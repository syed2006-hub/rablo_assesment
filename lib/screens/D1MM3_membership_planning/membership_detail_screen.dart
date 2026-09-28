import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';
import '../../controllers/D1MM3_membership_planning/membership_controller.dart';
import '../../widgets/common_app_bar.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_container.dart';
import '../../widgets/common_detail_row.dart';
import '../../widgets/common_section_header.dart';
import '../../widgets/common_status_chip.dart';

/// D1MM3 – Member Detail Screen providing complete member profile, attendance, and plan actions.
class MembershipDetailScreen extends StatelessWidget {
  const MembershipDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final MembershipController controller = Get.find<MembershipController>();

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: CommonAppBar(
        title: AppConstants.appName,
        subtitle: 'D1MM3 – Member Profile & Subscription',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final member = controller.selectedMember.value;

          if (member == null) {
            return const Center(
              child: Text(
                'No member selected.',
                style: TextStyle(color: AppColors.grey),
              ),
            );
          }

          final daysRemaining =
              member.expiryDate.difference(DateTime.now()).inDays;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 680),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Member Profile Hero Card
                    CommonContainer(
                      child: Column(
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: AppColors.dark,
                                child: Text(
                                  member.name.substring(0, 1).toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBright,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      member.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.dark,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Member ID: ${member.id} • ${member.gender}',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.grey,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    CommonStatusChip(status: member.status),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          // Stats Bar
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildMiniStat(
                                  'Total Check-Ins',
                                  '${member.attendanceCount}',
                                  Icons.check_circle_outline_rounded,
                                ),
                                Container(
                                  width: 1,
                                  height: 30,
                                  color: AppColors.lightGrey,
                                ),
                                _buildMiniStat(
                                  'Days Remaining',
                                  daysRemaining > 0
                                      ? '$daysRemaining days'
                                      : 'Expired',
                                  Icons.calendar_today_rounded,
                                  isAlert: daysRemaining <= 7,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Subscription Details Table
                    const CommonSectionHeader(
                      title: 'Membership & Subscription Details',
                      subtitle: 'Plan validity, renewal timestamps, and tier benefits',
                    ),
                    CommonContainer(
                      child: Column(
                        children: [
                          CommonDetailRow(
                            label: 'Membership Tier',
                            value: member.planName,
                            icon: Icons.fitness_center_rounded,
                          ),
                          CommonDetailRow(
                            label: 'Join Date',
                            value:
                                '${member.joinDate.day}/${member.joinDate.month}/${member.joinDate.year}',
                            icon: Icons.login_rounded,
                          ),
                          CommonDetailRow(
                            label: 'Expiry Date',
                            value:
                                '${member.expiryDate.day}/${member.expiryDate.month}/${member.expiryDate.year}',
                            icon: Icons.event_available_rounded,
                          ),
                          CommonDetailRow(
                            label: 'Phone Number',
                            value: member.phone,
                            icon: Icons.phone_outlined,
                          ),
                          CommonDetailRow(
                            label: 'Email Address',
                            value: member.email,
                            icon: Icons.email_outlined,
                          ),
                          CommonDetailRow(
                            label: 'Emergency Contact',
                            value: member.emergencyContact,
                            icon: Icons.emergency_outlined,
                          ),
                          if (member.notes != null)
                            CommonDetailRow(
                              label: 'Health / Workout Notes',
                              value: member.notes!,
                              icon: Icons.note_alt_outlined,
                              showDivider: false,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Digital Check-In Pass
                    const CommonSectionHeader(
                      title: 'D1CC6 Digital Access Pass',
                      subtitle: 'Live verification for turnstile & front desk entry',
                    ),
                    CommonContainer(
                      child: Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppColors.dark,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.qr_code_2_rounded,
                              color: AppColors.primaryBright,
                              size: 40,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fast-Track Desk Entry',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.dark,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Pass Token: ${member.id}-PASS',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          CommonButton(
                            text: '⚡ Check In',
                            width: 110,
                            height: 38,
                            onPressed:
                                controller.recordCheckInForSelectedMember,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // 4. Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: CommonButton(
                            text: '🔄 Renew Membership',
                            height: 48,
                            onPressed: () =>
                                controller.renewMembership(member),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: CommonButton(
                            text: 'Back to List',
                            height: 48,
                            backgroundColor: AppColors.dark,
                            textColor: AppColors.white,
                            onPressed: () => Get.back(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMiniStat(
    String label,
    String value,
    IconData icon, {
    bool isAlert = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isAlert ? AppColors.error : AppColors.dark,
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: isAlert ? AppColors.error : AppColors.dark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.grey),
        ),
      ],
    );
  }
}
