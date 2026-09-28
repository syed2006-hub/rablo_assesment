import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

/// A reusable modal popup dialog with customizable title, content, and actions.
class CommonPopup extends StatelessWidget {
  final String? title;
  final Widget? content;
  final String? message;
  final List<Widget>? actions;
  final EdgeInsetsGeometry padding;

  const CommonPopup({
    super.key,
    this.title,
    this.content,
    this.message,
    this.actions,
    this.padding = const EdgeInsets.all(20.0),
  });

  /// Static helper to show the popup dialog using GetX.
  static Future<T?> show<T>({
    String? title,
    String? message,
    Widget? content,
    List<Widget>? actions,
    bool barrierDismissible = true,
  }) {
    return Get.dialog<T>(
      CommonPopup(
        title: title,
        message: message,
        content: content,
        actions: actions,
      ),
      barrierDismissible: barrierDismissible,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      backgroundColor: AppColors.white,
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      actionsPadding: const EdgeInsets.all(16),
      title: title != null
          ? Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            )
          : null,
      content: content ??
          (message != null
              ? Text(
                  message!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.grey,
                  ),
                )
              : null),
      actions: actions,
    );
  }
}
