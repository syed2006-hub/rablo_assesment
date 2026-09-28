import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A reusable dropdown/selection field for choosing options.
class CommonSelectionField<T> extends StatelessWidget {
  final String? label;
  final String? hintText;
  final List<T> options;
  final T? selectedValue;
  final ValueChanged<T?>? onChanged;
  final String Function(T item)? optionLabelBuilder;
  final String? Function(T?)? validator;
  final bool enabled;

  const CommonSelectionField({
    super.key,
    this.label,
    this.hintText,
    required this.options,
    this.selectedValue,
    required this.onChanged,
    this.optionLabelBuilder,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.dark,
            ),
          ),
          const SizedBox(height: 6),
        ],
        DropdownButtonFormField<T>(
          initialValue: selectedValue,
          items: options.map((T item) {
            final String displayText = optionLabelBuilder != null
                ? optionLabelBuilder!(item)
                : item.toString();
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                displayText,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.dark,
                ),
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.lightGrey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.grey,
          ),
        ),
      ],
    );
  }
}
