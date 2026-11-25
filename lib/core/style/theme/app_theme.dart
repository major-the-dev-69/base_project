import 'package:flutter/material.dart';

import '../color/app_color.dart';

class AppTheme {
  AppTheme._();

  static ThemeData light = _buildTheme(AppColors.lightScheme, Brightness.light);

  static ThemeData dark = _buildTheme(AppColors.darkScheme, Brightness.dark);

  static ThemeData nova = _buildTheme(AppColors.darkScheme, Brightness.dark);

  static ThemeData _buildTheme(ColorScheme scheme, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final radius = BorderRadius.circular(12);

    Color scaffoldBg = scheme.surface;
    Color inputFillColor = scheme.surfaceContainerHighest;
    if (isLight) {
      scaffoldBg = AppColors.background;
      inputFillColor = scheme.surface;
    }

    OutlineInputBorder inputBorder(Color color, {double width = 1}) {
      return OutlineInputBorder(
        borderRadius: radius,
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldBg,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: inputFillColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant, fontSize: 14),
        border: inputBorder(scheme.outline),
        enabledBorder: inputBorder(scheme.outline),
        focusedBorder: inputBorder(scheme.primary, width: 1.5),
        errorBorder: inputBorder(scheme.error),
        focusedErrorBorder: inputBorder(scheme.error, width: 1.5),
        disabledBorder: inputBorder(scheme.outlineVariant),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: scheme.outlineVariant,
          disabledForegroundColor: scheme.onSurfaceVariant,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(double.infinity, 48),
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary),
          shape: RoundedRectangleBorder(borderRadius: radius),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: scheme.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return scheme.primary;
          }
          return scheme.onSurfaceVariant;
        }),
      ),
    );
  }
}
