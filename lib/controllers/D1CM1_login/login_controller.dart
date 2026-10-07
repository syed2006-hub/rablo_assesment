import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../routes/app_routes.dart';
import '../../services/D1CM1_login/firebase_auth_service.dart';
import '../../services/D1CM2_account_creation/account_creation_service.dart';
import '../../services/firebase/customer_firebase_service.dart';
import '../../utils/validators.dart';
import '../../widgets/form_feedback_widgets.dart';

/// D1CM1 – Login Controller managing authentication, validation,
/// session credential storage, duplicate submission protection, and real-time Firebase profile synchronization.
class LoginController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController =
      TextEditingController(text: 'member@gym.com');
  final TextEditingController passwordController =
      TextEditingController(text: 'Password123!');

  final RxBool isLoading = false.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isPasswordHidden = true.obs;
  final RxString loginErrorMessage = ''.obs;

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  /// Real Google Login with Firebase Auth and real-time Firestore sync
  Future<void> loginWithGoogle() async {
    if (isLoading.value || isSubmitting.value) return;

    try {
      isLoading.value = true;
      isSubmitting.value = true;
      loginErrorMessage.value = '';

      final user = await FirebaseAuthService.instance.signInWithGoogle();
      isLoading.value = false;
      isSubmitting.value = false;

      if (user == null) {
        return;
      }

      // 1. Store login credentials in CustomerFirebaseService & local cache
      if (Get.isRegistered<CustomerFirebaseService>()) {
        await CustomerFirebaseService.to.saveLoginCredentials(
          uid: user.uid,
          email: user.email,
          displayName: user.displayName,
          photoUrl: user.photoUrl,
        );
      }

      // 2. Sync with AccountCreationService for test/legacy compatibility
      if (!Get.isRegistered<AccountCreationService>()) {
        Get.put(AccountCreationService(), permanent: true);
      }
      final accountService = Get.find<AccountCreationService>();
      final onboarded = await accountService.loadStoredOnboardingForUser(user.uid, user.email);
      accountService.currentUser.value = user.copyWith(isOnboarded: onboarded);

      AppFeedback.showSuccess(
        title: 'Google Sign-In Successful',
        message: 'Authenticated as ${user.displayName.isNotEmpty ? user.displayName : user.email}.',
      );

      // 3. Check onboarding and navigate accordingly
      _navigatePostLogin(onboarded: onboarded);
    } catch (e) {
      isLoading.value = false;
      isSubmitting.value = false;
      debugPrint('Google Sign-In Notice: $e');
      loginErrorMessage.value = 'Could not complete Google Sign-In: $e';
      AppFeedback.showError(
        title: 'Sign-In Error',
        message: 'Could not complete Google Sign-In. Please try again.',
        onRetry: loginWithGoogle,
      );
    }
  }

  /// Use Google login function for all 3 social components
  Future<void> loginWithLinkedIn() async {
    await loginWithGoogle();
  }

  Future<void> loginWithFacebook() async {
    await loginWithGoogle();
  }

  /// Submit login with Firebase Auth & Firestore session storage
  Future<void> submitLogin() async {
    // 1. Duplicate submission guard
    if (isSubmitting.value) return;

    // 2. Input validation checks
    final emailError = Validators.validateEmail(emailController.text);
    if (emailError != null) {
      loginErrorMessage.value = emailError;
      AppFeedback.showError(title: 'Invalid Email', message: emailError);
      return;
    }

    final passwordError = Validators.validatePassword(passwordController.text);
    if (passwordError != null) {
      loginErrorMessage.value = passwordError;
      AppFeedback.showError(title: 'Invalid Password', message: passwordError);
      return;
    }

    if (formKey.currentState?.validate() ?? true) {
      isLoading.value = true;
      isSubmitting.value = true;
      loginErrorMessage.value = '';

      try {
        final user = await FirebaseAuthService.instance.signIn(
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
            displayName: user.displayName,
          );
        }

        // 2. Sync with AccountCreationService
        if (!Get.isRegistered<AccountCreationService>()) {
          Get.put(AccountCreationService(), permanent: true);
        }
        final accountService = Get.find<AccountCreationService>();
        final onboarded = await accountService.loadStoredOnboardingForUser(userUid, userEmail);
        accountService.currentUser.value = user.copyWith(isOnboarded: onboarded);

        AppFeedback.showSuccess(
          title: 'Login Successful',
          message: 'Welcome to Rablo Fitness!',
        );

        _navigatePostLogin(onboarded: onboarded);
      } catch (e) {
        isLoading.value = false;
        isSubmitting.value = false;
        debugPrint('[LoginController] Authentication error: $e');
        loginErrorMessage.value = 'Sign-in failed. Please verify your credentials.';
        AppFeedback.showError(
          title: 'Sign-In Failed',
          message: 'Unable to sign in. Please verify your email and password.',
          onRetry: submitLogin,
        );
      }
    }
  }

  void _navigatePostLogin({required bool onboarded}) {
    if (!onboarded) {
      Get.offAllNamed(AppRoutes.forms);
      return;
    }

    // Direct user to customerHome shell where Dashboard V1 is accessible via bottom navigation bar
    Get.offAllNamed(AppRoutes.customerHome);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
