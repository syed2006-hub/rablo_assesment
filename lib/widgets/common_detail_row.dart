import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A reusable key-value detail row for detail screens and profile views.
class CommonDetailRow extends StatelessWidget {
  final String label;
  final String? value;
  final Widget? valueWidget;
  final IconData? icon;
  final bool showDivider;

  const CommonDetailRow({
    super.key,
    required this.label,
    this.value,
    this.valueWidget,
    this.icon,
    this.showDivider = true,
  }) : assert(value != null || valueWidget != null,
            'Either value or valueWidget must be provided');

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: AppColors.grey),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Align(
                  alignment: Alignment.centerRight,
                  child: valueWidget ??
                      Text(
                        value!,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dark,
                        ),
                        textAlign: TextAlign.end,
                      ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 1,
            color: AppColors.lightGrey.withValues(alpha: 0.5),
          ),
      ],
    );
  }
}
