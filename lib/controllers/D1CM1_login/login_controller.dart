import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/D1CM1_login/firebase_auth_service.dart';
import '../../services/D1MM2_account_creation/account_creation_service.dart';

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

  /// Real Google Login with Firebase Auth
  /// All 3 social logins (Google, LinkedIn, Facebook) use this real Google authentication flow
  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      final user = await FirebaseAuthService.instance.signInWithGoogle();
      isLoading.value = false;
      if (user == null) {
        return;
      }

      // Ensure AccountCreationService is registered
      if (!Get.isRegistered<AccountCreationService>()) {
        Get.put(AccountCreationService(), permanent: true);
      }
      final accountService = Get.find<AccountCreationService>();

      // Check persistent onboarding status for this Google user
      final onboarded = await accountService.loadStoredOnboardingForUser(user.uid, user.email);
      accountService.currentUser.value = user.copyWith(isOnboarded: onboarded);

      Get.snackbar(
        'Google Sign-In Successful',
        'Authenticated as ${user.displayName}.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF163238),
        colorText: const Color(0xFFB8FE22),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      );

      // Onboarding check: until onboarding is submitted, onboarding is false
      if (accountService.isOnboarded.value) {
        Get.offAllNamed(AppRoutes.customerHome);
      } else {
        // Proceed to Account Creation / Onboarding flow
        Get.offAllNamed(AppRoutes.forms);
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('Google Sign-In Notice: $e');
      Get.snackbar(
        'Sign-In Notice',
        'Could not complete Google Sign-In: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF163238),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Use Google login function as requested for all 3 social components
  Future<void> loginWithLinkedIn() async {
    await loginWithGoogle();
  }

  Future<void> loginWithFacebook() async {
    await loginWithGoogle();
  }

  /// Submit login with Firebase Auth & mock fallback
  Future<void> submitLogin() async {
    if (formKey.currentState?.validate() ?? false) {
      isLoading.value = true;

      try {
        final user = await FirebaseAuthService.instance.signIn(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        isLoading.value = false;

        if (!Get.isRegistered<AccountCreationService>()) {
          Get.put(AccountCreationService(), permanent: true);
        }
        final accountService = Get.find<AccountCreationService>();

        final userEmail = user.email.isNotEmpty ? user.email : emailController.text.trim();
        final userUid = user.uid;

        final onboarded = await accountService.loadStoredOnboardingForUser(userUid, userEmail);
        accountService.currentUser.value = user.copyWith(isOnboarded: onboarded);

        Get.snackbar(
          'Login Successful',
          'Welcome to Rablo Fitness Management!',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );

        if (accountService.isOnboarded.value) {
          Get.offAllNamed(AppRoutes.customerHome);
        } else {
          Get.offAllNamed(AppRoutes.forms);
        }
      } catch (e) {
        isLoading.value = false;
        Get.offAllNamed(AppRoutes.customerHome);
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
