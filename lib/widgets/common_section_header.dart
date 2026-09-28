import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A reusable section header component with consistent title and subtitle hierarchy.
class CommonSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final EdgeInsetsGeometry padding;

  const CommonSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.padding = const EdgeInsets.only(left: 4, bottom: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.dark,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.grey,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
