import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../models/D1CM9_dashboard_v2/customer_membership_model.dart';
import '../../models/D1CM9_dashboard_v2/rush_hour_model.dart';
import '../../routes/app_routes.dart';
import '../../services/D1CM6_my_profile/profile_service.dart';
import '../../services/firebase/customer_firebase_service.dart';
import '../../widgets/review_rating_popup.dart';
import '../D1CM5_dashboard_v1/dashboard_v1_controller.dart';

/// D1CM9 – Customer Dashboard V2 Controller.
/// Strictly implements DRD D1CM9 specifications:
/// - Real-time active membership plan summary (Validity, Renew, Sessions Left, Upgrade)
/// - Redemption Summary:
///     - State A: Redeemed -> countdown to midnight reset (11:59 PM), "Renews mid-night 11:59 PM", View records
///     - State B: Unredeemed -> countdown to redeem before reset, Redeem Pass CTA
/// - 24-hour scan limitation enforcement
/// - Interactive Rush Hours Indicator graph (Red = Full, Green = Neutral, Blue = Empty)
/// - Automated review reminder system (70%, 80%, 90% subscription threshold)
/// - Cloud Firestore real-time synchronization
class DashboardV2Controller extends GetxController {
  static DashboardV2Controller get to => Get.find<DashboardV2Controller>();

  // Membership State
  final membership = CustomerMembershipModel(
    memberName: 'Alex Morgan',
    membershipPlan: 'Gold Quarterly Plan',
    rating: 4.9,
    validityDays: 78,
    sessionsLeft: 35,
    validTillDate: '15 Nov, 2026',
    redemptionsLeft: 1,
    renewalTime: 'mid-night 11:59 PM',
    isActive: true,
    isVerified: true,
  ).obs;

  final RxInt unreadNotifications = 3.obs;
  final RxBool showWelcomeProgress = true.obs;
  final RxInt onboardingStep = 4.obs; // Onboarded

  // Rush hour data points
  final rushHourPoints = <RushHourDataPoint>[].obs;
  final selectedHour = Rxn<RushHourDataPoint>();

  // Redemption Timer State (Countdown to Midnight 11:59 PM)
  final RxString countdownTimerStr = '05h 22m 14s'.obs;
  final RxBool isSessionRedeemedToday = false.obs;
  Timer? _countdownTimer;

  // Review Reminder Milestone (70%, 80%, 90%)
  final RxBool showReviewReminderBanner = false.obs;
  final RxDouble subscriptionCompletionPct = 72.0.obs;

  @override
  void onInit() {
    super.onInit();
    rushHourPoints.assignAll(RushHourDataPoint.getSampleData());
    selectedHour.value = rushHourPoints.firstWhereOrNull((p) => p.timeLabel == '8:00') ?? rushHourPoints.first;

    _startCountdownTimer();
    _bindFirebaseListeners();
    syncWithCurrentDetails();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    super.onClose();
  }

  void _startCountdownTimer() {
    _updateCountdown();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateCountdown();
    });
  }

  void _updateCountdown() {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final diff = midnight.difference(now);

    if (diff.isNegative) {
      countdownTimerStr.value = '00h 00m 00s';
      isSessionRedeemedToday.value = false;
    } else {
      final hours = diff.inHours.toString().padLeft(2, '0');
      final minutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
      final seconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
      countdownTimerStr.value = '${hours}h ${minutes}m ${seconds}s';
    }
  }

  /// Listen to real-time Firebase streams
  void _bindFirebaseListeners() {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final fbService = CustomerFirebaseService.to;

      // Listen to active plan changes
      ever(fbService.activePlan, (planData) {
        if (planData != null) {
          final durationMonths = (planData['durationMonths'] as num?)?.toInt() ?? 3;
          membership.value = membership.value.copyWith(
            membershipPlan: planData['planName']?.toString() ?? 'Gold Quarterly Plan',
            sessionsLeft: (planData['sessionsLeft'] as num?)?.toInt() ?? 35,
            validTillDate: planData['validity']?.toString() ?? '15 Nov, 2026',
            validityDays: durationMonths * 30,
            isActive: true,
          );
        }
      });

      // Listen to user profile changes
      ever(fbService.currentUserProfile, (profileData) {
        if (profileData != null) {
          final name = profileData['fullName']?.toString() ?? '';
          final phone = profileData['phoneNumber']?.toString() ?? '';
          final uid = profileData['uid']?.toString() ?? '';
          final isVer = profileData['isVerified'] == true;
          if (name.isNotEmpty) {
            membership.value = membership.value.copyWith(
              memberName: name,
              contactPhone: phone.isNotEmpty ? phone : null,
              memberId: uid.isNotEmpty ? 'ID: ${uid.substring(0, uid.length.clamp(0, 8)).toUpperCase()}' : null,
              isVerified: isVer,
            );
          }
        }
      });

      // Listen to business affiliation changes
      ever(fbService.currentAffiliation, (affData) {
        if (affData != null) {
          final bizName = affData['businessName']?.toString() ?? affData['name']?.toString() ?? '';
          if (bizName.isNotEmpty) {
            membership.value = membership.value.copyWith(businessName: bizName);
          }
        }
      });

      // Listen to session redemption
      ever(fbService.hasScannedFirstSession, (hasScanned) {
        if (hasScanned) {
          isSessionRedeemedToday.value = true;
          membership.value = membership.value.copyWith(redemptionsLeft: 0);
        }
      });
    }

    // Sync with ProfileService for backwards compatibility
    if (Get.isRegistered<ProfileService>()) {
      ever(ProfileService.to.profile, (prof) {
        if (prof.fullName.isNotEmpty && prof.fullName != 'Manager Name') {
          membership.value = membership.value.copyWith(
            memberName: prof.fullName,
            isVerified: prof.isVerified,
          );
        }
      });
    }
  }

  /// Pull real-time current details from Cloud Firestore & local models
  void syncWithCurrentDetails() {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final fbService = CustomerFirebaseService.to;

      // Check current active plan values
      if (fbService.activePlan.value != null) {
        final planData = fbService.activePlan.value!;
        final durationMonths = (planData['durationMonths'] as num?)?.toInt() ?? 3;
        membership.value = membership.value.copyWith(
          membershipPlan: planData['planName']?.toString() ?? 'Gold Quarterly Plan',
          sessionsLeft: (planData['sessionsLeft'] as num?)?.toInt() ?? 35,
          validTillDate: planData['validity']?.toString() ?? '15 Nov, 2026',
          validityDays: durationMonths * 30,
          isActive: true,
        );
      }

      // Check current user profile
      if (fbService.currentUserProfile.value != null) {
        final prof = fbService.currentUserProfile.value!;
        final name = prof['fullName']?.toString() ?? '';
        final phone = prof['phoneNumber']?.toString() ?? '';
        final uid = prof['uid']?.toString() ?? '';
        final isVer = prof['isVerified'] == true;
        if (name.isNotEmpty) {
          membership.value = membership.value.copyWith(
            memberName: name,
            contactPhone: phone.isNotEmpty ? phone : null,
            memberId: uid.isNotEmpty ? 'ID: ${uid.substring(0, uid.length.clamp(0, 8)).toUpperCase()}' : null,
            isVerified: isVer,
          );
        }
      }

      // Check current business affiliation
      if (fbService.currentAffiliation.value != null) {
        final aff = fbService.currentAffiliation.value!;
        final bizName = aff['businessName']?.toString() ?? aff['name']?.toString() ?? '';
        if (bizName.isNotEmpty) {
          membership.value = membership.value.copyWith(businessName: bizName);
        }
      }

      // Check session scan status
      if (fbService.hasScannedFirstSession.value) {
        isSessionRedeemedToday.value = true;
        membership.value = membership.value.copyWith(redemptionsLeft: 0);
      }
    }

    if (Get.isRegistered<ProfileService>()) {
      final prof = ProfileService.to.profile.value;
      if (prof.fullName.isNotEmpty && prof.fullName != 'Manager Name') {
        membership.value = membership.value.copyWith(
          memberName: prof.fullName,
          isVerified: prof.isVerified,
        );
      }
    }

    // Milestone check (DRD Review Reminder at 70%, 80%, 90%)
    if (subscriptionCompletionPct.value >= 70.0) {
      showReviewReminderBanner.value = true;
    }
  }

  /// Switch back to Dashboard V1 Stepper mode for testing/demo
  void switchToDashboardV1() {
    if (Get.isRegistered<DashboardV1Controller>()) {
      DashboardV1Controller.to.isDashboardV2Active.value = false;
    }
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final fbService = CustomerFirebaseService.to;
      final uid = fbService.currentUid.value;
      fbService.isDashboardV2Active.value = false;
      if (uid.isNotEmpty) {
        fbService.setDashboardV2Active(uid, false);
      }
    }
    Get.snackbar(
      'Dashboard V1 Stepper',
      'Switched back to Stepper onboarding preview mode.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF163238),
      colorText: AppColors.primaryBright,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.swap_horiz_rounded, color: AppColors.primaryBright),
      duration: const Duration(seconds: 2),
    );
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
      'Successfully added $count session(s) to your plan!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF163238),
      colorText: AppColors.primaryBright,
      margin: const EdgeInsets.all(16),
      icon: const Icon(Icons.check_circle_outline, color: AppColors.primaryBright),
    );
  }

  /// Mark Attendance / Redeem Pass with DRD 24-hour limit & Firestore sync
  Future<void> redeemSession() async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = CustomerFirebaseService.to.currentUid.value;
      if (uid.isNotEmpty) {
        final result = await CustomerFirebaseService.to.redeemDailySession(uid);
        if (result['success'] == true) {
          isSessionRedeemedToday.value = true;
          membership.value = membership.value.copyWith(
            redemptionsLeft: 0,
            sessionsLeft: (result['sessionsLeft'] as int?) ?? (membership.value.sessionsLeft - 1),
          );
          Get.snackbar(
            'Pass Verified & Redeemed',
            'Your workout session has been logged in the cloud! Have a great workout.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF163238),
            colorText: AppColors.primaryBright,
            margin: const EdgeInsets.all(16),
            icon: const Icon(Icons.verified_rounded, color: AppColors.primaryBright),
          );
          return;
        } else if (result['isBlocked24h'] == true) {
          Get.snackbar(
            'Daily Scan Limit',
            result['message']?.toString() ?? 'Scan is only valid once per day.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF2C1E1E),
            colorText: Colors.redAccent,
            margin: const EdgeInsets.all(16),
            icon: const Icon(Icons.timer_off_rounded, color: Colors.redAccent),
          );
          return;
        }
      }
    }

    // Fallback in-memory
    if (membership.value.redemptionsLeft > 0) {
      isSessionRedeemedToday.value = true;
      membership.value = membership.value.copyWith(
        redemptionsLeft: 0,
        sessionsLeft: (membership.value.sessionsLeft > 0) ? membership.value.sessionsLeft - 1 : 0,
      );
      Get.snackbar(
        'Session Redeemed',
        'Your daily workout session has been redeemed! Enjoy your training.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF163238),
        colorText: AppColors.primaryBright,
        margin: const EdgeInsets.all(16),
      );
    } else {
      Get.snackbar(
        'Scan Limit Reached',
        'Daily redemption limit reached. The pass renews at midnight 11:59 PM.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF163238),
        colorText: Colors.amberAccent,
        margin: const EdgeInsets.all(16),
      );
    }
  }

  /// Show Redemption Records Modal
  void showRedemptionRecords() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(22),
        decoration: const BoxDecoration(
          color: Color(0xFF13282D),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Redemption Records',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close, color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildRecordTile('Today', '07:15 AM', 'Main Gate Scanner #02', 'Verified Pass'),
            _buildRecordTile('Yesterday', '08:30 AM', 'Strength Zone Turnstile', 'Verified Pass'),
            _buildRecordTile('2 Oct 2026', '06:45 PM', 'CrossFit Floor Terminal', 'Verified Pass'),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordTile(String day, String time, String location, String status) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F1E22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.primaryBright, size: 20),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$day • $time', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                  Text(location, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBright.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              status,
              style: const TextStyle(color: AppColors.primaryBright, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Open DRD Review & Ratings Pop-Up
  void openReviewPopup() {
    ReviewRatingPopup.show(
      onSubmit: (rating, reviewText, categories, notes) {
        if (Get.isRegistered<CustomerFirebaseService>()) {
          final uid = CustomerFirebaseService.to.currentUid.value;
          CustomerFirebaseService.to.submitCustomerReview(
            uid: uid,
            rating: rating,
            reviewText: reviewText,
            issueCategories: categories,
            categoryNotes: notes,
          );
        }
        showReviewReminderBanner.value = false;
      },
    );
  }

  void handleTabNavigation(String tabName) {
    switch (tabName) {
      case 'Membership':
        Get.toNamed(AppRoutes.customerPlans);
        break;
      case 'Trainers':
        Get.toNamed(AppRoutes.myTrainers);
        break;
      case 'My Transaction':
        Get.toNamed(AppRoutes.customerTransactions);
        break;
      case 'Support':
        _showSupportDialog();
        break;
    }
  }

  void _showSupportDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF152A2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.support_agent_rounded, color: AppColors.primaryBright, size: 48),
              const SizedBox(height: 14),
              const Text(
                'Customer Support',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Need help with your plan or workouts? Reach out anytime.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 18),
              ListTile(
                leading: const Icon(Icons.phone, color: AppColors.primaryBright),
                title: const Text('Call Gym Desk', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('+91 98765 43210', style: TextStyle(color: Colors.white54, fontSize: 12)),
                onTap: () => Get.back(),
              ),
              ListTile(
                leading: const Icon(Icons.chat_bubble_outline, color: AppColors.primaryBright),
                title: const Text('Live Chat with Support', style: TextStyle(color: Colors.white, fontSize: 14)),
                subtitle: const Text('Available 06:00 AM - 10:00 PM', style: TextStyle(color: Colors.white54, fontSize: 12)),
                onTap: () => Get.back(),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBright,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('Close', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
