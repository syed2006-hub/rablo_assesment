import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../controllers/D1MM2_account_creation/account_creation_controller.dart';
import '../../models/D1MM3_membership_planning/membership_plan_model.dart';
import '../../utils/validators.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_container.dart';
import '../../widgets/common_section_header.dart';
import '../../widgets/common_selection_field.dart';
import '../../widgets/common_switch_tile.dart';
import '../../widgets/common_text_field.dart';

/// D1MM2 – Account Creation & Member Registration Form Screen.
class AccountCreationFormScreen extends StatelessWidget {
  const AccountCreationFormScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AccountCreationController controller =
        Get.put(AccountCreationController());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CommonAppBar(
        title: AppConstants.appName,
        subtitle: 'D1MM2 – Member Registration & Account Creation',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CommonSectionHeader(
                      title: 'Register New Member / Business',
                      subtitle:
                          'Capture profile data, membership plan tier, and onboarding details',
                    ),
                    const SizedBox(height: 8),

                    // Account Type Picker
                    CommonContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account Category',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Obx(
                            () => Row(
                              children: controller.accountTypes.map((type) {
                                final isSelected =
                                    controller.selectedAccountType.value == type;
                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4.0),
                                    child: InkWell(
                                      onTap: () => controller
                                          .selectedAccountType.value = type,
                                      borderRadius: BorderRadius.circular(10),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? AppColors.dark
                                              : AppColors.white,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                            color: isSelected
                                                ? AppColors.dark
                                                : AppColors.lightGrey,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            type == 'Individual'
                                                ? '👤 Individual'
                                                : '🏢 Business (D1MM2.2)',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? AppColors.primaryBright
                                                  : AppColors.dark,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Personal & Contact Information
                    CommonContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal & Contact Details',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 14),
                          CommonTextField(
                            controller: controller.fullNameController,
                            label: 'Full Name *',
                            hintText: 'e.g. Vikramaditya Singh',
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
                            label: 'Email Address *',
                            hintText: 'vikram@example.com',
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.grey,
                              size: 20,
                            ),
                            validator: Validators.validateEmail,
                          ),
                          const SizedBox(height: 14),
                          CommonTextField(
                            controller: controller.phoneController,
                            label: 'Phone Number *',
                            hintText: '+91 98765 43210',
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                              color: AppColors.grey,
                              size: 20,
                            ),
                            validator: (val) =>
                                Validators.validateRequired(val, 'Phone Number'),
                          ),
                          const SizedBox(height: 14),
                          Obx(
                            () => CommonSelectionField<String>(
                              label: 'Gender',
                              options: controller.genderOptions,
                              selectedValue: controller.selectedGender.value,
                              onChanged: (val) {
                                if (val != null) {
                                  controller.selectedGender.value = val;
                                }
                              },
                            ),
                          ),
                          const SizedBox(height: 14),
                          CommonTextField(
                            controller: controller.emergencyContactController,
                            label: 'Emergency Contact & Relationship',
                            hintText: '+91 98765 00000 (Parent/Spouse)',
                            prefixIcon: const Icon(
                              Icons.emergency_outlined,
                              color: AppColors.grey,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Membership Plan Selection
                    CommonContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Membership Plan Tier',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Obx(
                            () => CommonSelectionField<MembershipPlanModel>(
                              label: 'Select Plan Tier *',
                              options: controller.availablePlans,
                              selectedValue: controller.selectedPlan.value,
                              optionLabelBuilder: (plan) =>
                                  '${plan.name} (${plan.formattedPrice} / ${plan.billingDuration})',
                              onChanged: (val) {
                                controller.selectedPlan.value = val;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Business Details (Shown if Business Account selected)
                    Obx(
                      () => controller.selectedAccountType.value == 'Business'
                          ? CommonContainer(
                              margin: const EdgeInsets.only(bottom: 14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'D1MM2.2 Business Account Details',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  CommonTextField(
                                    controller:
                                        controller.businessNameController,
                                    label: 'Corporate / Gym Business Name',
                                    hintText: 'e.g. Apex Health Ventures LLP',
                                    prefixIcon: const Icon(
                                      Icons.business_outlined,
                                      color: AppColors.grey,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  CommonTextField(
                                    controller: controller.gstNumberController,
                                    label: 'GST / Tax Identification Number',
                                    hintText: '29AAAAA0000A1Z5',
                                    prefixIcon: const Icon(
                                      Icons.receipt_long_outlined,
                                      color: AppColors.grey,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink(),
                    ),

                    // Health Notes & Medical Disclaimer
                    CommonContainer(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Health Background & Preferences',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.dark,
                            ),
                          ),
                          const SizedBox(height: 14),
                          CommonTextField(
                            controller: controller.healthNotesController,
                            label: 'Medical Considerations / Fitness Goals',
                            hintText:
                                'e.g. Lower back surgery recovery, marathon prep, dietary restrictions...',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Preferences Switches
                    Obx(
                      () => CommonSwitchTile(
                        title: 'Send Welcome Email & Digital Pass',
                        subtitle: 'Sends QR entry badge directly to member email',
                        icon: Icons.mark_email_read_outlined,
                        value: controller.sendWelcomeEmail.value,
                        onChanged: (val) =>
                            controller.sendWelcomeEmail.value = val,
                      ),
                    ),
                    Obx(
                      () => CommonSwitchTile(
                        title: 'Auto-Renew Membership Plan',
                        subtitle: 'Automatically trigger renewal invoice on expiry',
                        icon: Icons.autorenew_rounded,
                        value: controller.autoRenewEnabled.value,
                        onChanged: (val) =>
                            controller.autoRenewEnabled.value = val,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Submit & Reset Actions
                    Obx(
                      () => CommonButton(
                        text: controller.isLoading.value
                            ? 'Creating Member Account...'
                            : 'Submit & Create Member Account',
                        isLoading: controller.isLoading.value,
                        onPressed: controller.submitAccountCreation,
                      ),
                    ),
                    const SizedBox(height: 10),
                    CommonButton(
                      text: 'Clear & Reset Form',
                      backgroundColor: AppColors.backgroundLight,
                      textColor: AppColors.dark,
                      onPressed: controller.resetForm,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
