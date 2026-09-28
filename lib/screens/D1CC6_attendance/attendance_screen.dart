import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../controllers/D1CC6_attendance/attendance_controller.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_list_item.dart';
import '../../widgets/common_section_header.dart';
import '../../widgets/common_status_chip.dart';

/// D1CC6 – Attendance Verification & Monitoring Screen.
class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AttendanceController controller = Get.put(AttendanceController());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CommonAppBar(
        title: AppConstants.appName,
        subtitle: 'D1CC6 – Attendance Verification & Monitoring',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 750),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const CommonSectionHeader(
                            title: 'Live Check-In Logs',
                            subtitle:
                                'Real-time turnstile verification and access records',
                          ),
                          CommonButton(
                            text: '⚡ Record Entry',
                            width: 140,
                            height: 38,
                            onPressed: controller.openManualScanDialog,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    final logs = controller.logs;

                    if (logs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No attendance logs recorded yet.',
                          style: TextStyle(color: AppColors.grey),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppConstants.defaultPadding,
                        vertical: 4,
                      ),
                      itemCount: logs.length,
                      itemBuilder: (context, index) {
                        final log = logs[index];
                        final timeStr =
                            '${log.checkInTime.hour.toString().padLeft(2, '0')}:${log.checkInTime.minute.toString().padLeft(2, '0')}';

                        return CommonListItem(
                          title: log.memberName,
                          subtitle:
                              '${log.recordId} • ${log.planName} • Method: ${log.accessMethod} • Time: $timeStr',
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.veryLightGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.verified_user_rounded,
                              color: Color(0xFF33691E),
                              size: 22,
                            ),
                          ),
                          trailing: CommonStatusChip(status: log.status),
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
