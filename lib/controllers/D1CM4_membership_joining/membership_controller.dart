import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../models/D1CM4_membership_joining/member_model.dart';
import '../../models/D1CM4_membership_joining/membership_plan_model.dart';
import '../../routes/app_routes.dart';
import '../../services/D1CC6_attendance/attendance_service.dart';
import '../../services/D1CM4_membership_joining/membership_service.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_popup.dart';

/// D1CM4 – Membership Controller for member directory lists, filtering, and member detail actions.
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

  void recordAttendanceForMember(MemberModel member) {
    attendanceService.recordAttendance(
      memberId: member.id,
      memberName: member.name,
      planName: member.planName,
    );

    final updated = member.copyWith(
      attendanceCount: member.attendanceCount + 1,
    );
    membershipService.updateMember(updated);
    selectedMember.value = updated;

    CommonPopup.show(
      title: 'Attendance Confirmed',
      content: Text(
        'Check-in recorded for ${member.name} at ${DateTime.now().hour}:${DateTime.now().minute.toString().padLeft(2, '0')}.',
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      actions: [
        CommonButton(
          text: 'Great',
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  void renewMembership(MemberModel member, MembershipPlanModel plan) {
    final newExpiry = member.isInactive
        ? DateTime.now().add(Duration(days: plan.durationMonths * 30))
        : member.expiryDate.add(Duration(days: plan.durationMonths * 30));

    final updated = member.copyWith(
      planName: plan.name,
      status: 'Active',
      expiryDate: newExpiry,
    );

    membershipService.updateMember(updated);
    selectedMember.value = updated;

    Get.back(); // close modal
    CommonPopup.show(
      title: 'Plan Renewed Successfully',
      content: Text(
        '${member.name} has been enrolled into ${plan.name}. New expiry date is ${newExpiry.day}/${newExpiry.month}/${newExpiry.year}.',
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      actions: [
        CommonButton(
          text: 'Done',
          onPressed: () => Get.back(),
        ),
      ],
    );
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
