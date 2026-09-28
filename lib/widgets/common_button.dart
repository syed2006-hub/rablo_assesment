import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A reusable elevated button component styled to Figma design guidelines.
class CommonButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isEnabled;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double height;
  final double borderRadius;

  const CommonButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isEnabled = true,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.height = 50.0,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final bool canPress = isEnabled && !isLoading && onPressed != null;
    final Color buttonColor = canPress
        ? (backgroundColor ?? AppColors.primary)
        : AppColors.lightGrey;
    final Color effectiveTextColor = canPress
        ? (textColor ?? AppColors.dark)
        : AppColors.grey;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: canPress ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: effectiveTextColor,
          disabledBackgroundColor: AppColors.lightGrey,
          disabledForegroundColor: AppColors.grey,
          elevation: canPress ? 1.5 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: isLoading
            ? SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(effectiveTextColor),
                ),
              )
            : Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: effectiveTextColor,
                ),
              ),
      ),
    );
  }
}
