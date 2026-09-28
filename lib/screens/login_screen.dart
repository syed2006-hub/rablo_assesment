import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../controllers/login_controller.dart';
import '../routes/app_routes.dart';
import '../utils/validators.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_button.dart';
import '../widgets/common_container.dart';
import '../widgets/common_section_header.dart';
import '../widgets/common_text_field.dart';

/// D1CM1 – Login Screen
/// Implemented using exclusively common widgets with mock validation flow.
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CommonAppBar(
        title: AppConstants.appName,
        subtitle: 'D1CM1 – Member Authentication',
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: CommonContainer(
                child: Form(
                  key: controller.formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CommonSectionHeader(
                        title: 'Welcome Back',
                        subtitle:
                            'Mock validation enabled • Submit to transition to Widget Screen',
                      ),
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
                      Obx(
                        () => CommonTextField(
                          controller: controller.passwordController,
                          label: 'Password',
                          hintText: 'Enter your password',
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
                      const SizedBox(height: 24),
                      Obx(
                        () => CommonButton(
                          text: controller.isLoading.value
                              ? 'Validating...'
                              : 'Sign In (Mock Validation)',
                          isLoading: controller.isLoading.value,
                          onPressed: controller.submitLogin,
                        ),
                      ),
                      const SizedBox(height: 12),
                      CommonButton(
                        text: 'Skip to Widget Screen',
                        backgroundColor: AppColors.backgroundLight,
                        textColor: AppColors.dark,
                        onPressed: () => Get.offNamed(AppRoutes.widgets),
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
