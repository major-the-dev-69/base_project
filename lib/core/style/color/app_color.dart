import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const primary = Color(0xFFD81B60);
  static const primaryDark = Color(0xFFAD1457);
  static const primaryLight = Color(0xFFF8BBD0);
  static const primaryContainer = Color(0xFFFCE4EC);

  // Secondary
  static const secondary = Color(0xFFFF6B8A);
  static const secondaryContainer = Color(0xFFFFDCE5);

  // Tertiary
  static const tertiary = Color(0xFF833B63);
  static const tertiaryContainer = Color(0xFFF3DCE8);

  // Background & Surface
  static const background = Color(0xFFFFF5F7);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceVariant = Color(0xFFF8E9EF);

  // Text
  static const textPrimary = Color(0xFF321523);
  static const textSecondary = Color(0xFF806574);

  // Other
  static const error = Color(0xFFBA1A1A);
  static const outline = Color(0xFFE7C7D5);
  static const divider = Color(0xFFF1DCE5);

  static const lightScheme = ColorScheme.light(
    primary: primary,
    onPrimary: Colors.white,
    primaryContainer: primaryContainer,
    onPrimaryContainer: Color(0xFF510020),

    secondary: secondary,
    onSecondary: Color(0xFF4A0019),
    secondaryContainer: secondaryContainer,
    onSecondaryContainer: Color(0xFF51001F),

    tertiary: tertiary,
    onTertiary: Colors.white,
    tertiaryContainer: tertiaryContainer,
    onTertiaryContainer: Color(0xFF351027),

    error: error,
    onError: Colors.white,

    surface: surface,
    onSurface: textPrimary,
    onSurfaceVariant: textSecondary,

    outline: outline,
    outlineVariant: divider,

    shadow: Colors.black,
    scrim: Colors.black54,
    inverseSurface: Color(0xFF39232F),
    onInverseSurface: Colors.white,
    inversePrimary: Color(0xFFFFB1C8),
    surfaceTint: primary,
  );

  static const darkScheme = ColorScheme.dark(
    primary: Color(0xFFFF80AB),
    onPrimary: Color(0xFF590027),
    primaryContainer: Color(0xFF880E4F),
    onPrimaryContainer: Color(0xFFFFD9E4),

    secondary: Color(0xFFFF9AAF),
    onSecondary: Color(0xFF590D29),
    secondaryContainer: Color(0xFF762D47),
    onSecondaryContainer: Color(0xFFFFD9E2),

    tertiary: Color(0xFFE8A9CD),
    onTertiary: Color(0xFF4A1738),
    tertiaryContainer: Color(0xFF63304F),
    onTertiaryContainer: Color(0xFFFFD8ED),

    error: Color(0xFFFFB4AB),
    onError: Color(0xFF690005),

    surface: Color(0xFF21151C),
    onSurface: Color(0xFFFFEAF0),
    onSurfaceVariant: Color(0xFFD5BFC9),

    outline: Color(0xFF947A86),
    outlineVariant: Color(0xFF59444F),

    shadow: Colors.black,
    scrim: Colors.black54,
    inverseSurface: Color(0xFFFFEAF0),
    onInverseSurface: Color(0xFF39232F),
    inversePrimary: primary,
    surfaceTint: Color(0xFFFF80AB),
  );
}
