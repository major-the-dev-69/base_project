import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_service/core/network/api_services.dart';
import 'package:go_service/core/style/theme/app_theme.dart';
import 'package:go_service/services/session_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

class BaseController extends GetxController {
  final isLoading = false.obs;

  void startLoading() {
    isLoading.value = true;
  }

  void stopLoading() {
    isLoading.value = false;
  }

  final api = Get.find<ApiServices>();
  final session = Get.find<SessionService>();

  final appName = "".obs;

  // --------------------------------------------------
  // THEME
  // --------------------------------------------------

  /// Mirrors [SessionService.themeMode] so the entire widget tree reacts
  /// whenever the user changes the theme preference.
  late final Rx<ThemeMode> activeTheme = session.themeMode;

  /// Returns the [ThemeData] that corresponds to the given [ThemeMode].
  /// For [ThemeMode.system] it reads the current platform brightness.
  ThemeData getThemeData(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return AppTheme.dark;
      case ThemeMode.light:
        return AppTheme.light;
      case ThemeMode.system:
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark ? AppTheme.dark : AppTheme.light;
    }
  }

  /// Persists and applies a new [ThemeMode] through [SessionService].
  Future<void> setTheme(ThemeMode mode) => session.setThemeMode(mode);

  // --------------------------------------------------
  // APP INFO
  // --------------------------------------------------

  Future<void> onAppOpen() async {
    final app = await PackageInfo.fromPlatform();
    appName.value = app.appName;
    update();
  }
}
