import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A reusable container card component for structured content sections.
class CommonContainer extends StatelessWidget {
  final Widget? child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BoxDecoration? decoration;
  final Color? backgroundColor;
  final double? borderRadius;
  final Border? border;
  final double? width;
  final double? height;

  const CommonContainer({
    super.key,
    this.child,
    this.padding,
    this.margin,
    this.decoration,
    this.backgroundColor,
    this.borderRadius,
    this.border,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDecoration = decoration ??
        BoxDecoration(
          color: backgroundColor ?? AppColors.white,
          borderRadius: BorderRadius.circular(borderRadius ?? 16.0),
          border: border ??
              Border.all(
                color: AppColors.lightGrey.withValues(alpha: 0.6),
                width: 1.0,
              ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        );

    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding ?? const EdgeInsets.all(16.0),
      decoration: effectiveDecoration,
      child: child,
    );
  }
}
