import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../routes/app_routes.dart';

/// GetX controller managing authentication flow and mock validation.
class LoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController =
      TextEditingController(text: 'member@gym.com');
  final TextEditingController passwordController =
      TextEditingController(text: 'Password123!');

  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  /// Performs mock validation and on success transitions to the widget screen.
  Future<void> submitLogin() async {
    if (formKey.currentState?.validate() ?? false) {
      isLoading.value = true;

      // Simulate mock validation delay
      await Future.delayed(const Duration(milliseconds: 600));

      isLoading.value = false;

      Get.snackbar(
        'Mock Validation Passed',
        'Credentials validated successfully. Navigating to Widget Screen...',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );

      // Transition to the widget showcase screen
      Get.offNamed(AppRoutes.widgets);
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
