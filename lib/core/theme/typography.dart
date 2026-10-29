import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Application Typography
/// Centralized text style definitions unified with Web Storefront (Cairo Font)
class AppTypography {
  // Private constructor to prevent instantiation
  AppTypography._();

  // Base Font Family (Cairo Arabic Font matching React Storefront)
  static String get fontFamily => GoogleFonts.cairo().fontFamily!;

  // Heading Styles
  static TextStyle h1 = GoogleFonts.cairo(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.3,
    height: 1.3,
  );

  static TextStyle h2 = GoogleFonts.cairo(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    letterSpacing: -0.2,
    height: 1.3,
  );

  static TextStyle h3 = GoogleFonts.cairo(
    fontSize: 18,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.1,
    height: 1.35,
  );

  static TextStyle h4 = GoogleFonts.cairo(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.1,
    height: 1.4,
  );

  static TextStyle h5 = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  static TextStyle h6 = GoogleFonts.cairo(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Body Text Styles
  static TextStyle bodyLarge = GoogleFonts.cairo(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.cairo(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.cairo(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  // Button Text Style
  static TextStyle button = GoogleFonts.cairo(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.2,
  );

  // Caption Text Style
  static TextStyle caption = GoogleFonts.cairo(
    fontSize: 11,
    fontWeight: FontWeight.normal,
    height: 1.3,
  );

  // Overline Text Style
  static TextStyle overline = GoogleFonts.cairo(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    height: 1.4,
  );

  // Label Text Styles
  static TextStyle labelLarge = GoogleFonts.cairo(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );

  static TextStyle labelMedium = GoogleFonts.cairo(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  static TextStyle labelSmall = GoogleFonts.cairo(
    fontSize: 10,
    fontWeight: FontWeight.w500,
  );
}
