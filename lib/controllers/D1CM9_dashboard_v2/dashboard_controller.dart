import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../models/D1CM9_dashboard_v2/gym_stat_model.dart';
import '../../routes/app_routes.dart';
import '../../services/D1CC6_attendance/attendance_service.dart';
import '../../services/D1CM4_membership_joining/membership_service.dart';
import '../../services/D1CM9_dashboard_v2/dashboard_service.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_popup.dart';
import '../../widgets/common_selection_field.dart';
import '../home/home_controller.dart';

/// D1CM9 – Dashboard Controller managing metrics, quick actions, and recent activity.
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
                style: TextStyle(color: AppColors.dark, fontSize: 13),
              ),
              const SizedBox(height: 16),
              CommonSelectionField<String>(
                label: 'Gym Member',
                selectedValue: quickCheckInSelectedMemberId.value,
                options: activeMembers.map((m) => m.id).toList(),
                optionLabelBuilder: (id) {
                  final m = activeMembers.firstWhereOrNull((x) => x.id == id);
                  return m != null ? '${m.name} (${m.planName})' : id;
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
        CommonButton(
          text: 'Confirm Entry',
          onPressed: () {
            final member = _membershipService.findMemberById(quickCheckInSelectedMemberId.value);
            if (member != null) {
              _attendanceService.recordAttendance(
                memberId: member.id,
                memberName: member.name,
                planName: member.planName,
              );
              final updated = member.copyWith(
                attendanceCount: member.attendanceCount + 1,
              );
              _membershipService.updateMember(updated);
            }
            Get.back();
            refreshDashboard();
            Get.snackbar(
              'Entry Verified',
              'Check-in successfully recorded.',
              backgroundColor: AppColors.dark,
              colorText: AppColors.primaryBright,
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        ),
      ],
    );
  }

  void openNewMemberForm() {
    Get.toNamed(AppRoutes.forms);
  }

  void openPlanManagement() {
    Get.toNamed(AppRoutes.customerPlans);
  }
}
