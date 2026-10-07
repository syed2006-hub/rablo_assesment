import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../routes/app_routes.dart';

/// D1CM1 – Welcome Page.
/// Strictly implements Welcome Page design.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Trainer Photo from Figma
          Image.asset(
            'assets/images/welcome_bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (ctx, err, stack) => Container(
              color: const Color(0xFF102124),
              child: const Center(
                child: Icon(Icons.fitness_center, size: 80, color: AppColors.primaryLight),
              ),
            ),
          ),

          // Deep Dark Gradient Overlay at the bottom
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.65),
                  Colors.black.withValues(alpha: 0.95),
                  Colors.black,
                ],
                stops: const [0.0, 0.35, 0.55, 0.75, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Content Box at the bottom
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heading matching Figma typography
                  const Text(
                    'Manage Your',
                    style: AppTextStyles.heroBoldItalic,
                  ),
                  const Text(
                    'Fitness Centre',
                    style: AppTextStyles.heroNeonItalic,
                  ),
                  const Text(
                    'with us!',
                    style: AppTextStyles.heroBoldItalic,
                  ),

                  const SizedBox(height: 16),

                  // Subtitle
                  const Text(
                    'All your business operations in one place, ready for you to take charge.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.45,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Thin divider line
                  Container(
                    height: 1,
                    color: Colors.white.withValues(alpha: 0.2),
                  ),

                  const SizedBox(height: 22),

                  // "Get Started" Neon Green CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBright,
                        foregroundColor: Colors.black,
                        elevation: 6,
                        shadowColor: AppColors.primaryBright.withValues(alpha: 0.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => Get.toNamed(AppRoutes.login),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
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
