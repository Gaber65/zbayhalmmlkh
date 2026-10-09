import 'package:flutter/material.dart';

/// Application Color Constants matching the reference design.
class AppColors {
  AppColors._();

  // Primary Accent Colors (Changed to Royal Blue for OTA Patch Test)
  static const Color primary = Color(0xFF2563EB);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFEFF6FF);
  static const Color onPrimaryContainer = Color(0xFF1E40AF);
  static const Color inversePrimary = Color(0xFF60A5FA);
  static const Color primaryFixed = Color(0xFFDBEAFE);
  static const Color primaryFixedDim = Color(0xFFBFDBFE);
  static const Color onPrimaryFixed = Color(0xFF1E3A8A);
  static const Color onPrimaryFixedVariant = Color(0xFF1D4ED8);

  // Secondary Colors (Clean Neutral Charcoal & Slate)
  static const Color secondary = Color(0xFF7A7E89);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFF2F2F5);
  static const Color onSecondaryContainer = Color(0xFF2C2D35);
  static const Color secondaryFixed = Color(0xFFEAEAEF);
  static const Color secondaryFixedDim = Color(0xFFD5D5DC);
  static const Color onSecondaryFixed = Color(0xFF14151B);
  static const Color onSecondaryFixedVariant = Color(0xFF4A4C56);

  // Tertiary Colors (Accent Amber / Star Rating)
  static const Color tertiary = Color(0xFFFFB300);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFFFFF8E1);
  static const Color onTertiaryContainer = Color(0xFFFF8F00);

  // Error Colors
  static const Color error = Color(0xFFE53935);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFEBEE);
  static const Color onErrorContainer = Color(0xFFC62828);

  // Clean White Background & Minimal Surfaces
  static const Color background = Color(0xFFFFFFFF);
  static const Color onBackground = Color(0xFF1A1D26);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1D26);
  static const Color surfaceVariant = Color(0xFFF5F5F7);
  static const Color onSurfaceVariant = Color(0xFF7A7E89);
  static const Color inverseSurface = Color(0xFF1A1D26);
  static const Color inverseOnSurface = Color(0xFFF9F9FB);

  // Dark Surfaces
  static const Color darkBackground = Color(0xFF121214);
  static const Color darkSurface = Color(0xFF18181B);
  static const Color darkSurfaceVariant = Color(0xFF27272A);
  static const Color darkOnSurface = Color(0xFFF4F4F5);
  static const Color darkOnSurfaceVariant = Color(0xFFA1A1AA);

  // Surface Containers (Light Elevation System)
  static const Color surfaceDim = Color(0xFFEFEFF3);
  static const Color surfaceBright = Color(0xFFFFFFFF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF9F9FB);
  static const Color surfaceContainer = Color(0xFFF4F4F7);
  static const Color surfaceContainerHigh = Color(0xFFEDEDF2);
  static const Color surfaceContainerHighest = Color(0xFFE5E5EB);
  static const Color surfaceTint = Color(0xFFE53935);

  // Outline & Borders
  static const Color outline = Color(0xFFD1D1D6);
  static const Color outlineVariant = Color(0xFFF0F0F3);
  static const Color darkOutline = Color(0xFF3F3F46);
  static const Color darkOutlineVariant = Color(0xFF27272A);

  // Compatibility Aliases
  static const Color textPrimary = onSurface;
  static const Color textSecondary = onSurfaceVariant;
  static const Color border = outlineVariant;
  static const Color divider = outlineVariant;

  // Soft Red Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFEF5350),
      Color(0xFFE53935),
    ],
  );

  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFEF5350),
      Color(0xFFE53935),
    ],
  );

  static const RadialGradient ambientGlowGradient = RadialGradient(
    center: Alignment.center,
    radius: 0.8,
    colors: [
      Color(0xFFFFEBEE),
      Color(0xFFFFFFFF),
    ],
  );
}
