import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'common_container.dart';

/// A reusable statistical card displaying a metric, label, icon, and trend indicator.
class CommonStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final String? changeText;
  final bool isPositive;
  final IconData icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;
  final VoidCallback? onTap;

  const CommonStatCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    this.changeText,
    this.isPositive = true,
    required this.icon,
    this.iconColor,
    this.iconBackgroundColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: CommonContainer(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor ?? AppColors.veryLightGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? AppColors.dark,
                    size: 22,
                  ),
                ),
                if (changeText != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? AppColors.primary.withValues(alpha: 0.15)
                          : AppColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 12,
                          color: isPositive
                              ? const Color(0xFF558B2F)
                              : AppColors.error,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          changeText!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isPositive
                                ? const Color(0xFF558B2F)
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.grey,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
