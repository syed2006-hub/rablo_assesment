import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/D1CM1_login/user_model.dart';
import '../../routes/app_routes.dart';
import '../../services/D1CM1_login/firebase_auth_service.dart';
import '../../services/D1CM2_account_creation/account_creation_service.dart';
import '../../services/firebase/customer_firebase_service.dart';
import '../../utils/validators.dart';
import '../../widgets/form_feedback_widgets.dart';

/// D1CM1 – Signup Controller for new member / administrator registration with validation & duplicate protection.
class SignupController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxBool isConfirmPasswordHidden = true.obs;
  final RxBool agreeToTerms = true.obs;
  final RxString signupErrorMessage = ''.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  Future<void> submitSignup() async {
    // 1. Duplicate submission guard
    if (isSubmitting.value) return;

    // 2. Form validation
    final nameErr = Validators.validateRequired(nameController.text, 'Full Name');
    if (nameErr != null) {
      AppFeedback.showError(title: 'Required Field', message: nameErr);
      return;
    }

    final emailErr = Validators.validateEmail(emailController.text);
    if (emailErr != null) {
      AppFeedback.showError(title: 'Invalid Email', message: emailErr);
      return;
    }

    final passErr = Validators.validatePassword(passwordController.text);
    if (passErr != null) {
      AppFeedback.showError(title: 'Weak Password', message: passErr);
      return;
    }

    final matchErr = Validators.validateMatch(
      confirmPasswordController.text,
      passwordController.text,
      'Passwords',
    );
    if (matchErr != null) {
      AppFeedback.showError(title: 'Password Mismatch', message: matchErr);
      return;
    }

    if (!agreeToTerms.value) {
      AppFeedback.showError(
        title: 'Terms Required',
        message: 'Please accept the gym membership terms to continue.',
      );
      return;
    }

    if (formKey.currentState?.validate() ?? true) {
      isLoading.value = true;
      isSubmitting.value = true;
      signupErrorMessage.value = '';

      try {
        final user = await FirebaseAuthService.instance.signUp(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        isLoading.value = false;
        isSubmitting.value = false;

        final userEmail = user.email.isNotEmpty ? user.email : emailController.text.trim();
        final userUid = user.uid;

        // 1. Store login credentials in CustomerFirebaseService
        if (Get.isRegistered<CustomerFirebaseService>()) {
          await CustomerFirebaseService.to.saveLoginCredentials(
            uid: userUid,
            email: userEmail,
            displayName: nameController.text.trim(),
          );
        }

        // 2. Set user as un-onboarded in AccountCreationService
        if (!Get.isRegistered<AccountCreationService>()) {
          Get.put(AccountCreationService(), permanent: true);
        }
        final accountService = Get.find<AccountCreationService>();
        accountService.currentUser.value = UserModel(
          uid: userUid,
          email: userEmail,
          displayName: nameController.text.trim(),
          role: 'Customer',
          createdAt: DateTime.now(),
          isOnboarded: false,
        );
        accountService.isOnboarded.value = false;

        AppFeedback.showSuccess(
          title: 'Account Created',
          message: 'Welcome to Rablo Fitness, ${nameController.text.trim()}!',
        );

        // Newly registered user must complete onboarding
        Get.offAllNamed(AppRoutes.forms);
      } catch (e) {
        isLoading.value = false;
        isSubmitting.value = false;
        debugPrint('[SignupController] Registration error: $e');
        signupErrorMessage.value = 'Registration failed: $e';
        AppFeedback.showError(
          title: 'Registration Failed',
          message: 'Could not create account. Please check your details and try again.',
          onRetry: submitSignup,
        );
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
