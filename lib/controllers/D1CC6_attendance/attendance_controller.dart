import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../api/api_state.dart';
import '../../constants/app_colors.dart';
import '../../models/D1CC6_attendance/attendance_record_model.dart';
import '../../services/D1CC6_attendance/attendance_service.dart';
import '../../services/D1MM3_membership_planning/membership_service.dart';
import '../../widgets/common_popup.dart';
import '../../widgets/common_selection_field.dart';
import '../../widgets/form_feedback_widgets.dart';

/// D1CC6 – Attendance Controller managing attendance logs, check-ins, validation, and states.
class AttendanceController extends GetxController {
  final AttendanceService attendanceService = Get.put(AttendanceService());
  final MembershipService membershipService = Get.put(MembershipService());

  final RxString selectedMemberForScan = ''.obs;
  final Rx<ViewState> attendanceState = ViewState.initial.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isSubmitting = false.obs;

  List<AttendanceRecordModel> get logs => attendanceService.attendanceLogs;

  @override
  void onInit() {
    super.onInit();
    loadAttendance();
  }

  Future<void> loadAttendance() async {
    attendanceState.value = ViewState.loading;
    errorMessage.value = '';
    await Future.delayed(const Duration(milliseconds: 300));
    if (logs.isEmpty) {
      attendanceState.value = ViewState.empty;
    } else {
      attendanceState.value = ViewState.success;
    }
  }

  void openManualScanDialog() {
    final members = membershipService.members;
    if (members.isEmpty) {
      AppFeedback.showError(
        title: 'No Members Found',
        message: 'No registered gym members found to record check-in.',
      );
      return;
    }

    selectedMemberForScan.value = members.first.id;

    CommonPopup.show(
      title: 'Scan / Manual Check-In',
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select a gym member to record entry verification:',
                style: TextStyle(fontSize: 13, color: AppColors.grey),
              ),
              const SizedBox(height: 12),
              CommonSelectionField<String>(
                label: 'Member',
                options: members.map((m) => m.id).toList(),
                selectedValue: selectedMemberForScan.value,
                optionLabelBuilder: (id) {
                  final m = members.firstWhere((item) => item.id == id);
                  return '${m.name} (${m.status})';
                },
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      selectedMemberForScan.value = val;
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
        Obx(() {
          return FormSubmitButton(
            text: 'Record Check-In',
            width: 160,
            height: 42,
            isSubmitting: isSubmitting.value,
            onPressed: () async {
              if (selectedMemberForScan.value.isEmpty) {
                AppFeedback.showError(
                  title: 'Selection Required',
                  message: 'Please select a member to check in.',
                );
                return;
              }

              // Duplicate submission & Duplicate Check-in guard:
              // Check if member already checked in today within the last 5 minutes
              final recentCheckIn = logs.any((l) =>
                  l.memberId == selectedMemberForScan.value &&
                  DateTime.now().difference(l.checkInTime).inMinutes < 5);

              if (recentCheckIn) {
                AppFeedback.showError(
                  title: 'Duplicate Check-In Warning',
                  message: 'This member has already recorded entry within the last 5 minutes.',
                );
                return;
              }

              isSubmitting.value = true;
              Get.back();

              await Future.delayed(const Duration(milliseconds: 200));
              attendanceService.recordMemberCheckIn(
                selectedMemberForScan.value,
                accessMethod: 'Manual Entry',
              );
              attendanceState.value = ViewState.success;
              isSubmitting.value = false;

              AppFeedback.showSuccess(
                title: 'Attendance Recorded',
                message: 'Turnstile check-in logged successfully.',
              );
            },
          );
        }),
      ],
    );
  }
}
