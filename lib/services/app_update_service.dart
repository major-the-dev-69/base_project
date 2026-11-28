import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_service/components/app_buttons.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/app_logger.dart';
import '../components/app_snack_bar.dart';

class VersionStatus {
  /// The current version of the app.
  final String localVersion;

  /// The most recent version of the app in the store.
  final String storeVersion;

  /// The most recent version of the app in the store.
  final String? originalStoreVersion;

  /// A link to the app store page where the app can be updated.
  final String appStoreLink;

  /// The release notes for the store version of the app.
  final String? releaseNotes;

  /// Returns `true` if the store version of the application is greater than the local version.
  bool get canUpdate {
    final local = localVersion.split('.').map(int.parse).toList();
    final store = storeVersion.split('.').map(int.parse).toList();

    for (var i = 0; i < store.length; i++) {
      if (store[i] > local[i]) {
        return true;
      }
      if (local[i] > store[i]) {
        return false;
      }
    }
    return false;
  }

  //Public Constructor
  VersionStatus({
    required this.localVersion,
    required this.storeVersion,
    required this.appStoreLink,
    this.releaseNotes,
    this.originalStoreVersion,
  });

  VersionStatus._({
    required this.localVersion,
    required this.storeVersion,
    required this.appStoreLink,
    this.releaseNotes,
    this.originalStoreVersion,
  });
}

class NewVersionPlus {
  final String? iOSId;
  final String? androidId;
  final String? iOSAppStoreCountry;
  final String? androidPlayStoreCountry;
  final String? forceAppVersion;
  final bool androidHtmlReleaseNotes;
  final _dio = Dio();
  NewVersionPlus({
    this.androidId,
    this.iOSId,
    this.iOSAppStoreCountry,
    this.forceAppVersion,
    this.androidPlayStoreCountry,
    this.androidHtmlReleaseNotes = false,
  });

  Future<VersionStatus?> getVersionStatus() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (Platform.isIOS) {
      return _getIOSStoreVersion(packageInfo);
    } else if (Platform.isAndroid) {
      return _getAndroidStoreVersion(packageInfo);
    } else {
      printMessage(
        'The target platform "${Platform.operatingSystem}" is not yet supported by this package.',
      );
      return null;
    }
  }

  /// This function attempts to clean local version strings so they match the MAJOR.MINOR.PATCH
  /// versioning pattern, so they can be properly compared with the store version.
  String _getCleanVersion(String version) {
    return RegExp(r'\d+(\.\d+)?(\.\d+)?').stringMatch(version) ?? '0.0.0';
  }

  //RegExp(r'\d+\.\d+(\.\d+)?').stringMatch(version) ?? '0.0.0';
  //RegExp(r'\d+\.\d+(\\.[a-z]+)?(\\.([^\"]|\\\\\")*)?').stringMatch(version) ?? '0.0.0'; \\d+(\\.\\d+)?(\\.\\d+)?

  /// iOS info is fetched by using the iTunes lookup API, which returns a
  /// JSON document.

  Future<VersionStatus?> _getIOSStoreVersion(PackageInfo packageInfo) async {
    final id = iOSId ?? packageInfo.packageName;

    Map<String, dynamic> parameters = {};

    /// programmermager:fix/issue-35-ios-failed-host-lookup
    if (id.contains('.')) {
      parameters['bundleId'] = id;
    } else {
      parameters['id'] = id;
    }

    parameters['timestamp'] = DateTime.now().millisecondsSinceEpoch.toString();

    if (iOSAppStoreCountry != null) {
      parameters.addAll({"country": iOSAppStoreCountry!});
    }

    try {
      final response = await _dio.getUri<String>(
        Uri.https("itunes.apple.com", "/lookup", parameters),
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode != 200) {
        printMessage('Failed to query iOS App Store');
        return null;
      }

      final jsonObj = json.decode(response.data!);
      final List results = jsonObj['results'];
      if (results.isEmpty) {
        printMessage("Can't find an app in the App Store with the id: $id");
        return null;
      }
      return VersionStatus._(
        localVersion: _getCleanVersion(packageInfo.version),
        storeVersion: _getCleanVersion(
          forceAppVersion ?? jsonObj['results'][0]['version'],
        ),
        originalStoreVersion:
            forceAppVersion ?? jsonObj['results'][0]['version'],
        appStoreLink: jsonObj['results'][0]['trackViewUrl'],
        releaseNotes: jsonObj['results'][0]['releaseNotes'],
      );
    } catch (e) {
      printMessage('Failed to query iOS App Store\n$e');
      return null;
    }
  }

  /// Android info is fetched by parsing the html of the app store page.
  Future<VersionStatus?> _getAndroidStoreVersion(
    PackageInfo packageInfo,
  ) async {
    final id = androidId ?? packageInfo.packageName;
    final uri = Uri.https("play.google.com", "/store/apps/details", {
      "id": id.toString(),
      "hl": androidPlayStoreCountry ?? "en_US",
      "timestamp": DateTime.now().millisecondsSinceEpoch.toString(),
    });

    try {
      final response = await _dio.getUri<String>(
        uri,
        options: Options(responseType: ResponseType.plain),
      );

      if (response.statusCode != 200) {
        throw Exception("Invalid response code: ${response.statusCode}");
      }

      final regexp = RegExp(
        r'\[\[\[\"(\d+\.\d+(\.[a-z]+)?(\.([^"]|\\")*)?)\"\]\]',
      );

      final storeVersion = regexp.firstMatch(response.data!)?.group(1);

      //Release
      final regexpRelease = RegExp(
        r'\[(null,)\[(null,)\"((\.[a-z]+)?(([^\"|\\\"])*)?)\"\]\]',
      );

      final expRemoveSc = RegExp(
        r"\\u003c[A-Za-z]{1,10}\\u003e",
        multiLine: true,
        caseSensitive: true,
      );

      final expRemoveQuote = RegExp(
        r"\\u0026quot;",
        multiLine: true,
        caseSensitive: true,
      );

      final releaseNotes = regexpRelease.firstMatch(response.data!)?.group(3);
      printMessage("_getAndroidStoreVersion $releaseNotes");
      return VersionStatus._(
        localVersion: _getCleanVersion(packageInfo.version),
        storeVersion: _getCleanVersion(forceAppVersion ?? storeVersion ?? ""),
        originalStoreVersion: forceAppVersion ?? storeVersion ?? "",
        appStoreLink: uri.toString(),
        releaseNotes: androidHtmlReleaseNotes
            ? _parseUnicodeToString(releaseNotes)
            : releaseNotes
                  ?.replaceAll(expRemoveSc, '')
                  .replaceAll(expRemoveQuote, '"'),
      );
    } catch (e) {
      printMessage('Failed to query Google Play Store\n$e');
      return null;
    }
  }

  /// Update action fun
  /// show modal
  void _updateActionFunc({
    required String appStoreLink,
    required bool allowDismissal,
    required BuildContext context,
    LaunchMode launchMode = LaunchMode.platformDefault,
  }) {
    launchAppStore(appStoreLink, launchMode: launchMode);
    if (allowDismissal) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  void showUpdateDialog({
    required BuildContext context,
    required VersionStatus versionStatus,
    String dialogTitle = 'Update Available',
    String? dialogText,
    String updateButtonText = 'Update',
    bool allowDismissal = true,
    String dismissButtonText = 'Maybe Later',
    VoidCallback? dismissAction,
    LaunchModeVersion launchModeVersion = LaunchModeVersion.normal,
  }) async {
    final dialogTitleWidget = Text(dialogTitle);
    final dialogTextWidget = Text(
      dialogText ??
          'You can now update this app from ${versionStatus.localVersion} to ${versionStatus.storeVersion}',
    );

    final launchMode = launchModeVersion == LaunchModeVersion.external
        ? LaunchMode.externalApplication
        : LaunchMode.platformDefault;

    final updateButtonTextWidget = Text(updateButtonText);

    List<Widget> actions = [
      Platform.isAndroid
          ? TextButton(
              onPressed: () => _updateActionFunc(
                allowDismissal: allowDismissal,
                context: context,
                appStoreLink: versionStatus.appStoreLink,
                launchMode: launchMode,
              ),
              child: updateButtonTextWidget,
            )
          : CupertinoDialogAction(
              onPressed: () => _updateActionFunc(
                allowDismissal: allowDismissal,
                context: context,
                appStoreLink: versionStatus.appStoreLink,
                launchMode: launchMode,
              ),
              child: updateButtonTextWidget,
            ),
    ];

    if (allowDismissal) {
      final dismissButtonTextWidget = Text(dismissButtonText);
      dismissAction =
          dismissAction ??
          () => Navigator.of(context, rootNavigator: true).pop();
      actions.add(
        Platform.isAndroid
            ? TextButton(
                onPressed: dismissAction,
                child: dismissButtonTextWidget,
              )
            : CupertinoDialogAction(
                onPressed: dismissAction,
                child: dismissButtonTextWidget,
              ),
      );
    }

    await showDialog(
      context: context,
      barrierDismissible: allowDismissal,
      builder: (BuildContext context) {
        return PopScope(
          canPop: allowDismissal,
          child: Platform.isAndroid
              ? AlertDialog(
                  title: dialogTitleWidget,
                  content: dialogTextWidget,
                  actions: actions,
                )
              : CupertinoAlertDialog(
                  title: dialogTitleWidget,
                  content: dialogTextWidget,
                  actions: actions,
                ),
        );
      },
    );
  }

  /// Launches the Apple App Store or Google Play Store page for the app.
  Future<void> launchAppStore(
    String appStoreLink, {
    LaunchMode launchMode = LaunchMode.platformDefault,
  }) async {
    if (await canLaunchUrl(Uri.parse(appStoreLink))) {
      await launchUrl(Uri.parse(appStoreLink), mode: launchMode);
    } else {
      throw 'Could not launch appStoreLink';
    }
  }

  /// Function for convert text
  /// _parseUnicodeToString
  String? _parseUnicodeToString(String? release) {
    try {
      if (release == null || release.isEmpty) return release;

      final re = RegExp(
        r'(%(?<asciiValue>[0-9A-Fa-f]{2}))'
        r'|(\u(?<codePoint>[0-9A-Fa-f]{4}))'
        r'|.',
      );

      var matches = re.allMatches(release);
      var codePoints = <int>[];
      for (var match in matches) {
        var codePoint =
            match.namedGroup('asciiValue') ?? match.namedGroup('codePoint');
        if (codePoint != null) {
          codePoints.add(int.parse(codePoint, radix: 16));
        } else {
          codePoints += match.group(0)!.runes.toList();
        }
      }
      var decoded = String.fromCharCodes(codePoints);
      return decoded;
    } catch (e) {
      return release;
    }
  }
}

enum LaunchModeVersion { normal, external }

Future<bool> isUpdateAvailable() async {
  try {
    final newVersion = NewVersionPlus();
    final status = await newVersion.getVersionStatus();

    return status?.canUpdate ?? false;
  } catch (e) {
    return false;
  }
}

Future<void> checkUpdateAvailable() async {
  bool isAvailable = await isUpdateAvailable();
  printMessage("checkUpdateAvailable: $isAvailable");
  if (isAvailable) {
    final theme = Get.theme;
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    await Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          backgroundColor: colorScheme.surfaceContainer,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer.withValues(alpha: 0.3),
                  colorScheme.surface,
                ],
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon badge
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    CupertinoIcons.arrow_down_to_line,
                    size: 48,
                    color: colorScheme.primary,
                  ),
                ),

                const SizedBox(height: 20),

                // Title
                Text(
                  'Update Available!',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Description
                Text(
                  'A new version of the app is available with exciting features and improvements.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 8),

                // Features list
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainer.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: colorScheme.surfaceContainer,
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Bug fixes and performance improvements',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: colorScheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Enhanced user experience',
                              style: textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Update button
                AppButton(onTap: _navigateToPlayStore, title: "Update Now"),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
}

void _navigateToPlayStore() async {
  final info = await PackageInfo.fromPlatform();
  final url = Uri.parse(
    "https://play.google.com/store/apps/details?id=${info.packageName}",
  );
  try {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      CustomSnackBar.showError(message: "Could not launch Play Store");
    }
  } catch (e) {
    CustomSnackBar.showError(message: "An error occurred: ${e.toString()}");
  }
}

/// Entry-point class for triggering the in-app update check.
/// Call [initialize] once the app has fully started (e.g. in [GetMaterialApp.onInit]).
class AppUpdate {
  static Future<void> initialize() async {
    await checkUpdateAvailable();
  }
}
