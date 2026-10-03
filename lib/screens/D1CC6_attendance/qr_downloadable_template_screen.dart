import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';

/// D1CC6 – QR Downloadable Template Screen (Digital Access Pass).
/// Strictly implements Figma `QR Downloadable Template.png`.
class QrDownloadableTemplateScreen extends StatelessWidget {
  const QrDownloadableTemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slateScaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Digital Access Pass',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            onPressed: () {
              Get.snackbar(
                'Share QR Pass',
                'Access Pass link & PIN copied to clipboard!',
                backgroundColor: AppColors.slateCard,
                colorText: AppColors.primaryLight,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        child: Column(
          children: [
            const Text(
              'Scan & Connect',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Scan the QR code or enter the PIN Manually.',
              style: TextStyle(color: AppColors.greyMuted, fontSize: 13),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),
            Container(height: 1, color: AppColors.slateBorder),
            const SizedBox(height: 12),

            const Text(
              'Fitness Centre Rablo',
              style: TextStyle(
                color: AppColors.primaryLight,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Contact: +91 98765 43210',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),

            const SizedBox(height: 20),

            // Main QR Container Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: AppColors.slateCard,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.slateBorder, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBright.withValues(alpha: 0.15),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Image.asset(
                        'assets/images/qr_template.png',
                        fit: BoxFit.contain,
                        errorBuilder: (ctx, err, stack) => const Icon(
                          Icons.qr_code_2_rounded,
                          size: 180,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.slateCardDark,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.slateBorder),
                    ),
                    child: const Text(
                      'ID: 123456',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'How to Use?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildStepItem(
                        icon: Icons.upload_rounded,
                        line1: 'Share Your',
                        line2: 'QR or PIN',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward_ios, color: AppColors.primaryLight, size: 14),
                      ),
                      _buildStepItem(
                        icon: Icons.qr_code_scanner,
                        line1: 'Ask to Scan',
                        line2: 'QR or PIN',
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.arrow_forward_ios, color: AppColors.primaryLight, size: 14),
                      ),
                      _buildStepItem(
                        icon: Icons.how_to_reg,
                        line1: 'Check Your',
                        line2: 'Check-Ins',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text('Powered By', style: TextStyle(color: AppColors.greyMuted, fontSize: 11)),
                  const SizedBox(height: 2),
                  const Text(
                    'Membes App',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Live Simulation Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBright,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 4,
                ),
                onPressed: () => _simulateTurnstileCheckIn(context),
                icon: const Icon(Icons.check_circle_outline, color: Colors.black),
                label: const Text(
                  'Simulate Turnstile Pass',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepItem({
    required IconData icon,
    required String line1,
    required String line2,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.slateCardLight,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.slateBorder),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(height: 6),
        Text(line1, style: const TextStyle(color: Colors.white70, fontSize: 9.5)),
        Text(
          line2,
          style: const TextStyle(
            color: AppColors.primaryLight,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _simulateTurnstileCheckIn(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.slateCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.primaryLight, width: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: Color(0xFF1E3A20),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.verified, color: AppColors.primaryBright, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Access Granted!',
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Turnstile #01 unlocked. Check-in recorded at 5:13 PM. Enjoy your workout!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBright,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
