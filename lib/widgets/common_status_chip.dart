import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A reusable status pill component with dynamic color mapping.
class CommonStatusChip extends StatelessWidget {
  final String status;
  final Color? backgroundColor;
  final Color? textColor;
  final double fontSize;

  const CommonStatusChip({
    super.key,
    required this.status,
    this.backgroundColor,
    this.textColor,
    this.fontSize = 11.0,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Color dotColor;

    switch (status.toLowerCase()) {
      case 'active':
        bg = AppColors.veryLightGreen;
        fg = const Color(0xFF33691E);
        dotColor = const Color(0xFF558B2F);
        break;
      case 'expiring':
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        dotColor = const Color(0xFFF57C00);
        break;
      case 'inactive':
      case 'expired':
        bg = const Color(0xFFFFEBEE);
        fg = AppColors.error;
        dotColor = AppColors.error;
        break;
      case 'vip':
      case 'platinum':
        bg = AppColors.backgroundLight;
        fg = const Color(0xFF4A148C);
        dotColor = const Color(0xFF7B1FA2);
        break;
      default:
        bg = AppColors.lightGrey.withValues(alpha: 0.5);
        fg = AppColors.dark;
        dotColor = AppColors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor ?? bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            status,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: textColor ?? fg,
            ),
          ),
        ],
      ),
    );
  }
}
