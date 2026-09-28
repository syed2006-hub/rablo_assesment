import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// A reusable application bar adhering to the dark & green brand aesthetic.
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget>? actions;

  const CommonAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.dark,
      elevation: 0,
      centerTitle: false,
      leading: leading ??
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.fitness_center_rounded,
                  color: AppColors.dark,
                  size: 20,
                ),
              ),
            ),
          ),
      leadingWidth: leading != null ? 56 : 60,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primaryBright,
              ),
            ),
        ],
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
