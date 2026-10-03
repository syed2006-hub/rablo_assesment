import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../controllers/D1CM1_login/login_controller.dart';

/// D1CM1 – Social Authentication Screen.
/// Strictly implements the Figma design with Google, LinkedIn, and Facebook sign-in.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Trainer Photo strictly matching Figma
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

          // Dark gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.5),
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.35, 0.6, 1.0],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Tap background to dismiss / go back
          Positioned.fill(
            child: GestureDetector(
              onTap: () => Get.back(),
              behavior: HitTestBehavior.translucent,
            ),
          ),

          // Bottom Glassmorphic Social Login Container matching Figma design
          SafeArea(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 26, 20, 26),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF22444C),
                        Color(0xFF142B31),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Title: "Hi there!"
                  const Text(
                    'Hi there!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Subtitle: "Sign in to keep things running smoothly."
                  const Text(
                    'Sign in to keep things running smoothly.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Thin divider line
                  Container(
                    height: 1,
                    width: double.infinity,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),

                  const SizedBox(height: 20),

                  // Button 1: Continue with Google
                  _buildSocialButton(
                    onTap: controller.loginWithGoogle,
                    leading: _buildGoogleIcon(),
                    label: 'Continue with Google',
                  ),

                  const SizedBox(height: 12),

                  // Button 2: Continue with LinkedIn
                  _buildSocialButton(
                    onTap: controller.loginWithLinkedIn,
                    leading: _buildLinkedInIcon(),
                    label: 'Continue with LinkedIn',
                  ),

                  const SizedBox(height: 12),

                  // Button 3: Continue with Facebook
                  _buildSocialButton(
                    onTap: controller.loginWithFacebook,
                    leading: _buildFacebookIcon(),
                    label: 'Continue with Facebook',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ],
  ),
);
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required Widget leading,
    required String label,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF284E56),
          foregroundColor: Colors.white,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.white.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            leading,
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Google Colored 'G' Logo
  Widget _buildGoogleIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      padding: const EdgeInsets.all(2),
      child: Center(
        child: Text.rich(
          TextSpan(
            text: 'G',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [
                    Color(0xFF4285F4), // Blue
                    Color(0xFFEA4335), // Red
                    Color(0xFFFBBC05), // Yellow
                    Color(0xFF34A853), // Green
                  ],
                ).createShader(const Rect.fromLTWH(0, 0, 20, 20)),
            ),
          ),
        ),
      ),
    );
  }

  // LinkedIn 'in' Logo
  Widget _buildLinkedInIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: const Color(0xFF0A66C2), // LinkedIn Blue
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          'in',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            fontFamily: 'sans-serif',
          ),
        ),
      ),
    );
  }

  // Facebook 'f' Logo
  Widget _buildFacebookIcon() {
    return Container(
      width: 22,
      height: 22,
      decoration: const BoxDecoration(
        color: Color(0xFF1877F2), // Facebook Blue
        shape: BoxShape.circle,
      ),
      child: const Center(
        child: Text(
          'f',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            fontFamily: 'sans-serif',
          ),
        ),
      ),
    );
  }
}
