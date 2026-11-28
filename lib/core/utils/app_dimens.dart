import 'dart:ui';

import 'package:get/get.dart';

class AppDimens {
  AppDimens._();

  static const double baseWidth = 440.0;

  /// Safely resolves the logical screen width even before the widget tree context is mounted.
  static double get screenWidth {
    try {
      if (Get.context != null && Get.width > 0) {
        return Get.width;
      }
    } catch (_) {}

    try {
      final views = PlatformDispatcher.instance.views;
      if (views.isNotEmpty) {
        final view = views.first;
        if (view.devicePixelRatio > 0 && view.physicalSize.width > 0) {
          return view.physicalSize.width / view.devicePixelRatio;
        }
      }
    } catch (_) {}

    return baseWidth;
  }

  static double get _scale => (screenWidth / baseWidth).clamp(0.85, 1.25);

  /// Responsive font size scaled relative to [baseWidth], clamped for readability.
  static double sp(double size) => size * _scale;

  /// Responsive regular dimension (padding, margin, radius, icon, height/width)
  /// scaled relative to [baseWidth], clamped for readability.
  static double dp(double size) => size * _scale;

  /// 📌 Padding
  static double get paddingXSmall => dp(4.0);
  static double get paddingSmall => dp(8.0);
  static double get paddingBasic => dp(12.0);
  static double get paddingMedium => dp(16.0);
  static double get paddingLarge => dp(24.0);
  static double get paddingXLarge => dp(32.0);

  /// 📌 Margin
  static double get marginXSmall => dp(4.0);
  static double get marginSmall => dp(8.0);
  static double get marginMedium => dp(16.0);
  static double get marginLarge => dp(24.0);
  static double get marginXLarge => dp(32.0);

  /// 📌 Spacing (between widgets)
  static double get spaceXSmall => dp(4.0);
  static double get spaceSmall => dp(8.0);
  static double get spaceMedium => dp(16.0);
  static double get spaceLarge => dp(24.0);
  static double get spaceXLarge => dp(32.0);

  /// 📌 Border radius
  static double get radiusSmall => dp(6.0);
  static double get radiusMedium => dp(12.0);
  static double get radiusLarge => dp(20.0);
  static double get radiusXLarge => dp(30.0);
  static const double radiusCircular = 100.0;

  /// 📌 Elevation
  static const double elevationLow = 2.0;
  static const double elevationMedium = 4.0;
  static const double elevationHigh = 8.0;

  /// 📌 Icons
  static double get iconSmall => dp(16.0);
  static double get iconMedium => dp(24.0);
  static double get iconLarge => dp(32.0);
  static double get iconXLarge => dp(48.0);

  /// 📌 AppBar & Navigation
  static double get appBarHeight => dp(56.0);
  static double get leadingWidth => dp(68.0);
  static double get bottomNavHeight => dp(60.0);

  /// 📌 Buttons
  static double get buttonHeight => dp(48.0);
  static double get buttonRadius => dp(12.0);
  static double get buttonPadding => dp(16.0);
  static double get buttonPaddingV => dp(14.0);
  static double get buttonPaddingH => dp(20.0);

  /// 📌 Cards
  static double get cardRadius => dp(16.0);
  static const double cardElevation = 4.0;
  static double get cardPadding => dp(12.0);

  /// 📌 Text fields
  static double get textFieldHeight => dp(56.0);
  static double get textFieldRadius => dp(32.0);

  /// 📌 Divider
  static const double dividerThickness = 1.0;
  static double get dividerIndent => dp(16.0);

  /// 📌 Shadows
  static double get blurSmall => dp(6.0);
  static double get blurMedium => dp(10.0);
  static double get blurLarge => dp(12.0);

  static double get spreadSmall => dp(1.0);
  static double get spreadMedium => dp(2.0);

  static double get offsetSmall => dp(2.0);
  static double get offsetMedium => dp(4.0);
  static double get offsetLarge => dp(6.0);

  /// 📌 Borders
  static const double strokeThin = 0.5;
  static const double strokeSmall = 1.0;
  static const double strokeMedium = 1.5;
  static const double strokeThick = 2.0;
}

/// Convenient shorthand for responsive sizes (`16.dp`, `14.sp`).
extension AppResponsiveSize on num {
  double get dp => AppDimens.dp(toDouble());
  double get sp => AppDimens.sp(toDouble());
}
