import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_text_styles.dart';
import '../../controllers/D1MM10_dashboard_v2/dashboard_v2_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/membership_hero_card.dart';
import '../../widgets/rush_hour_chart.dart';

/// D1MM10 – Customer Dashboard V2 Screen.
/// Strictly implements Figma `D1MM10 Dashboard V2.png` and `iPhone 16.png`.
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

              const SizedBox(height: 18),

              // 2. WELCOME BACK STEPPER PROGRESS CARD (D1MM10)
              _buildWelcomeProgressCard(context, controller),

              const SizedBox(height: 18),

              // 3. ACTIVE MEMBERSHIP HERO CARD (iPhone 16)
              Obx(() => MembershipHeroCard(
                    membership: controller.membership.value,
                    onTap: () => Get.toNamed(AppRoutes.customerPlanListing),
                  )),

              const SizedBox(height: 14),

              // 4. DUAL ACTION BALANCE CARDS (Side-by-side)
              _buildDualBalanceCards(context, controller),

              const SizedBox(height: 16),

              // 5. 4-ACTION QUICK SHORTCUTS GRID
              _buildQuickActionGrid(context),

              const SizedBox(height: 18),

              // 6. RUSH HOURS INDICATOR CARD
              _buildRushHoursCard(context, controller),

              const SizedBox(height: 22),

              // 7. NEW MEMBERSHIPS PLAN CAROUSEL HEADER
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
      children: [
        // User Avatar with circular border
        Stack(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryBright, width: 2),
                image: const DecorationImage(
                  image: AssetImage('assets/images/welcome_bg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: AppColors.verifiedGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 10),
              ),
            ),
          ],
        ),


        const SizedBox(width: 12),

        // Greeting & Rablo brand
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Obx(() => Text(
                        'Hi ${controller.membership.value.memberName}!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                  const SizedBox(width: 8),
                  // Verified / Unverified pill badge
                  Obx(() {
                    final isVer = controller.membership.value.isVerified;
                    return GestureDetector(
                      onTap: controller.toggleVerified,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isVer ? AppColors.verifiedGreen : AppColors.unverifiedRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isVer ? Icons.verified : Icons.help_outline,
                              color: Colors.white,
                              size: 11,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isVer ? 'Verified' : 'Unverified',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 2),
              const Text.rich(
                TextSpan(
                  text: 'This is ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontStyle: FontStyle.italic,
                  ),
                  children: [
                    TextSpan(
                      text: 'Rablo..',
                      style: TextStyle(
                        color: AppColors.primaryBright,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Notification Bell with badge '4'
        Stack(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.slateCardLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.slateBorder),
              ),
              child: IconButton(
                icon: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
                onPressed: () {
                  Get.snackbar(
                    'Notifications',
                    'You have 4 new gym notifications and renewal updates.',
                    backgroundColor: AppColors.slateCard,
                    colorText: Colors.white,
                    snackPosition: SnackPosition.TOP,
                  );
                },
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.badgeBlue,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '4',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(width: 8),

        // 3-dots Menu
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          color: AppColors.slateCardDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: const BorderSide(color: AppColors.slateBorder),
          ),
          onSelected: (val) {
            if (val == 'staff') {
              Get.toNamed(AppRoutes.home);
            } else if (val == 'webpage') {
              Get.toNamed(AppRoutes.customerWebpage);
            } else if (val == 'qr') {
              Get.toNamed(AppRoutes.customerQr);
            }
          },
          itemBuilder: (ctx) => [
            const PopupMenuItem(
              value: 'qr',
              child: Text('Digital Access Pass', style: TextStyle(color: Colors.white)),
            ),
            const PopupMenuItem(
              value: 'webpage',
              child: Text('Web Presence Addon', style: TextStyle(color: Colors.white)),
            ),
            const PopupMenuItem(
              value: 'staff',
              child: Text('Switch to Staff Desk', style: TextStyle(color: AppColors.primaryLight)),
            ),
          ],
        ),
      ],
    );
  }

  // --- Welcome Back Progress Card ---
  Widget _buildWelcomeProgressCard(BuildContext context, DashboardV2Controller controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slateCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slateBorder),
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome Back!',
            style: AppTextStyles.sectionTitleItalic,
          ),
          const SizedBox(height: 4),
          const Text(
            'You are One-Step Closer to creating your App.',
            style: TextStyle(color: AppColors.greyMuted, fontSize: 13),
          ),

          const SizedBox(height: 18),

          // Stepper Row
          Row(
            children: [
              _buildStepIcon(Icons.check, isDone: true),
              _buildStepConnector(isDone: false),
              _buildStepIcon(Icons.description_outlined, isDone: false),
              _buildStepConnector(isDone: false),
              _buildStepIcon(Icons.verified_outlined, isDone: false),
              _buildStepConnector(isDone: false),
              _buildStepIcon(Icons.military_tech_outlined, isDone: false),
              _buildStepConnector(isDone: false),
              _buildStepIcon(Icons.language, isDone: false),

              const SizedBox(width: 10),
              Container(height: 24, width: 1, color: AppColors.slateBorder),
              const SizedBox(width: 10),

              const Text(
                '20%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // CTA Button: Complete Your Profile
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBright,
                foregroundColor: Colors.black,
                elevation: 4,
                shadowColor: AppColors.primaryBright.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Get.toNamed(AppRoutes.profile),
              child: const Text(
                'Complete Your Profile',
                style: AppTextStyles.buttonDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon(IconData icon, {required bool isDone}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: isDone ? AppColors.primaryLight : AppColors.slateCardLight,
        shape: BoxShape.circle,
        border: Border.all(
          color: isDone ? AppColors.primaryLight : AppColors.slateBorderLight,
          width: 1.5,
        ),
      ),
      child: Icon(
        icon,
        size: 16,
        color: isDone ? Colors.black : Colors.white60,
      ),
    );
  }

  Widget _buildStepConnector({required bool isDone}) {
    return Expanded(
      child: Container(
        height: 2,
        color: isDone ? AppColors.primaryLight : AppColors.slateBorderLight,
      ),
    );
  }

  // --- Dual Balance Cards ---
  Widget _buildDualBalanceCards(BuildContext context, DashboardV2Controller controller) {
    return Row(
      children: [
        // Left Card: Session-Based
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.slateCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.slateBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Session-Based',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white54, size: 16),
                  ],
                ),
                const SizedBox(height: 10),
                Obx(() => Text.rich(
                      TextSpan(
                        text: '${controller.membership.value.sessionsLeft.toString().padLeft(2, '0')} ',
                        style: const TextStyle(
                          color: AppColors.primaryLight,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Sessions Left',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 6),
                Obx(() => Text(
                      'Valid till ${controller.membership.value.validTillDate}',
                      style: const TextStyle(color: AppColors.greyMuted, fontSize: 10),
                    )),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBright,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () => controller.buySessions(10),
                    child: const Text(
                      'Buy Sessions',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Right Card: Session Redemption
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.slateCard,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.slateBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Session Redemption',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.chevron_right, color: Colors.white54, size: 16),
                  ],
                ),
                const SizedBox(height: 10),
                Obx(() => Text.rich(
                      TextSpan(
                        text: '${controller.membership.value.redemptionsLeft.toString().padLeft(2, '0')} ',
                        style: const TextStyle(
                          color: AppColors.cyanAccent,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Redemptions Left',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 6),
                Obx(() => Text(
                      'Renews ${controller.membership.value.renewalTime}',
                      style: const TextStyle(color: AppColors.greyMuted, fontSize: 10),
                    )),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.cyanAccent,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: controller.redeemSession,
                    child: const Text(
                      'Redeem Now',
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // --- Quick Action Grid (4 Icons) ---
  Widget _buildQuickActionGrid(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slateCard,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.slateBorder),
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildQuickActionItem(
            icon: Icons.military_tech_outlined,
            label: 'Membership',
            onTap: () => Get.toNamed(AppRoutes.customerPlanListing),
          ),
          _buildQuickActionItem(
            icon: Icons.people_outline,
            label: 'Trainers',
            onTap: () => _showTrainersModal(context),
          ),
          _buildQuickActionItem(
            icon: Icons.sync_alt,
            label: 'My Transactions',
            onTap: () => Get.toNamed(AppRoutes.customerTransactions),
          ),
          _buildQuickActionItem(
            icon: Icons.headset_mic_outlined,
            label: 'Support',
            onTap: () => _showSupportModal(context),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.slateCardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.slateBorder),
            ),
            child: Icon(icon, color: Colors.white70, size: 22),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // --- Rush Hours Card ---
  Widget _buildRushHoursCard(BuildContext context, DashboardV2Controller controller) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slateCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slateBorder),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBright.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.speed_rounded, color: AppColors.primaryBright, size: 18),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Rush Hours Indicator',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.tune_rounded, color: Colors.white54, size: 18),
            ],
          ),

          const SizedBox(height: 14),

          // Interactive Graph
          Obx(() => RushHourChartWidget(
                points: controller.rushHourPoints,
                selectedPoint: controller.selectedHour.value,
                onPointSelected: controller.selectHour,
              )),
        ],
      ),
    );
  }

  // --- Plan Previews ---
  Widget _buildPlanPreviews(BuildContext context) {
    return SizedBox(
      height: 145,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildPlanPreviewCard(
            title: 'Starter Plan',
            price: '₹1,000 / mo',
            users: '100 Max Users',
            color: AppColors.primaryLight,
            isRecommended: true,
          ),
          const SizedBox(width: 12),
          _buildPlanPreviewCard(
            title: 'Business Plan',
            price: '₹3,000 / mo',
            users: '500 Max Users',
            color: AppColors.cyanAccent,
            isRecommended: false,
          ),
          const SizedBox(width: 12),
          _buildPlanPreviewCard(
            title: 'Enterprise Plan',
            price: '₹5,000 / mo',
            users: 'Unlimited Access',
            color: Colors.white,
            isRecommended: false,
          ),
        ],
      ),
    );
  }

  Widget _buildPlanPreviewCard({
    required String title,
    required String price,
    required String users,
    required Color color,
    required bool isRecommended,
  }) {
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.customerPlans),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.slateCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isRecommended ? AppColors.primaryBright : AppColors.slateBorder,
            width: isRecommended ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (isRecommended) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBright,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text('POPULAR', style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.w900)),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(
              price,
              style: TextStyle(color: color, fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(users, style: const TextStyle(color: AppColors.greyMuted, fontSize: 11)),
          ],
        ),
      ),
    );
  }


  void _showTrainersModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.slateCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Supervised Trainers',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTrainerTile('Alex Stone', 'Strength & HIIT Specialist', '4.9 ★ (120 reviews)'),
            const Divider(color: AppColors.slateBorder),
            _buildTrainerTile('Sarah Connor', 'Cardio & Crossfit Trainer', '4.8 ★ (98 reviews)'),
            const Divider(color: AppColors.slateBorder),
            _buildTrainerTile('David Miller', 'Yoga & Flexibility Coach', '4.7 ★ (85 reviews)'),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainerTile(String name, String role, String rating) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.slateCardLight,
            child: Text(name[0], style: const TextStyle(color: AppColors.primaryBright, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(role, style: const TextStyle(color: AppColors.greyMuted, fontSize: 12)),
              ],
            ),
          ),
          Text(rating, style: const TextStyle(color: AppColors.primaryLight, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _showSupportModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.slateCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.slateBorder),
        ),
        title: const Text('Fitness Centre Support', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Need help with your membership or turnstile pass?', style: TextStyle(color: Colors.white70)),
            SizedBox(height: 12),
            Text('📞 Desk Phone: +91 98765 43210', style: TextStyle(color: AppColors.primaryLight)),
            SizedBox(height: 6),
            Text('✉ Email: support@rablofitness.com', style: TextStyle(color: AppColors.cyanAccent)),
            SizedBox(height: 6),
            Text('⏰ Desk Hours: 6:00 AM - 11:00 PM', style: TextStyle(color: Colors.white60)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.primaryBright)),
          ),
        ],
      ),
    );
  }
}
