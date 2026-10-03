import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../widgets/plan/active_plan_card.dart';
import '../../widgets/plan/period_based_plan_card.dart';
import 'plan_overview_screen.dart';

/// D1MM3 – Customer My Plan Screen strictly matching Figma `media_1790870927298.png`.
class PlanListingScreen extends StatelessWidget {
  const PlanListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Trainer image with gradient overlay
          Image.asset(
            'assets/images/welcome_bg.png',
            fit: BoxFit.cover,
            alignment: Alignment.topCenter,
            errorBuilder: (ctx, err, st) =>
                Container(color: const Color(0xFF0F262B)),
          ),

          // Deep Dark Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.65),
                  const Color(0xE60D1E22),
                  const Color(0xF210282E),
                  const Color(0xFA0B1B1F),
                  Colors.black,
                ],
                stops: const [0.0, 0.25, 0.55, 0.82, 1.0],
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Top App Bar: < My Plan (left) & Bell + Menu (right)
                _buildTopAppBar(context),

                // Main Scrollable Plan List
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Active Plan Card (Session-Based) matching Figma
                            ActivePlanCard(
                              planName: 'Membership Name',
                              planType: 'Session-Based',
                              sessionCount: 30,
                              validityDays: 90,
                              pricePerSession: 100,
                              onViewDetails: () {
                                Get.to(() => const PlanOverviewScreen(
                                      isSessionBased: true,
                                      isActive: true,
                                      planName: 'Membership Name',
                                    ));
                              },
                            ),

                            const SizedBox(height: 18),

                            // Thin Divider Line matching Figma
                            Container(
                              height: 1,
                              color: Colors.white.withValues(alpha: 0.2),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                            ),

                            const SizedBox(height: 18),

                            // 2. Period-Based Plan Card matching Figma
                            PeriodBasedPlanCard(
                              planName: 'Membership Name',
                              price: '5,000',
                              period: '/year',
                              objectives: const [
                                'General Fitness & Wellness',
                                'Weight Gain',
                                'Muscle Gain',
                                'Fat Loss',
                                'Rehabilitation & Recovery',
                              ],
                              features: const [
                                'Full Gym & Cardio Equipment Access',
                                'Strength & Free Weights Zone',
                                'Locker & Steam Bath Access',
                                'Quarterly Nutrition Guidance Call',
                                'Dedicated Locker Facility',
                              ],
                              onViewDetails: () {
                                Get.to(() => const PlanOverviewScreen(
                                      isSessionBased: false,
                                      isActive: false,
                                      planName: 'Membership Name',
                                    ));
                              },
                              onRecharge: () => _showRechargeModal(context),
                            ),

                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button + "My Plan" title
          InkWell(
            onTap: () => Get.back(),
            borderRadius: BorderRadius.circular(10),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 4, horizontal: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 18,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'My Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Controls: Bell badge + More Options
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: const Color(0xFF163238),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white12),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        padding: const EdgeInsets.all(3.5),
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B9AB2),
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          '4',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showRechargeModal(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        decoration: const BoxDecoration(
          color: Color(0xFF163238),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recharge Membership',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose your renewal package to keep training active',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildOptionRow('1 Year Period Pass', '₹5,000 /year', 'Best Value'),
            const SizedBox(height: 10),
            _buildOptionRow('3 Months Period Pass', '₹2,400 /quarter', 'Popular'),
            const SizedBox(height: 10),
            _buildOptionRow('1 Month Period Pass', '₹1,000 /month', 'Flexible'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBright,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Get.back();
                  Get.snackbar(
                    'Recharge Confirmed',
                    'Your membership has been recharged successfully!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF163238),
                    colorText: AppColors.primaryBright,
                  );
                },
                child: const Text(
                  'Confirm & Recharge',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildOptionRow(String title, String price, String badge) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3F47),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                badge,
                style: const TextStyle(
                  color: AppColors.primaryBright,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Text(
            price,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
