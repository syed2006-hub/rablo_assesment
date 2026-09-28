import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../models/D1MM3_membership_planning/member_model.dart';
import '../../models/D1MM3_membership_planning/membership_plan_model.dart';
import '../../routes/app_routes.dart';
import '../../services/D1CC6_attendance/attendance_service.dart';
import '../../services/D1MM3_membership_planning/membership_service.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_popup.dart';

/// D1MM3 – Membership Controller for member directory lists, filtering, and member detail actions.
class MembershipController extends GetxController {
  final MembershipService membershipService = Get.put(MembershipService());
  final AttendanceService attendanceService = Get.put(AttendanceService());

  final TextEditingController searchController = TextEditingController();
  final RxString searchQuery = ''.obs;
  final RxInt selectedFilterIndex = 0.obs;

  final List<String> filterTabs = const ['All', 'Active', 'Expiring', 'Inactive'];

  final Rx<MemberModel?> selectedMember = Rx<MemberModel?>(null);

  List<MembershipPlanModel> get plans => membershipService.plans;

  List<MemberModel> get filteredMembers {
    final query = searchQuery.value.toLowerCase().trim();
    final filter = filterTabs[selectedFilterIndex.value];

    return membershipService.members.where((member) {
      // Filter by tab
      if (filter == 'Active' && !member.isActive) return false;
      if (filter == 'Expiring' && !member.isExpiring) return false;
      if (filter == 'Inactive' && !member.isInactive) return false;

      // Filter by search query
      if (query.isNotEmpty) {
        final matchesName = member.name.toLowerCase().contains(query);
        final matchesEmail = member.email.toLowerCase().contains(query);
        final matchesPhone = member.phone.toLowerCase().contains(query);
        final matchesPlan = member.planName.toLowerCase().contains(query);
        final matchesId = member.id.toLowerCase().contains(query);
        return matchesName || matchesEmail || matchesPhone || matchesPlan || matchesId;
      }
      return true;
    }).toList();
  }

  void onSearchChanged(String value) {
    searchQuery.value = value;
  }

  void onFilterTabSelected(int index) {
    selectedFilterIndex.value = index;
  }

  void selectMemberAndOpenDetail(MemberModel member) {
    selectedMember.value = member;
    Get.toNamed(AppRoutes.memberDetail);
  }

  void renewMembership(MemberModel member) {
    CommonPopup.show(
      title: 'Renew Membership',
      message: 'Extend membership subscription for ${member.name} by 3 months?',
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel', style: TextStyle(color: AppColors.grey)),
        ),
        CommonButton(
          text: 'Confirm Renewal',
          width: 150,
          height: 42,
          onPressed: () {
            final updated = member.copyWith(
              status: 'Active',
              expiryDate: DateTime.now().add(const Duration(days: 90)),
            );
            membershipService.updateMember(updated);
            selectedMember.value = updated;
            Get.back();
            Get.snackbar(
              'Membership Renewed',
              'Plan for ${member.name} extended to ${updated.expiryDate.day}/${updated.expiryDate.month}/${updated.expiryDate.year}',
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
            );
          },
        ),
      ],
    );
  }

  void recordCheckInForSelectedMember() {
    final member = selectedMember.value;
    if (member != null) {
      final success = attendanceService.recordMemberCheckIn(
        member.id,
        accessMethod: 'Member Detail Pass',
      );
      if (success) {
        final updated = membershipService.findMemberById(member.id);
        if (updated != null) {
          selectedMember.value = updated;
        }
        Get.snackbar(
          'Check-In Recorded',
          'Attendance logged for ${member.name}. Total: ${updated?.attendanceCount ?? member.attendanceCount + 1}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.dark,
          colorText: AppColors.primaryBright,
          margin: const EdgeInsets.all(16),
        );
      }
    }
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
