import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/D1MM10_dashboard_v2/customer_membership_model.dart';
import '../../models/D1MM10_dashboard_v2/rush_hour_model.dart';
import '../../services/D1MM5_my_profile/profile_service.dart';
import '../../constants/app_colors.dart';

class DashboardV2Controller extends GetxController {
  // Membership State
  final membership = CustomerMembershipModel(
    memberName: 'Alex Morgan',
    membershipPlan: 'Session-Based Plan',
    rating: 4.0,
    validityDays: 60,
    sessionsLeft: 35,
    validTillDate: '31 Jan, 2025',
    redemptionsLeft: 1,
    renewalTime: 'mid-night 11:59 PM',
    isActive: true,
    isVerified: true,
  ).obs;

  // Notification count
  final unreadNotifications = 4.obs;

  // Stepper / Onboarding Progress (D1MM10 Stepper)
  final onboardingStep = 1.obs; // 20%
  final showWelcomeProgress = true.obs;

  // Rush hour data points
  final rushHourPoints = <RushHourDataPoint>[].obs;
  final selectedHour = Rxn<RushHourDataPoint>();

  @override
  void onInit() {
    super.onInit();
    rushHourPoints.assignAll(RushHourDataPoint.getSampleData());
    selectedHour.value = rushHourPoints.firstWhereOrNull((p) => p.timeLabel == '8:00') ?? rushHourPoints.first;

    if (Get.isRegistered<ProfileService>()) {
      final prof = ProfileService.to.profile.value;
      if (prof.fullName.isNotEmpty && prof.fullName != 'Manager Name') {
        membership.value = membership.value.copyWith(
          memberName: prof.fullName,
          isVerified: prof.isVerified,
        );
      }
      ever(ProfileService.to.profile, (prof) {
        membership.value = membership.value.copyWith(
          memberName: prof.fullName,
          isVerified: prof.isVerified,
        );
      });
    }
  }

  void toggleVerified() {
    membership.value = membership.value.copyWith(
      isVerified: !membership.value.isVerified,
    );
  }

  void selectHour(RushHourDataPoint point) {
    selectedHour.value = point;
  }

  void buySessions(int count) {
    membership.value = membership.value.copyWith(
      sessionsLeft: membership.value.sessionsLeft + count,
    );
    Get.snackbar(
      'Sessions Added',
      'Successfully purchased $count session(s)!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.slateCard,
      colorText: AppColors.primaryLight,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle_outline, color: AppColors.primaryLight),
    );
  }

  void redeemSession() {
    if (membership.value.redemptionsLeft > 0) {
      membership.value = membership.value.copyWith(
        redemptionsLeft: membership.value.redemptionsLeft - 1,
        sessionsLeft: (membership.value.sessionsLeft > 0) ? membership.value.sessionsLeft - 1 : 0,
      );
      Get.snackbar(
        'Session Redeemed',
        'Your daily workout session has been redeemed! Enjoy your training.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.slateCard,
        colorText: AppColors.cyanAccent,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.fitness_center, color: AppColors.cyanAccent),
      );
    } else {
      Get.snackbar(
        'No Redemptions Left',
        'Daily redemption limit reached. Renews at mid-night 11:59 PM.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.slateCard,
        colorText: AppColors.peakRed,
        margin: const EdgeInsets.all(16),
        icon: const Icon(Icons.error_outline, color: AppColors.peakRed),
      );
    }
  }
}
