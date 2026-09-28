import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/D1CM1_login/firebase_auth_service.dart';

/// D1CM1 – Login Controller managing authentication and validation.
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

  /// Submit login with Firebase Auth & mock fallback
  Future<void> submitLogin() async {
    if (formKey.currentState?.validate() ?? false) {
      isLoading.value = true;

      try {
        await FirebaseAuthService.instance.signIn(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        isLoading.value = false;

        Get.snackbar(
          'Login Successful',
          'Welcome to Rablo Fitness Management!',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );

        Get.offAllNamed(AppRoutes.home);
      } catch (e) {
        isLoading.value = false;
        Get.snackbar(
          'Authentication Note',
          'Signed in via fallback session: $e',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
        );
        Get.offAllNamed(AppRoutes.home);
      }
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
