import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A reusable search field component with integrated clear action.
class CommonSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const CommonSearchField({
    super.key,
    required this.controller,
    this.hintText = 'Search members, phone, or plan...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.lightGrey.withValues(alpha: 0.8),
        ),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.dark,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(
            fontSize: 14,
            color: AppColors.grey,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.grey,
            size: 20,
          ),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.grey),
                  onPressed: () {
                    controller.clear();
                    if (onChanged != null) onChanged!('');
                    if (onClear != null) onClear!();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        ),
      ),
    );
  }
}
