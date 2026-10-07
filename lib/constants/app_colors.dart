import 'package:flutter/material.dart';

/// Centralized application color palette derived strictly from Figma designs.
class AppColors {
  AppColors._();

  // Primary greens & Figma brand neon accents
  static const Color primary = Color(0xFF93CB1B);
  static const Color primaryBright = Color(0xFFB8FE22); // Figma vibrant CTA green
  static const Color primaryLight = Color(0xFFCEFF65);  // Figma heading neon lime
  static const Color veryLightGreen = Color(0xFFE3FFA7);
  static const Color neonGreen = Color(0xFFB8FE22);

  // Figma Customer Slate Teal Theme Colors
  static const Color slateScaffold = Color(0xFF0C191B);      // Dark slate background
  static const Color slateCard = Color(0xFF163238);          // Slate teal card surface
  static const Color slateCardDark = Color(0xFF112529);      // Darker card background
  static const Color slateCardLight = Color(0xFF1E4149);     // Elevated card surface
  static const Color slateBorder = Color(0xFF264F56);        // Border color
  static const Color slateBorderLight = Color(0xFF386C75);   // Lighter border
  static const Color slateDashedBorder = Color(0xFF3F7782);  // Dashed outline color
  static const Color slateNavDock = Color(0xFF132A2F);       // Bottom floating nav bar

  // Background and neutrals
  static const Color backgroundLight = Color(0xFFEDE7FF);
  static const Color grey = Color(0xFF7A7A7A);
  static const Color greyMuted = Color(0xFF8FA2A6);
  static const Color greyDark = Color(0xFF2C3E42);
  static const Color dark = Color(0xFF1E1E1E);
  static const Color textPrimary = Color(0xFF1E1E1E);

  // Additional UI utility colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color lightGrey = Color(0xFFE0E0E0);
  static const Color error = Color(0xFFD32F2F);

  // Figma Functional Accents
  static const Color cyanAccent = Color(0xFF38BDF8);      // "Redeem Now" button cyan
  static const Color peakRed = Color(0xFFEF4444);         // Peak rush hour indicator red
  static const Color rushYellow = Color(0xFFFACC15);      // Medium rush hour yellow
  static const Color rushGreen = Color(0xFF84CC16);       // Low occupancy rush hour green
  static const Color unverifiedRed = Color(0xFFDC2626);   // Unverified badge red
  static const Color verifiedGreen = Color(0xFF16A34A);   // Verified badge green
  static const Color badgeBlue = Color(0xFF0284C7);       // Notification count blue badge
}

