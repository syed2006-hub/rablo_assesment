import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../controllers/D1CM1_login/signup_controller.dart';
import '../../routes/app_routes.dart';
import '../../utils/validators.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_container.dart';
import '../../widgets/common_section_header.dart';
import '../../widgets/common_text_field.dart';

/// D1CM1 – Signup Screen for account registration.
class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SignupController controller = Get.put(SignupController());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CommonAppBar(
        title: AppConstants.appName,
        subtitle: 'D1CM1 – Create Account',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: CommonContainer(
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CommonSectionHeader(
                        title: 'Join Rablo Fitness',
                        subtitle:
                            'Create your account to start managing gym memberships & workouts',
                      ),
                      const SizedBox(height: 16),
                      CommonTextField(
                        controller: controller.nameController,
                        label: 'Full Name',
                        hintText: 'e.g. Rahul Sharma',
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          color: AppColors.grey,
                          size: 20,
                        ),
                        validator: (val) =>
                            Validators.validateRequired(val, 'Full Name'),
                      ),
                      const SizedBox(height: 14),
                      CommonTextField(
                        controller: controller.emailController,
                        label: 'Email Address',
                        hintText: 'member@gym.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.grey,
                          size: 20,
                        ),
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 14),
                      Obx(
                        () => CommonTextField(
                          controller: controller.passwordController,
                          label: 'Password',
                          hintText: 'Create a strong password',
                          obscureText: controller.isPasswordHidden.value,
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                            color: AppColors.grey,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordHidden.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.grey,
                              size: 20,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                          validator: Validators.validatePassword,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Obx(
                        () => CommonTextField(
                          controller: controller.confirmPasswordController,
                          label: 'Confirm Password',
                          hintText: 'Re-enter your password',
                          obscureText: controller.isConfirmPasswordHidden.value,
                          prefixIcon: const Icon(
                            Icons.lock_clock_outlined,
                            color: AppColors.grey,
                            size: 20,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isConfirmPasswordHidden.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.grey,
                              size: 20,
                            ),
                            onPressed:
                                controller.toggleConfirmPasswordVisibility,
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Please confirm your password';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      Obx(
                        () => Row(
                          children: [
                            Checkbox(
                              value: controller.agreeToTerms.value,
                              onChanged: (val) =>
                                  controller.agreeToTerms.value = val ?? false,
                              activeColor: AppColors.primary,
                            ),
                            const Expanded(
                              child: Text(
                                'I agree to the Gym Terms of Service & Privacy Policy',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.dark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Obx(
                        () => CommonButton(
                          text: controller.isLoading.value
                              ? 'Creating Account...'
                              : 'Create Account',
                          isLoading: controller.isLoading.value,
                          onPressed: controller.submitSignup,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.grey,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.toNamed(AppRoutes.login),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.dark,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
