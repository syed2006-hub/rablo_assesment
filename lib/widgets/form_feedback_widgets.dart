import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

/// Guarded Submit Button with automatic duplicate submission prevention & loading indicator
class FormSubmitButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isSubmitting;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double? width;
  final double borderRadius;
  final Widget? icon;

  const FormSubmitButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isSubmitting = false,
    this.backgroundColor,
    this.textColor,
    this.height = 48.0,
    this.width,
    this.borderRadius = 12.0,
    this.icon,
  });

  bool get _isBusy => isLoading || isSubmitting;

  @override
  Widget build(BuildContext context) {
    final effectiveBg = backgroundColor ?? AppColors.primaryBright;
    final effectiveText = textColor ?? Colors.black;

    return SizedBox(
      width: width ?? double.infinity,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: _isBusy ? effectiveBg.withValues(alpha: 0.6) : effectiveBg,
          foregroundColor: effectiveText,
          elevation: _isBusy ? 0 : 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
        ),
        // Duplicate Submission Protection: Ignore taps while submitting/loading
        onPressed: _isBusy ? null : onPressed,
        child: _isBusy
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(effectiveText),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Processing...',
                    style: TextStyle(
                      color: effectiveText,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    icon!,
                    const SizedBox(width: 8),
                  ],
                  Text(
                    text,
                    style: TextStyle(
                      color: effectiveText,
                      fontSize: 14.5,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Alert banner displayed at the top of forms to communicate server/API validation errors
class ApiValidationBanner extends StatelessWidget {
  final String? errorMessage;
  final Map<String, dynamic>? validationErrors;
  final VoidCallback? onDismiss;
  final VoidCallback? onRetry;

  const ApiValidationBanner({
    super.key,
    this.errorMessage,
    this.validationErrors,
    this.onDismiss,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null && (validationErrors == null || validationErrors!.isEmpty)) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3B181A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF87171).withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFF87171),
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      errorMessage ?? 'Validation Error',
                      style: const TextStyle(
                        color: Color(0xFFFCA5A5),
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (validationErrors != null && validationErrors!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      ...validationErrors!.entries.map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            '• ${e.key}: ${e.value}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onDismiss != null)
                InkWell(
                  onTap: onDismiss,
                  child: const Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Icon(Icons.close, color: Colors.white70, size: 16),
                  ),
                ),
            ],
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFFCA5A5),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: onRetry,
                icon: const Icon(Icons.refresh, size: 14),
                label: const Text('Retry', style: TextStyle(fontSize: 12)),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Centralized UI Feedback helper for Snackbars and Feedback alerts
class AppFeedback {
  AppFeedback._();

  static void showSuccess({
    required String title,
    required String message,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF163238),
      colorText: AppColors.primaryBright,
      icon: const Icon(Icons.check_circle_rounded, color: AppColors.primaryBright),
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
      borderWidth: 1,
      borderColor: AppColors.primaryBright.withValues(alpha: 0.3),
    );
  }

  static void showError({
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF2A1518),
      colorText: const Color(0xFFFCA5A5),
      icon: const Icon(Icons.error_outline_rounded, color: Color(0xFFF87171)),
      margin: const EdgeInsets.all(16),
      borderRadius: 14,
      duration: const Duration(seconds: 4),
      borderWidth: 1,
      borderColor: const Color(0xFFF87171).withValues(alpha: 0.4),
      mainButton: onRetry != null
          ? TextButton(
              onPressed: () {
                Get.closeCurrentSnackbar();
                onRetry();
              },
              child: const Text(
                'RETRY',
                style: TextStyle(
                  color: AppColors.primaryBright,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            )
          : null,
    );
  }

  static void showNetworkError({VoidCallback? onRetry}) {
    showError(
      title: 'Network Failure',
      message: 'Unable to communicate with the server. Please verify your connection.',
      onRetry: onRetry,
    );
  }
}
