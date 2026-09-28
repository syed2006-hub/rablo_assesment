import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A reusable horizontal tab selector for filtering and category navigation.
class CommonTabSelector extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final EdgeInsetsGeometry padding;

  const CommonTabSelector({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(tabs.length, (index) {
            final isSelected = selectedIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => onTabSelected(index),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.dark : AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.dark
                          : AppColors.lightGrey.withValues(alpha: 0.8),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.dark.withValues(alpha: 0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Text(
                    tabs[index],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? AppColors.primaryBright : AppColors.dark,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
