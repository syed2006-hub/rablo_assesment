import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralized text styles matching Figma typography specifications.
class AppTextStyles {
  AppTextStyles._();

  /// Bold italic hero display heading (e.g. "Manage Your", "Welcome Back!")
  static const TextStyle heroBoldItalic = TextStyle(
    color: AppColors.white,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    letterSpacing: -0.5,
    height: 1.15,
  );

  /// Neon lime bold italic text accent
  static const TextStyle heroNeonItalic = TextStyle(
    color: AppColors.primaryLight,
    fontSize: 28,
    fontWeight: FontWeight.w900,
    fontStyle: FontStyle.italic,
    letterSpacing: -0.5,
    height: 1.15,
  );

  /// Section heading (e.g. "Welcome Back!", "Manage Your Plan")
  static const TextStyle sectionTitleItalic = TextStyle(
    color: AppColors.white,
    fontSize: 22,
    fontWeight: FontWeight.w800,
    fontStyle: FontStyle.italic,
    letterSpacing: -0.3,
  );

  /// Subtitle / description light text
  static const TextStyle subtitle = TextStyle(
    color: AppColors.white,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  /// Muted grey subtext
  static const TextStyle subtextMuted = TextStyle(
    color: AppColors.greyMuted,
    fontSize: 12,
    fontWeight: FontWeight.w400,
  );

  /// KPI / Large number (e.g. "498", "365", "35")
  static const TextStyle kpiNumberNeon = TextStyle(
    color: AppColors.primaryLight,
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
  );

  static const TextStyle kpiNumberWhite = TextStyle(
    color: AppColors.white,
    fontSize: 32,
    fontWeight: FontWeight.w900,
    letterSpacing: -0.5,
  );

  /// Button label in bold dark text (for neon green buttons)
  static const TextStyle buttonDark = TextStyle(
    color: Color(0xFF0C191B),
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: 0.2,
  );

  /// Button label in bold light text
  static const TextStyle buttonLight = TextStyle(
    color: AppColors.white,
    fontSize: 14,
    fontWeight: FontWeight.w700,
  );

  /// Card title
  static const TextStyle cardTitle = TextStyle(
    color: AppColors.white,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  /// Pill badge label
  static const TextStyle badgeLabel = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
  );
}
