import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../controllers/widget_controller.dart';
import '../routes/app_routes.dart';
import '../utils/validators.dart';
import '../widgets/common_app_bar.dart';
import '../widgets/common_button.dart';
import '../widgets/common_container.dart';
import '../widgets/common_section_header.dart';
import '../widgets/common_selection_field.dart';
import '../widgets/common_text_field.dart';

/// Front screen showcasing all reusable common components.
/// Uses solely centralized common widgets without any inline helper build methods.
class WidgetScreen extends StatelessWidget {
  const WidgetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final WidgetController controller = Get.put(WidgetController());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CommonAppBar(
        title: AppConstants.appName,
        subtitle: 'Reusable Components Showcase',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.white),
            tooltip: 'Back to Login (Mock Validation)',
            onPressed: () => Get.offNamed(AppRoutes.login),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. CommonContainer
                  const CommonSectionHeader(
                    title: '1. CommonContainer',
                    subtitle:
                        'Reusable structured card with standardized border, radius, and elevation.',
                  ),
                  const CommonContainer(
                    child: Text(
                      'CommonContainer provides centralized surface styling, margin, padding, border radius, and elevation across all fitness modules.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.dark,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. CommonTextField
                  const CommonSectionHeader(
                    title: '2. CommonTextField',
                    subtitle:
                        'Standardized input field with labels, hints, icons, validation, and obscure-text toggle.',
                  ),
                  CommonContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonTextField(
                          controller: controller.nameController,
                          label: 'Full Name',
                          hintText: 'Enter member name',
                          prefixIcon: const Icon(
                            Icons.person_outline_rounded,
                            color: AppColors.grey,
                            size: 20,
                          ),
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
                            hintText: 'Enter password',
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
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. CommonSelectionField
                  const CommonSectionHeader(
                    title: '3. CommonSelectionField',
                    subtitle:
                        'Reusable dropdown selection widget matching centralized input field styling.',
                  ),
                  CommonContainer(
                    child: Obx(
                      () => CommonSelectionField<String>(
                        label: 'Membership Plan',
                        hintText: 'Select plan',
                        options: controller.planOptions,
                        selectedValue: controller.selectedPlan.value,
                        onChanged: controller.onPlanChanged,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 4. CommonButton
                  const CommonSectionHeader(
                    title: '4. CommonButton',
                    subtitle:
                        'Elevated button supporting active, loading spinner, and disabled states.',
                  ),
                  CommonContainer(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CommonButton(
                          text: 'Primary Button (Active)',
                          onPressed: () {
                            Get.snackbar(
                              'CommonButton Pressed',
                              'Standard primary button triggered successfully.',
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => CommonButton(
                            text: controller.isButtonLoading.value
                                ? 'Processing...'
                                : 'Toggle Loading State (Interactive)',
                            isLoading: controller.isButtonLoading.value,
                            backgroundColor: AppColors.primaryBright,
                            onPressed: controller.toggleButtonLoading,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const CommonButton(
                          text: 'Disabled Button State',
                          isEnabled: false,
                          onPressed: null,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5. CommonPopup
                  const CommonSectionHeader(
                    title: '5. CommonPopup',
                    subtitle:
                        'Reusable modal dialog helper supporting title, message, and customizable action buttons.',
                  ),
                  CommonContainer(
                    child: CommonButton(
                      text: 'Open CommonPopup Dialog',
                      backgroundColor: AppColors.dark,
                      textColor: AppColors.white,
                      onPressed: controller.showPopupDemo,
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
