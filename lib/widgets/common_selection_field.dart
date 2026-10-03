import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A reusable dropdown/selection field for choosing options.
class CommonSelectionField<T> extends StatelessWidget {
  final String? label;
  final Widget? labelWidget;
  final String? hintText;
  final List<T> options;
  final T? selectedValue;
  final ValueChanged<T?>? onChanged;
  final String Function(T item)? optionLabelBuilder;
  final String? Function(T?)? validator;
  final bool enabled;
  final Color? fillColor;
  final Color? textColor;
  final Color? labelColor;
  final Color? hintColor;
  final Color? dropdownColor;
  final Color? iconColor;
  final Color? borderColor;
  final double borderRadius;

  const CommonSelectionField({
    super.key,
    this.label,
    this.labelWidget,
    this.hintText,
    required this.options,
    this.selectedValue,
    required this.onChanged,
    this.optionLabelBuilder,
    this.validator,
    this.enabled = true,
    this.fillColor,
    this.textColor,
    this.labelColor,
    this.hintColor,
    this.dropdownColor,
    this.iconColor,
    this.borderColor,
    this.borderRadius = 12.0,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AppColors.lightGrey;
    final effectiveFillColor = fillColor ?? AppColors.white;
    final effectiveTextColor = textColor ?? AppColors.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (labelWidget != null) ...[
          labelWidget!,
          const SizedBox(height: 6),
        ] else if (label != null) ...[
          Text(
            label!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: labelColor ?? AppColors.dark,
            ),
          ),
          const SizedBox(height: 6),
        ],
        DropdownButtonFormField<T>(
          isExpanded: true,
          initialValue: selectedValue,
          dropdownColor: dropdownColor ?? AppColors.white,
          items: options.map((T item) {
            final String displayText = optionLabelBuilder != null
                ? optionLabelBuilder!(item)
                : item.toString();
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 15,
                  color: effectiveTextColor,
                ),
              ),
            );
          }).toList(),
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              fontSize: 14,
              color: hintColor ?? AppColors.grey,
            ),
            filled: true,
            fillColor: effectiveFillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: effectiveBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: BorderSide(color: effectiveBorderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: iconColor ?? AppColors.grey,
          ),
        ),
      ],
    );
  }
}
