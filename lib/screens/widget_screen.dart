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
import '../widgets/common_detail_row.dart';
import '../widgets/common_list_item.dart';
import '../widgets/common_search_field.dart';
import '../widgets/common_section_header.dart';
import '../widgets/common_selection_field.dart';
import '../widgets/common_stat_card.dart';
import '../widgets/common_status_chip.dart';
import '../widgets/common_switch_tile.dart';
import '../widgets/common_tab_selector.dart';
import '../widgets/common_text_field.dart';

/// Front screen showcasing all reusable common components for Day 4 & Day 5.
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
            icon: const Icon(Icons.dashboard_rounded, color: AppColors.primaryBright),
            tooltip: 'Go to Main App',
            onPressed: () => Get.offAllNamed(AppRoutes.home),
          ),
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
              constraints: const BoxConstraints(maxWidth: 700),
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
                            hintText: 'Enter secret passcode',
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
                        'Dropdown selector component conforming to app theme styling.',
                  ),
                  CommonContainer(
                    child: Obx(
                      () => CommonSelectionField<String>(
                        label: 'Membership Package Tier',
                        hintText: 'Choose membership duration',
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
                        'Elevated button supporting active, disabled, loading, and custom color variants.',
                  ),
                  CommonContainer(
                    child: Column(
                      children: [
                        CommonButton(
                          text: 'Primary Action Button',
                          onPressed: () {
                            Get.snackbar(
                              'Action Clicked',
                              'Primary button trigger activated.',
                              snackPosition: SnackPosition.BOTTOM,
                              margin: const EdgeInsets.all(16),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Obx(
                          () => CommonButton(
                            text: controller.isButtonLoading.value
                                ? 'Processing Request...'
                                : 'Toggle Loading State Button',
                            isLoading: controller.isButtonLoading.value,
                            backgroundColor: AppColors.dark,
                            textColor: AppColors.primaryBright,
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
                        'Standardized modal alert dialog with customizable actions.',
                  ),
                  CommonContainer(
                    child: CommonButton(
                      text: 'Trigger CommonPopup Dialog',
                      backgroundColor: AppColors.veryLightGreen,
                      textColor: AppColors.dark,
                      onPressed: controller.showPopupDemo,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 6. CommonStatCard (Day 5)
                  const CommonSectionHeader(
                    title: '6. CommonStatCard (Day 5 Metric KPI)',
                    subtitle:
                        'Metric card with trend indicators, icons, and values for Dashboards & Profiles.',
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: CommonStatCard(
                          title: 'Active Members',
                          value: '1,248',
                          changeText: '+8.4%',
                          isPositive: true,
                          icon: Icons.people_alt_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CommonStatCard(
                          title: 'Expiring This Week',
                          value: '34',
                          changeText: '-12%',
                          isPositive: false,
                          icon: Icons.timer_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 7. CommonStatusChip (Day 5)
                  const CommonSectionHeader(
                    title: '7. CommonStatusChip (Day 5 Status Badges)',
                    subtitle:
                        'Dynamic status pill with automatic color mapping for Active, Expiring, and Inactive.',
                  ),
                  CommonContainer(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: const [
                        CommonStatusChip(status: 'Active'),
                        CommonStatusChip(status: 'Expiring'),
                        CommonStatusChip(status: 'Inactive'),
                        CommonStatusChip(status: 'VIP'),
                        CommonStatusChip(status: 'Pending'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 8. CommonListItem (Day 5)
                  const CommonSectionHeader(
                    title: '8. CommonListItem (Day 5 List Tile)',
                    subtitle:
                        'Modular list row with leading avatar, titles, subtitles, and trailing chips.',
                  ),
                  CommonListItem(
                    title: 'Sophia Martinez',
                    subtitle: 'Gold Quarterly Plan • +91 91234 56789',
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.dark,
                      radius: 18,
                      child: Text('S', style: TextStyle(color: AppColors.primaryBright)),
                    ),
                    trailing: const CommonStatusChip(status: 'Active'),
                    onTap: () {},
                  ),
                  CommonListItem(
                    title: 'Rahul Sharma',
                    subtitle: 'Standard Monthly • Expiring in 3 days',
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.dark,
                      radius: 18,
                      child: Text('R', style: TextStyle(color: AppColors.primaryBright)),
                    ),
                    trailing: const CommonStatusChip(status: 'Expiring'),
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),

                  // 9. CommonSearchField & TabSelector (Day 5)
                  const CommonSectionHeader(
                    title: '9. CommonSearchField & CommonTabSelector',
                    subtitle:
                        'Input search bar with clear button and horizontal pill tab filter.',
                  ),
                  CommonContainer(
                    child: Column(
                      children: [
                        CommonSearchField(
                          controller: controller.searchController,
                        ),
                        const SizedBox(height: 10),
                        Obx(
                          () => CommonTabSelector(
                            tabs: controller.demoTabs,
                            selectedIndex: controller.selectedDemoTabIndex.value,
                            onTabSelected: controller.onDemoTabSelected,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 10. CommonDetailRow (Day 5)
                  const CommonSectionHeader(
                    title: '10. CommonDetailRow (Day 5 Key-Value Row)',
                    subtitle:
                        'Clean labeled rows for detail screens and profile views.',
                  ),
                  CommonContainer(
                    child: Column(
                      children: const [
                        CommonDetailRow(
                          label: 'Membership Tier',
                          value: 'Platinum VIP Annual',
                          icon: Icons.military_tech_rounded,
                        ),
                        CommonDetailRow(
                          label: 'Check-in Time',
                          value: 'Today, 08:30 AM',
                          icon: Icons.access_time_rounded,
                        ),
                        CommonDetailRow(
                          label: 'Verification Status',
                          value: 'Biometric Verified',
                          icon: Icons.fingerprint_rounded,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 11. CommonSwitchTile (Day 5)
                  const CommonSectionHeader(
                    title: '11. CommonSwitchTile (Day 5 Setting Switch)',
                    subtitle:
                        'Interactive switch row with branding colors for preference screens.',
                  ),
                  Obx(
                    () => CommonSwitchTile(
                      title: 'Real-Time Check-In Alerts',
                      subtitle: 'Trigger instant notifications on turnstile entry',
                      icon: Icons.notifications_active_rounded,
                      value: controller.switchValue.value,
                      onChanged: controller.onSwitchChanged,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
