import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../controllers/settings/settings_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_container.dart';
import '../../widgets/common_detail_row.dart';
import '../../widgets/common_section_header.dart';
import '../../widgets/common_switch_tile.dart';

/// Settings Screen for system configuration, Firebase connection, and preferences.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.put(SettingsController());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CommonAppBar(
        title: AppConstants.appName,
        subtitle: 'System Settings & Cloud Sync',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 680),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Firebase Cloud Sync Status Card
                  const CommonSectionHeader(
                    title: 'Firebase & Cloud Status',
                    subtitle: 'Day 5 Connected Cloud Services',
                  ),
                  CommonContainer(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF8E1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.cloud_done_rounded,
                                color: Color(0xFFF57C00),
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Text(
                                        'Firebase Backend',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.dark,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.veryLightGreen,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          '● ACTIVE',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF33691E),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Project ID: ${controller.firebaseProjectId}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        CommonDetailRow(
                          label: 'Authentication Service',
                          value: 'Firebase Auth (v6.7.0)',
                          icon: Icons.vpn_key_outlined,
                        ),
                        CommonDetailRow(
                          label: 'Cloud Core Service',
                          value: 'Firebase Core (v4.15.0)',
                          icon: Icons.hub_outlined,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Notification Preferences
                  const CommonSectionHeader(
                    title: 'Notifications & Alerts',
                    subtitle: 'Configure automated member communication',
                  ),
                  Obx(
                    () => CommonSwitchTile(
                      title: 'Push Notifications',
                      subtitle:
                          'Real-time check-in alerts and front-desk notifications',
                      icon: Icons.notifications_active_outlined,
                      value: controller.pushNotificationsEnabled.value,
                      onChanged: controller.togglePushNotifications,
                    ),
                  ),
                  Obx(
                    () => CommonSwitchTile(
                      title: 'SMS Expiry Reminders',
                      subtitle:
                          'Send SMS when membership enters expiring status',
                      icon: Icons.sms_outlined,
                      value: controller.smsAlertsEnabled.value,
                      onChanged: controller.toggleSmsAlerts,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 3. Security & App Preferences
                  const CommonSectionHeader(
                    title: 'Security & App Interface',
                    subtitle: 'Local device locks and appearance settings',
                  ),
                  Obx(
                    () => CommonSwitchTile(
                      title: 'Biometric App Lock',
                      subtitle:
                          'Require Fingerprint / FaceID to access member data',
                      icon: Icons.fingerprint_rounded,
                      value: controller.biometricAuthEnabled.value,
                      onChanged: controller.toggleBiometricAuth,
                    ),
                  ),
                  Obx(
                    () => CommonSwitchTile(
                      title: 'Auto Cloud Backup',
                      subtitle:
                          'Continuously sync offline ledger entries to cloud',
                      icon: Icons.backup_outlined,
                      value: controller.autoBackupEnabled.value,
                      onChanged: controller.toggleAutoBackup,
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 4. App Information
                  const CommonSectionHeader(
                    title: 'Application Information',
                    subtitle: 'Build metadata and design specifications',
                  ),
                  CommonContainer(
                    child: Column(
                      children: [
                        CommonDetailRow(
                          label: 'App Name',
                          value: AppConstants.appName,
                          icon: Icons.fitness_center_rounded,
                        ),
                        CommonDetailRow(
                          label: 'Version & Build',
                          value: controller.appVersion,
                          icon: Icons.info_outline_rounded,
                        ),
                        CommonDetailRow(
                          label: 'Design System',
                          value: 'Rablo Clean Fitness (M3)',
                          icon: Icons.palette_outlined,
                        ),
                        CommonDetailRow(
                          label: 'Architecture',
                          value: 'GetX MVC + Modular Folders',
                          icon: Icons.architecture_rounded,
                          showDivider: false,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 5. Component Showcase Navigation
                  CommonButton(
                    text: '🎨 Explore Reusable Component Set',
                    backgroundColor: AppColors.dark,
                    textColor: AppColors.primaryBright,
                    onPressed: () => Get.toNamed(AppRoutes.widgets),
                  ),
                  const SizedBox(height: 12),

                  // 6. Sign Out Button
                  CommonButton(
                    text: '🚪 Sign Out',
                    backgroundColor: AppColors.error,
                    textColor: AppColors.white,
                    onPressed: controller.confirmLogout,
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
