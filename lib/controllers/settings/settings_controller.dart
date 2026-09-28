import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../services/D1CM1_login/firebase_auth_service.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_popup.dart';

/// Controller managing application settings, Firebase status, and user preferences.
class SettingsController extends GetxController {
  final RxBool pushNotificationsEnabled = true.obs;
  final RxBool smsAlertsEnabled = true.obs;
  final RxBool biometricAuthEnabled = false.obs;
  final RxBool autoBackupEnabled = true.obs;
  final RxBool isDarkMode = false.obs;

  final String firebaseProjectId = 'rablo-rablo';
  final String appVersion = '1.0.0+1 (Day 5 Clean Build)';

  void togglePushNotifications(bool val) => pushNotificationsEnabled.value = val;
  void toggleSmsAlerts(bool val) => smsAlertsEnabled.value = val;
  void toggleBiometricAuth(bool val) => biometricAuthEnabled.value = val;
  void toggleAutoBackup(bool val) => autoBackupEnabled.value = val;
  void toggleDarkMode(bool val) => isDarkMode.value = val;

  void confirmLogout() {
    CommonPopup.show(
      title: 'Sign Out Confirmation',
      message: 'Are you sure you want to sign out of your gym management session?',
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
        ),
        CommonButton(
          text: 'Sign Out',
          width: 120,
          height: 42,
          backgroundColor: AppColors.error,
          textColor: AppColors.white,
          onPressed: () async {
            Get.back();
            await FirebaseAuthService.instance.signOut();
            Get.offAllNamed(AppRoutes.login);
            Get.snackbar(
              'Signed Out',
              'You have been securely logged out.',
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
            );
          },
        ),
      ],
    );
  }
}
