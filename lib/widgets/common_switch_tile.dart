import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'common_container.dart';

/// A reusable switch setting tile for settings and preference screens.
class CommonSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CommonSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CommonContainer(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: AppColors.dark, size: 20),
            ),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.dark,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.white,
            activeTrackColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
