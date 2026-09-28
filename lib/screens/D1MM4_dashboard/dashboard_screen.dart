import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../controllers/D1MM3_membership_planning/membership_controller.dart';
import '../../controllers/D1MM4_dashboard/dashboard_controller.dart';
import '../../routes/app_routes.dart';
import '../../services/D1CC6_attendance/attendance_service.dart';
import '../../services/D1MM3_membership_planning/membership_service.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_container.dart';
import '../../widgets/common_list_item.dart';
import '../../widgets/common_section_header.dart';
import '../../widgets/common_stat_card.dart';
import '../../widgets/common_status_chip.dart';

/// D1MM4 – Dashboard Screen providing comprehensive gym metrics and quick operations.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DashboardController controller = Get.put(DashboardController());
    final AttendanceService attendanceService = Get.put(AttendanceService());
    final MembershipService membershipService = Get.put(MembershipService());

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CommonAppBar(
        title: AppConstants.appName,
        subtitle: 'D1MM4 – Gym Operations Dashboard',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.white),
            tooltip: 'Refresh Metrics',
            onPressed: controller.refreshDashboard,
          ),
          IconButton(
            icon: const Icon(Icons.widgets_outlined, color: AppColors.primaryBright),
            tooltip: 'Component Showcase',
            onPressed: () => Get.toNamed(AppRoutes.widgets),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header Greeting
                  const CommonSectionHeader(
                    title: 'Gym Management Overview',
                    subtitle:
                        'Live tracking of attendance, memberships, and operational health',
                  ),
                  const SizedBox(height: 12),

                  // 1. KPI Metric Cards
                  Obx(() {
                    final stats = controller.stats.toList();
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth > 500;
                        final crossAxisCount = isWide ? 2 : 1;

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: stats.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: isWide ? 2.2 : 2.5,
                          ),
                          itemBuilder: (context, index) {
                            final stat = stats[index];
                            return CommonStatCard(
                              title: stat.title,
                              value: stat.value,
                              changeText: stat.change,
                              isPositive: stat.isPositive,
                              icon: stat.icon,
                              onTap: () {
                                if (stat.title.contains('Members') ||
                                    stat.title.contains('Enrolled')) {
                                  controller.navigateToMembersList();
                                } else if (stat.title.contains('Check-ins')) {
                                  controller.navigateToAttendanceLogs();
                                }
                              },
                            );
                          },
                        );
                      },
                    );
                  }),
                  const SizedBox(height: 20),

                  // 2. Quick Operations Card
                  const CommonSectionHeader(
                    title: 'Quick Operations',
                    subtitle: 'Execute high-frequency gym desk actions',
                  ),
                  CommonContainer(
                    child: Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 170,
                          child: CommonButton(
                            text: '⚡ Check-In Pass',
                            height: 42,
                            onPressed: controller.openQuickCheckInDialog,
                          ),
                        ),
                        SizedBox(
                          width: 170,
                          child: CommonButton(
                            text: '+ Add Member',
                            height: 42,
                            backgroundColor: AppColors.dark,
                            textColor: AppColors.white,
                            onPressed: controller.navigateToCreateMember,
                          ),
                        ),
                        SizedBox(
                          width: 170,
                          child: CommonButton(
                            text: '👥 Members List',
                            height: 42,
                            backgroundColor: AppColors.veryLightGreen,
                            textColor: AppColors.dark,
                            onPressed: controller.navigateToMembersList,
                          ),
                        ),
                        SizedBox(
                          width: 170,
                          child: CommonButton(
                            text: '📋 Attendance Logs',
                            height: 42,
                            backgroundColor: AppColors.backgroundLight,
                            textColor: AppColors.dark,
                            onPressed: controller.navigateToAttendanceLogs,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 3. Live Attendance Feed
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const CommonSectionHeader(
                        title: 'Recent Member Check-Ins',
                        subtitle: 'D1CC6 Attendance verification live feed',
                      ),
                      TextButton(
                        onPressed: controller.navigateToAttendanceLogs,
                        child: const Text(
                          'View All →',
                          style: TextStyle(
                            color: AppColors.dark,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    final logs = attendanceService.attendanceLogs.take(4).toList();
                    if (logs.isEmpty) {
                      return const CommonContainer(
                        child: Center(
                          child: Text(
                            'No check-ins recorded today.',
                            style: TextStyle(color: AppColors.grey),
                          ),
                        ),
                      );
                    }
                    return Column(
                      children: logs.map((log) {
                        final timeStr =
                            '${log.checkInTime.hour.toString().padLeft(2, '0')}:${log.checkInTime.minute.toString().padLeft(2, '0')}';
                        return CommonListItem(
                          title: log.memberName,
                          subtitle: '${log.planName} • $timeStr (${log.accessMethod})',
                          leading: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.veryLightGreen,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.check_circle_outline_rounded,
                              color: Color(0xFF33691E),
                              size: 20,
                            ),
                          ),
                          trailing: CommonStatusChip(status: log.status),
                          onTap: () {
                            final member = membershipService.findMemberById(log.memberId);
                            if (member != null) {
                              Get.find<MembershipController>()
                                  .selectMemberAndOpenDetail(member);
                            }
                          },
                        );
                      }).toList(),
                    );
                  }),
                  const SizedBox(height: 20),

                  // 4. Membership Plans Summary Card
                  const CommonSectionHeader(
                    title: 'Active Membership Tiers',
                    subtitle: 'D1MM3 Membership planning packages',
                  ),
                  Obx(() {
                    final plans = membershipService.plans;
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: plans.map((plan) {
                          return Container(
                            width: 220,
                            margin: const EdgeInsets.only(right: 12, bottom: 8),
                            child: CommonContainer(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          plan.name,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.dark,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      if (plan.isPopular)
                                        const CommonStatusChip(
                                          status: 'POPULAR',
                                          fontSize: 9,
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    plan.formattedPrice,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                  Text(
                                    'per ${plan.billingDuration}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  ...plan.features.take(2).map(
                                        (f) => Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 4),
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.check_rounded,
                                                size: 14,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 4),
                                              Expanded(
                                                child: Text(
                                                  f,
                                                  style: const TextStyle(
                                                    fontSize: 11,
                                                    color: AppColors.grey,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
