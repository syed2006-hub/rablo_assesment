import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class CustomerFloatingNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onQrScanPressed;

  const CustomerFloatingNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onQrScanPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.fromLTRB(28, 0, 28, 20),
      decoration: BoxDecoration(
        color: AppColors.slateNavDock,
        borderRadius: BorderRadius.circular(36),
        border: Border.all(
          color: AppColors.slateBorderLight.withValues(alpha: 0.5),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Tab 0: Home Icon
          GestureDetector(
            onTap: () => onTabSelected(0),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 64,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_rounded,
                    color: currentIndex == 0 ? AppColors.primaryBright : AppColors.greyMuted,
                    size: 28,
                  ),
                  const SizedBox(height: 3),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3.5,
                    width: currentIndex == 0 ? 24 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBright,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Center Elevated Floating QR Scanner Button (Tab 1)
          Transform.translate(
            offset: const Offset(0, -10),
            child: GestureDetector(
              onTap: onQrScanPressed,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: currentIndex == 1
                      ? const Color(0xFF22444C)
                      : AppColors.slateCardDark,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryBright,
                    width: currentIndex == 1 ? 3.0 : 2.0,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBright.withValues(
                          alpha: currentIndex == 1 ? 0.7 : 0.35),
                      blurRadius: currentIndex == 1 ? 18 : 10,
                      spreadRadius: currentIndex == 1 ? 3 : 1,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.qr_code_scanner_rounded,
                    color: currentIndex == 1
                        ? AppColors.primaryBright
                        : Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),

          // Tab 2: Profile Icon
          GestureDetector(
            onTap: () => onTabSelected(2),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 64,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_rounded,
                    color: currentIndex == 2
                        ? AppColors.primaryBright
                        : AppColors.greyMuted,
                    size: 28,
                  ),
                  const SizedBox(height: 3),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 3.5,
                    width: currentIndex == 2 ? 24 : 0,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBright,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
