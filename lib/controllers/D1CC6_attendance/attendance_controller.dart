import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../models/D1CC6_attendance/attendance_record_model.dart';
import '../../services/D1CC6_attendance/attendance_service.dart';
import '../../services/D1MM3_membership_planning/membership_service.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_popup.dart';
import '../../widgets/common_selection_field.dart';

/// D1CC6 – Attendance Controller managing attendance logs and scan entries.
class AttendanceController extends GetxController {
  final AttendanceService attendanceService = Get.put(AttendanceService());
  final MembershipService membershipService = Get.put(MembershipService());

  final RxString selectedMemberForScan = ''.obs;

  List<AttendanceRecordModel> get logs => attendanceService.attendanceLogs;

  void openManualScanDialog() {
    final members = membershipService.members;
    if (members.isEmpty) {
      Get.snackbar('No Members', 'No members found.');
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
        CommonButton(
          text: 'Record Check-In',
          width: 150,
          height: 42,
          onPressed: () {
            attendanceService.recordMemberCheckIn(
              selectedMemberForScan.value,
              accessMethod: 'Manual Entry',
            );
            Get.back();
            Get.snackbar(
              'Attendance Recorded',
              'Check-in successfully saved in attendance ledger.',
              snackPosition: SnackPosition.BOTTOM,
              margin: const EdgeInsets.all(16),
            );
          },
        ),
      ],
    );
  }
}
