import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';

enum ScannerState {
  idle,
  confirming,
  congratulations,
  timeout,
  error,
}

/// Controller managing the Real-time QR Scanner, live viewfinder states,
/// 4-digit code entry, and Figma modal popups.
class ScannerController extends GetxController with GetSingleTickerProviderStateMixin {
  static ScannerController get to => Get.find<ScannerController>();

  final Rx<ScannerState> currentState = ScannerState.idle.obs;
  final RxBool isScanning = true.obs;
  final RxBool isTorchOn = false.obs;
  final RxBool isFrontCamera = false.obs;

  // 4-Digit PIN Code
  final RxString enteredCode = ''.obs;

  // Gym / Business Information
  final RxString businessName = "Gold's Gym Arena".obs;
  final RxString branchName = 'Indiranagar - Platinum Club'.obs;
  final RxString machineId = 'M-4028'.obs;

  // Animation controller for laser scanning beam
  late AnimationController laserAnimationController;
  late Animation<double> laserAnimation;

  bool get _isTestEnvironment {
    try {
      return WidgetsBinding.instance.runtimeType.toString().contains('Test');
    } catch (_) {
      return false;
    }
  }

  @override
  void onInit() {
    super.onInit();
    laserAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    laserAnimation = Tween<double>(begin: 0.05, end: 0.95).animate(
      CurvedAnimation(
        parent: laserAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    if (!_isTestEnvironment) {
      laserAnimationController.repeat(reverse: true);
    }
  }

  @override
  void onClose() {
    laserAnimationController.dispose();
    super.onClose();
  }

  void toggleTorch() {
    isTorchOn.value = !isTorchOn.value;
    Get.snackbar(
      isTorchOn.value ? 'Flashlight On' : 'Flashlight Off',
      isTorchOn.value ? 'Scanner torch activated' : 'Scanner torch turned off',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF163238),
      colorText: isTorchOn.value ? AppColors.primaryBright : Colors.white70,
      duration: const Duration(seconds: 1),
    );
  }

  void flipCamera() {
    isFrontCamera.value = !isFrontCamera.value;
    Get.snackbar(
      'Camera Flipped',
      isFrontCamera.value ? 'Using Front Camera' : 'Using Rear Camera',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF163238),
      colorText: AppColors.primaryBright,
      duration: const Duration(seconds: 1),
    );
  }

  void appendDigit(String digit) {
    if (enteredCode.value.length < 4) {
      enteredCode.value += digit;
      if (enteredCode.value.length == 4) {
        // Trigger verification with entered code
        triggerConfirmationRequired();
      }
    }
  }

  void removeDigit() {
    if (enteredCode.value.isNotEmpty) {
      enteredCode.value =
          enteredCode.value.substring(0, enteredCode.value.length - 1);
    }
  }

  void clearCode() {
    enteredCode.value = '';
    currentState.value = ScannerState.idle;
  }

  int _scanSequence = 0;

  /// Trigger next scan state in sequential order (or randomly) upon scanner detection
  void triggerNextScan() {
    final sequence = [
      ScannerState.confirming,
      ScannerState.congratulations,
      ScannerState.timeout,
      ScannerState.error,
    ];
    final next = sequence[_scanSequence % sequence.length];
    _scanSequence++;

    switch (next) {
      case ScannerState.confirming:
        triggerConfirmationRequired();
        break;
      case ScannerState.congratulations:
        triggerCongratulations();
        break;
      case ScannerState.timeout:
        triggerTimeout();
        break;
      case ScannerState.error:
        triggerSomethingWentWrong();
        break;
      case ScannerState.idle:
        break;
    }
  }

  /// State 1: Confirmation required?
  void triggerConfirmationRequired() {
    currentState.value = ScannerState.confirming;
    enteredCode.value = '4578';
    showConfirmationDialog();
  }

  /// State 2: Congratulations!
  void triggerCongratulations() {
    currentState.value = ScannerState.congratulations;
    enteredCode.value = '1076';
    showCongratulationsDialog();
  }

  /// State 3: Scanning Timeout
  void triggerTimeout() {
    currentState.value = ScannerState.timeout;
    enteredCode.value = '9270';
    showTimeoutDialog();
  }

  /// State 4: Something went wrong!
  void triggerSomethingWentWrong() {
    currentState.value = ScannerState.error;
    enteredCode.value = '9270';
    showErrorDialog();
  }

  /// Random state trigger
  void triggerRandomState() {
    final random = Random().nextInt(4);
    switch (random) {
      case 0:
        triggerConfirmationRequired();
        break;
      case 1:
        triggerCongratulations();
        break;
      case 2:
        triggerTimeout();
        break;
      case 3:
        triggerSomethingWentWrong();
        break;
    }
  }

  /// Upload QR Image simulation
  void uploadQrImage() {
    Get.snackbar(
      'Upload QR Image',
      'Scanning QR code from device gallery...',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF163238),
      colorText: AppColors.primaryBright,
      duration: const Duration(seconds: 2),
    );
    Future.delayed(const Duration(milliseconds: 1200), () {
      triggerCongratulations();
    });
  }

  // ==========================================
  // FIGMA MODAL POPUP DIALOGS
  // ==========================================

  /// Dialog 1: Confirmation required?
  void showConfirmationDialog() {
    if (Get.isDialogOpen ?? false) Get.back();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          decoration: BoxDecoration(
            color: const Color(0xFF163238), // Figma dark slate teal
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primaryBright.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top circular lime green badge with info / check icon
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBright,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.touch_app_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title: Confirmation required?
              const Text(
                'Confirmation required?',
                style: TextStyle(
                  color: AppColors.primaryBright,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 14),

              // Business Name Card matching Figma olive green container
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF284824), // Olive green banner from Figma
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryBright.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryBright,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.fitness_center_rounded,
                          color: Colors.black,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            businessName.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            branchName.value,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Explanatory Text with highlighted business name
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.45,
                  ),
                  children: [
                    const TextSpan(text: 'You are connecting to '),
                    TextSpan(
                      text: businessName.value,
                      style: const TextStyle(
                        color: AppColors.primaryBright,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text: '. Would you like to proceed with the check-in?',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Dual Action Buttons: [Cancel] & [Check-in]
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Colors.white54, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                          currentState.value = ScannerState.idle;
                          enteredCode.value = '';
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B9AB2), // Figma Cyan
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                          // Seamless transition to Congratulations!
                          Future.delayed(const Duration(milliseconds: 200), () {
                            triggerCongratulations();
                          });
                        },
                        child: const Text(
                          'Check-in',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Dialog 2: Congratulations!
  void showCongratulationsDialog() {
    if (Get.isDialogOpen ?? false) Get.back();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          decoration: BoxDecoration(
            color: const Color(0xFF163238),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.primaryBright,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBright.withValues(alpha: 0.25),
                blurRadius: 28,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top circular lime green badge with checkmark
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBright,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    color: Colors.black,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title: Congratulations!
              const Text(
                'Congratulations!',
                style: TextStyle(
                  color: AppColors.primaryBright,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 12),

              // Congratulations Body Text
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    height: 1.45,
                  ),
                  children: [
                    const TextSpan(
                        text: 'You have been successfully checked in with '),
                    TextSpan(
                      text: businessName.value,
                      style: const TextStyle(
                        color: AppColors.primaryBright,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(
                      text:
                          '. Enjoy your workout session! Track your training with ',
                    ),
                    const TextSpan(
                      text: 'Rablo Ecosystem',
                      style: TextStyle(
                        color: AppColors.primaryBright,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),

              const SizedBox(height: 22),

              // Cyan CTA Button: Access Membership Pass
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B9AB2),
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    currentState.value = ScannerState.idle;
                    enteredCode.value = '';
                  },
                  child: const Text(
                    'Access Membership Pass',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Dialog 3: Scanning Timeout
  void showTimeoutDialog() {
    if (Get.isDialogOpen ?? false) Get.back();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          decoration: BoxDecoration(
            color: const Color(0xFF163238),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFFFA000).withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top circular amber badge with hourglass / timer
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFA000), // Amber warning
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.timer_outlined,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title: Scanning Timeout
              const Text(
                'Scanning Timeout',
                style: TextStyle(
                  color: AppColors.primaryBright,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                height: 1,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              const SizedBox(height: 12),

              const Text(
                'The QR code scan has timed out. Please position your camera over the QR code and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 22),

              // Dual Action Buttons: [Cancel] & [Rescan QR Code]
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                              color: Colors.white54, width: 1.5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                          currentState.value = ScannerState.idle;
                          enteredCode.value = '';
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBright,
                          foregroundColor: Colors.black,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Get.back();
                          currentState.value = ScannerState.idle;
                          enteredCode.value = '';
                          Get.snackbar(
                            'Rescanning...',
                            'Scanner active. Align QR code within frame.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF163238),
                            colorText: AppColors.primaryBright,
                            duration: const Duration(seconds: 1),
                          );
                        },
                        child: const Text(
                          'Rescan QR Code',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Dialog 4: Something went wrong!
  void showErrorDialog() {
    if (Get.isDialogOpen ?? false) Get.back();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
          decoration: BoxDecoration(
            color: const Color(0xFF163238),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFBE1E2D).withValues(alpha: 0.7),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFBE1E2D).withValues(alpha: 0.25),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top circular crimson red badge with alert !
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFBE1E2D),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.priority_high_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title: Something went wrong!
              const Text(
                'Something went wrong!',
                style: TextStyle(
                  color: AppColors.primaryBright,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                height: 1,
                color: Colors.white24,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              const SizedBox(height: 12),

              const Text(
                'A connection error occurred. Check your internet connection or verify the QR code and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 22),

              // Wide Lime Retry Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBright,
                    foregroundColor: Colors.black,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Get.back();
                    currentState.value = ScannerState.idle;
                    enteredCode.value = '';
                    Get.snackbar(
                      'Retrying Scanner',
                      'Scanner restarted. Ready to scan.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF163238),
                      colorText: AppColors.primaryBright,
                      duration: const Duration(seconds: 1),
                    );
                  },
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
