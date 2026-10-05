import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../controllers/D1CM3_affiliation_scanning/affiliation_scanning_controller.dart';
import '../../widgets/common_button.dart';

/// D1CM3 – Affiliation Scanning Screen.
/// Guides users through linking to a business via QR Scanning, PIN Entry, or File Upload.
class AffiliationScanningScreen extends StatelessWidget {
  const AffiliationScanningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AffiliationScanningController());

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Join Business',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Obx(() {
            if (controller.selectedMode.value == AffiliationInputMode.scanner) {
              return IconButton(
                icon: Icon(
                  controller.isTorchOn.value ? Icons.flash_on : Icons.flash_off,
                  color: controller.isTorchOn.value ? AppColors.primaryBright : Colors.white70,
                ),
                onPressed: controller.toggleTorch,
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 1. DRD Guide to Join Business (Ask for PIN/QR -> Scan or Enter -> Start Journey)
              _buildGuideTimeline(),

              const SizedBox(height: 20),

              // 2. Mode Selection Tabs (Scan QR / Enter PIN / Upload QR)
              _buildModeSelector(controller),

              const SizedBox(height: 24),

              // 3. Dynamic Mode Content
              Obx(() {
                switch (controller.selectedMode.value) {
                  case AffiliationInputMode.scanner:
                    return _buildScannerView(context, controller);
                  case AffiliationInputMode.manualPin:
                  default:
                    return _buildManualPinView(controller);
                }
              }),
            ],
          ),
        ),
      ),
    );
  }

  /// DRD 3-step Guide timeline
  Widget _buildGuideTimeline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF162D33),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildTimelineStep('1', 'Ask for\nPIN/QR', isActive: true),
          _buildTimelineArrow(),
          _buildTimelineStep('2', 'Scan or\nEnter PIN', isActive: true),
          _buildTimelineArrow(),
          _buildTimelineStep('3', 'Start your\nJourney', isActive: false),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(String number, String label, {required bool isActive}) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBright : const Color(0xFF24444C),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: TextStyle(
              color: isActive ? Colors.black : Colors.white70,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.white54,
            fontSize: 11,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineArrow() {
    return const Icon(Icons.arrow_forward_rounded, color: Colors.white24, size: 18);
  }

  /// 2 Input Options Tabs: Scan QR and Enter PIN
  Widget _buildModeSelector(AffiliationScanningController controller) {
    return Obx(() {
      return Row(
        children: [
          _buildTabButton(
            label: 'Scan QR Code',
            icon: Icons.qr_code_scanner,
            isSelected: controller.selectedMode.value == AffiliationInputMode.scanner,
            onTap: () => controller.switchMode(AffiliationInputMode.scanner),
          ),
          const SizedBox(width: 12),
          _buildTabButton(
            label: 'Enter PIN',
            icon: Icons.pin_outlined,
            isSelected: controller.selectedMode.value == AffiliationInputMode.manualPin,
            onTap: () => controller.switchMode(AffiliationInputMode.manualPin),
          ),
        ],
      );
    });
  }

  Widget _buildTabButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1D3F47) : const Color(0xFF132427),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primaryBright : Colors.white10,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primaryBright : Colors.white54, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white60,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Scanner Viewfinder
  Widget _buildScannerView(BuildContext context, AffiliationScanningController controller) {
    return Column(
      children: [
        Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.4), width: 2),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBright.withValues(alpha: 0.15),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Grid background
              Positioned.fill(
                child: Opacity(
                  opacity: 0.15,
                  child: GridPaper(color: AppColors.primaryBright),
                ),
              ),

              // Animated Scanning Laser
              AnimatedBuilder(
                animation: controller.laserAnimation,
                builder: (context, child) {
                  return Positioned(
                    top: 280 * controller.laserAnimation.value,
                    left: 20,
                    right: 20,
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.primaryBright,
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBright.withValues(alpha: 0.8),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              // Corner accents
              Positioned(
                top: 12,
                left: 12,
                child: _buildCorner(isTop: true, isLeft: true),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: _buildCorner(isTop: true, isLeft: false),
              ),
              Positioned(
                bottom: 12,
                left: 12,
                child: _buildCorner(isTop: false, isLeft: true),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                child: _buildCorner(isTop: false, isLeft: false),
              ),

              // Camera icon placeholder
              const Icon(Icons.qr_code_2_rounded, size: 100, color: Colors.white24),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Align the gym QR code inside the frame to scan',
          style: TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 20),

        // Simulate successful scan CTA
        CommonButton(
          text: 'Simulate Scan Business QR',
          backgroundColor: AppColors.primaryBright,
          textColor: Colors.black,
          onPressed: controller.showConfirmationDialog,
        ),
      ],
    );
  }

  Widget _buildCorner({required bool isTop, required bool isLeft}) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        border: Border(
          top: isTop ? const BorderSide(color: AppColors.primaryBright, width: 3) : BorderSide.none,
          bottom: !isTop ? const BorderSide(color: AppColors.primaryBright, width: 3) : BorderSide.none,
          left: isLeft ? const BorderSide(color: AppColors.primaryBright, width: 3) : BorderSide.none,
          right: !isLeft ? const BorderSide(color: AppColors.primaryBright, width: 3) : BorderSide.none,
        ),
      ),
    );
  }

  /// Manual PIN Entry View
  Widget _buildManualPinView(AffiliationScanningController controller) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF14292E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter Business PIN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Enter the 4 or 6-digit unique PIN provided by the fitness centre reception.',
            style: TextStyle(color: Colors.white60, fontSize: 12.5),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: controller.pinInputController,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
            textAlign: TextAlign.center,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(
              hintText: 'BIZ-XXXX',
              hintStyle: const TextStyle(color: Colors.white24, letterSpacing: 2),
              filled: true,
              fillColor: const Color(0xFF1E3C44),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primaryBright, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 22),
          CommonButton(
            text: 'Connect Business',
            backgroundColor: AppColors.primaryBright,
            textColor: Colors.black,
            onPressed: controller.submitPin,
          ),
        ],
      ),
    );
  }
}
