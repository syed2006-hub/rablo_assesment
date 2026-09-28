import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../models/D1MM4_dashboard/gym_stat_model.dart';
import '../../routes/app_routes.dart';
import '../../services/D1CC6_attendance/attendance_service.dart';
import '../../services/D1MM3_membership_planning/membership_service.dart';
import '../../services/D1MM4_dashboard/dashboard_service.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_popup.dart';
import '../../widgets/common_selection_field.dart';
import '../home/home_controller.dart';

/// D1MM4 – Dashboard Controller managing metrics, quick actions, and recent activity.
class DashboardController extends GetxController {
  final DashboardService _dashboardService = Get.put(DashboardService());
  final MembershipService _membershipService = Get.put(MembershipService());
  final AttendanceService _attendanceService = Get.put(AttendanceService());

  final RxList<GymStatModel> stats = <GymStatModel>[].obs;
  final RxString quickCheckInSelectedMemberId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    refreshDashboard();
  }

  void refreshDashboard() {
    stats.assignAll(_dashboardService.getMetrics());
  }

  void navigateToTab(int index) {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().changeTab(index);
    }
  }

  /// Opens quick check-in popup
  void openQuickCheckInDialog() {
    final activeMembers =
        _membershipService.members.where((m) => m.isActive || m.isExpiring).toList();

    if (activeMembers.isEmpty) {
      Get.snackbar('No Members', 'No active members available for check-in.');
      return;
    }

    quickCheckInSelectedMemberId.value = activeMembers.first.id;

    CommonPopup.show(
      title: '⚡ Quick Attendance Check-In',
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a gym member to record immediate entry verification:',
                style: TextStyle(fontSize: 13, color: AppColors.grey),
              ),
              const SizedBox(height: 12),
              CommonSelectionField<String>(
                label: 'Select Member',
                options: activeMembers.map((m) => m.id).toList(),
                selectedValue: quickCheckInSelectedMemberId.value,
                optionLabelBuilder: (id) {
                  final m = activeMembers.firstWhere((item) => item.id == id);
                  return '${m.name} (${m.planName})';
                },
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      quickCheckInSelectedMemberId.value = val;
                    });
                  }
                },
              ),
            ],
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
        ),
        CommonButton(
          text: 'Verify & Check In',
          width: 160,
          height: 42,
          onPressed: () {
            final memberId = quickCheckInSelectedMemberId.value;
            final success = _attendanceService.recordMemberCheckIn(
              memberId,
              accessMethod: 'Quick Action',
            );
            Get.back();
            if (success) {
              refreshDashboard();
              Get.snackbar(
                'Check-In Verified',
                'Attendance recorded successfully.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: AppColors.dark,
                colorText: AppColors.primaryBright,
                margin: const EdgeInsets.all(16),
              );
            }
          },
        ),
      ],
    );
  }

  void navigateToCreateMember() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().changeTab(2); // Forms tab
    } else {
      Get.toNamed(AppRoutes.forms);
    }
  }

  void navigateToMembersList() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().changeTab(1); // Members tab
    } else {
      Get.toNamed(AppRoutes.members);
    }
  }

  void navigateToAttendanceLogs() {
    Get.toNamed(AppRoutes.attendance);
  }
}
