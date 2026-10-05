import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../controllers/D1CM9_dashboard_v2/dashboard_v2_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/membership_hero_card.dart';
import '../../widgets/rush_hour_chart.dart';

/// D1CM9 – Customer Dashboard V2 Screen.
/// Strictly implements DRD D1CM9 specifications:
/// - Active membership plan summary (Validity, Renew, Sessions Left, Upgrade)
/// - Redemption Summary with countdown to midnight reset (11:59 PM) and pass logs
/// - 24-hour scan limitation enforcement
/// - Interactive Rush Hours Indicator graph (Red = Full, Green = Neutral, Blue = Empty)
/// - Accessibility tabs: Membership, Trainers, My Transaction, Support
/// - Automated review reminder system with Review & Ratings pop-up
class DashboardV2Screen extends StatelessWidget {
  const DashboardV2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DashboardV2Controller());

    return Scaffold(
      backgroundColor: AppColors.slateScaffold,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP APP BAR
              _buildTopHeader(context, controller),

              const SizedBox(height: 16),

              // 2. AUTOMATED REVIEW REMINDER BANNER (DRD Milestone 70%, 80%, 90%)
              Obx(() {
                if (!controller.showReviewReminderBanner.value) {
                  return const SizedBox.shrink();
                }
                return _buildReviewReminderBanner(context, controller);
              }),

              // 3. WELCOME BACK STEPPER PROGRESS CARD
              _buildWelcomeProgressCard(context, controller),

              const SizedBox(height: 16),

              // 4. ACTIVE MEMBERSHIP SUMMARY HERO CARD
              Obx(() => MembershipHeroCard(
                    membership: controller.membership.value,
                    onTap: () => Get.toNamed(AppRoutes.customerPlanListing),
                  )),

              const SizedBox(height: 14),

              // 5. REDEMPTION SUMMARY CARD (Countdown to 11:59 PM Reset)
              _buildRedemptionSummaryCard(context, controller),

              const SizedBox(height: 14),

              // 6. ACCESSIBILITY TABS (Membership, Trainers, My Transaction, Support)
              _buildAccessibilityTabs(context, controller),

              const SizedBox(height: 16),

              // 7. RUSH HOURS INDICATOR CARD
              _buildRushHoursCard(context, controller),

              const SizedBox(height: 20),

              // 8. NEW MEMBERSHIPS PLAN CAROUSEL HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New Memberships Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.toNamed(AppRoutes.customerPlans),
                    child: const Text(
                      'View all >>',
                      style: TextStyle(
                        color: AppColors.primaryLight,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Plan preview cards
              _buildPlanPreviews(context),
            ],
          ),
        ),
      ),
    );
  }

  // --- Top Header ---
  Widget _buildTopHeader(BuildContext context, DashboardV2Controller controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.profile),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryBright, width: 2),
                  color: const Color(0xFF1E353B),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Good day,',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                Obx(() => Text(
                      controller.membership.value.memberName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
              ],
            ),
          ],
        ),
        Row(
          children: [
     
            // Review Trigger Button
            IconButton(
              tooltip: 'Write a Review',
              icon: const Icon(Icons.star_rounded, color: Colors.amberAccent, size: 26),
              onPressed: () => controller.openReviewPopup(),
            ),
            // Notifications Icon
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF162D34),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const Icon(Icons.notifications_none_rounded, color: Colors.white, size: 20),
                ),
                Positioned(
                  top: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.peakRed,
                      shape: BoxShape.circle,
                    ),
                    child: Obx(() => Text(
                          '${controller.unreadNotifications.value}',
                          style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                        )),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // --- Review Reminder Banner ---
  Widget _buildReviewReminderBanner(BuildContext context, DashboardV2Controller controller) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2B3A1C), Color(0xFF152A2F)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryBright.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.rate_review_rounded, color: AppColors.primaryBright, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Milestone Reached! (70% Completion)',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 2),
                Text(
                  'How is your training going? Share your quick feedback.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBright,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => controller.openReviewPopup(),
            child: const Text('Review', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // --- Welcome Progress Card ---
  Widget _buildWelcomeProgressCard(BuildContext context, DashboardV2Controller controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF162D34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBright.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(color: AppColors.primaryBright, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const Icon(Icons.verified_user_rounded, color: AppColors.primaryBright, size: 20),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() {
            final m = controller.membership.value;
            final plan = m.membershipPlan.isNotEmpty ? m.membershipPlan : 'Gold Quarterly Plan';
            final biz = m.businessName.isNotEmpty ? m.businessName : 'Fitness Centre Rablo';
            return Text(
              'Active Plan: $plan • $biz',
              style: const TextStyle(color: Colors.white70, fontSize: 12.5),
            );
          }),
          const SizedBox(height: 12),
          // Stepper progress indicator (100% completed)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: const LinearProgressIndicator(
              value: 1.0,
              minHeight: 6,
              backgroundColor: Colors.white10,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBright),
            ),
          ),
        ],
      ),
    );
  }

  // --- Redemption Summary Card ---
  Widget _buildRedemptionSummaryCard(BuildContext context, DashboardV2Controller controller) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF142B31),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Redemption Summary',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              TextButton.icon(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => controller.showRedemptionRecords(),
                icon: const Icon(Icons.history_rounded, color: AppColors.primaryLight, size: 16),
                label: const Text(
                  'View records',
                  style: TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF0F1E22),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.timer_outlined, color: AppColors.primaryBright, size: 16),
                          const SizedBox(width: 6),
                          const Text('Reset Countdown:', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            controller.countdownTimerStr.value,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              fontFamily: 'monospace',
                            ),
                          )),
                      const SizedBox(height: 3),
                      Obx(() => Text(
                            '${controller.membership.value.sessionsLeft} session(s) left • ${controller.membership.value.businessName}',
                            style: const TextStyle(color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          )),
                      const SizedBox(height: 2),
                      const Text(
                        'Renews mid-night 11:59 PM',
                        style: TextStyle(color: Colors.white38, fontSize: 10.5),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBright,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                  onPressed: () => controller.redeemSession(),
                  icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                  label: Obx(() => Text(
                        controller.isSessionRedeemedToday.value ? 'Redeemed' : 'Redeem Pass',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Accessibility Tabs ---
  Widget _buildAccessibilityTabs(BuildContext context, DashboardV2Controller controller) {
    final tabs = [
      {'name': 'Membership', 'icon': Icons.card_membership_rounded},
      {'name': 'Trainers', 'icon': Icons.sports_gymnastics_rounded},
      {'name': 'My Transaction', 'icon': Icons.receipt_long_rounded},
      {'name': 'Support', 'icon': Icons.support_agent_rounded},
    ];

    return Row(
      children: tabs.map((tab) {
        return Expanded(
          child: GestureDetector(
            onTap: () => controller.handleTabNavigation(tab['name'] as String),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF162D34),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: Column(
                children: [
                  Icon(tab['icon'] as IconData, color: AppColors.primaryBright, size: 20),
                  const SizedBox(height: 6),
                  Text(
                    tab['name'] as String,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // --- Rush Hours Indicator Card ---
  Widget _buildRushHoursCard(BuildContext context, DashboardV2Controller controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF162D34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rush Hours Indicator',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white10,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.access_time, color: Colors.white54, size: 12),
                    SizedBox(width: 4),
                    Text('06:00 - 22:00', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Live gym occupancy pattern across operating hours.',
            style: TextStyle(color: Colors.white54, fontSize: 11.5),
          ),
          const SizedBox(height: 14),

          // Rush Hour Chart
          Obx(() => RushHourChartWidget(
                points: controller.rushHourPoints,
                selectedPoint: controller.selectedHour.value,
                onPointSelected: controller.selectHour,
              )),

          const SizedBox(height: 12),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegend(AppColors.cyanAccent, 'Empty'),
              const SizedBox(width: 16),
              _buildLegend(AppColors.primaryBright, 'Neutral'),
              const SizedBox(width: 16),
              _buildLegend(AppColors.peakRed, 'Full / Peak'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  // --- Plan Previews ---
  Widget _buildPlanPreviews(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildMiniPlanCard('Standard Monthly', '₹2,499', '30 Sessions', 'General gym floor access'),
          _buildMiniPlanCard('Gold Quarterly', '₹6,999', '90 Sessions', 'All-access pass with trainer'),
          _buildMiniPlanCard('Platinum Annual', '₹19,999', '365 Sessions', 'Full VIP access with private locker'),
        ],
      ),
    );
  }

  Widget _buildMiniPlanCard(String name, String price, String sessions, String subtitle) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF162D34),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                price,
                style: const TextStyle(color: AppColors.primaryBright, fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ],
          ),
          Text(subtitle, style: const TextStyle(color: Colors.white54, fontSize: 11), maxLines: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  sessions,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              const Text('Join >>', style: TextStyle(color: AppColors.primaryLight, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
