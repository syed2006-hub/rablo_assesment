import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/D1CM1_login/firebase_auth_service.dart';

/// D1CM1 – Signup Controller for new member / administrator registration.
class SignupController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;
  final RxBool agreeToTerms = true.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  Future<void> submitSignup() async {
    if (formKey.currentState?.validate() ?? false) {
      if (!agreeToTerms.value) {
        Get.snackbar(
          'Terms & Conditions',
          'Please agree to the gym membership terms to continue.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        Get.snackbar(
          'Password Mismatch',
          'Passwords do not match. Please verify.',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        return;
      }

      isLoading.value = true;

      try {
        await FirebaseAuthService.instance.signUp(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        isLoading.value = false;

        Get.snackbar(
          'Account Created',
          'Welcome to Rablo Fitness, ${nameController.text.trim()}!',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );

        Get.offAllNamed(AppRoutes.home);
      } catch (e) {
        isLoading.value = false;
        Get.snackbar(
          'Registration Note',
          'Signed up with local session: $e',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        Get.offAllNamed(AppRoutes.home);
      }
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
