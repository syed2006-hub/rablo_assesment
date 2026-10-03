import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../controllers/D1MM3_membership_planning/plan_management_controller.dart';
import '../../widgets/plan_comparison_table.dart';

/// D1MM3 – Subscription Plans & Offerings Comparison Screen.
/// Strictly implements Figma `D1MM3 Membership Management Subscription Plans Starter.png` and `D1MM3 Plan Listing Page.png`.
class SubscriptionPlansScreen extends StatelessWidget {
  const SubscriptionPlansScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PlanManagementController());

    return Scaffold(
      backgroundColor: AppColors.slateScaffold,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'My Plan',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: AppColors.slateCardLight,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.slateBorder),
            ),
            child: Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.badgeBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Text('4', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header matching Figma typography
            const Text.rich(
              TextSpan(
                text: 'Manage ',
                style: TextStyle(
                  color: AppColors.primaryLight,
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
                children: [
                  TextSpan(
                    text: 'Your Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Design your Membership as you wish.',
              style: TextStyle(color: AppColors.greyMuted, fontSize: 14),
            ),

            const SizedBox(height: 18),

            // Two KPI Cards (Active vs Pending)
            _buildKpiRow(),

            const SizedBox(height: 20),

            // Monthly vs Quarterly Segmented Switcher
            _buildBillingSwitcher(controller),

            const SizedBox(height: 18),

            // Plan Cards Carousel
            _buildPlanCardsCarousel(controller),

            const SizedBox(height: 16),

            // Switch to Individual Plan Checkbox
            Obx(() => GestureDetector(
                  onTap: () => controller.toggleAutoSwitch(!controller.autoSwitchToIndividual.value),
                  child: Row(
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: controller.autoSwitchToIndividual.value ? AppColors.primaryBright : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: controller.autoSwitchToIndividual.value ? AppColors.primaryBright : AppColors.greyMuted,
                            width: 1.5,
                          ),
                        ),
                        child: controller.autoSwitchToIndividual.value
                            ? const Icon(Icons.check, color: Colors.black, size: 16)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text.rich(
                          TextSpan(
                            text: 'Do you wish to switch to ',
                            style: TextStyle(color: Colors.white70, fontSize: 12),
                            children: [
                              TextSpan(
                                text: 'Individual Plan ',
                                style: TextStyle(color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: 'if user limit exceeds?'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

            const SizedBox(height: 20),

            // "Pay Now" Neon Green Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBright,
                  foregroundColor: Colors.black,
                  elevation: 6,
                  shadowColor: AppColors.primaryBright.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => controller.executePayment(context),
                child: Obx(() => Text(
                      'Pay Now (₹${controller.currentPrice})',
                      style: const TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900),
                    )),
              ),
            ),

            const SizedBox(height: 8),

            const Center(
              child: Text(
                'Billed Monthly, Cancel Anytime.',
                style: TextStyle(color: AppColors.greyMuted, fontSize: 11),
              ),
            ),

            const SizedBox(height: 24),

            // Offerings Comparison Matrix Table
            Obx(() => PlanComparisonTableWidget(
                  rows: controller.comparisonRows,
                  activeColumn: controller.selectedPlanId.value,
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiRow() {
    return Row(
      children: [
        // Card 1: 365 Active Members
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E3A20),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.groups, color: AppColors.primaryBright, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text('Members', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text.rich(
                  TextSpan(
                    text: '365 ',
                    style: TextStyle(color: AppColors.primaryLight, fontSize: 24, fontWeight: FontWeight.w900),
                    children: [
                      TextSpan(text: 'Active', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text('↓ 2.1% vs last 7 days Avg.', style: TextStyle(color: AppColors.peakRed, fontSize: 10)),
              ],
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Card 2: 15 Pending New Members
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
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color(0xFF173642),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person_add, color: AppColors.cyanAccent, size: 16),
                    ),
                    const SizedBox(width: 8),
                    const Text('New Members', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 10),
                const Text.rich(
                  TextSpan(
                    text: '15 ',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900),
                    children: [
                      TextSpan(text: 'Pending', style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text('Activate Now >', style: TextStyle(color: AppColors.primaryLight, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBillingSwitcher(PlanManagementController controller) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.slateCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.slateBorder),
      ),
      child: Obx(() {
        final isMonthly = controller.billingPeriod.value == BillingPeriod.monthly;
        return Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.setBillingPeriod(BillingPeriod.monthly),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: isMonthly ? const Color(0xFFE2F0F3) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Monthly',
                      style: TextStyle(
                        color: isMonthly ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(width: 1, height: 20, color: AppColors.slateBorder),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.setBillingPeriod(BillingPeriod.quarterly),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: !isMonthly ? const Color(0xFFE2F0F3) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Quarterly',
                      style: TextStyle(
                        color: !isMonthly ? Colors.black : Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildPlanCardsCarousel(PlanManagementController controller) {
    return SizedBox(
      height: 210,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildPlanOptionCard(
            controller: controller,
            planId: 'business',
            title: 'Business',
            icon: Icons.military_tech_rounded,
            price: '3000',
            userLimit: '500 Max. User Limit',
          ),
          const SizedBox(width: 12),
          _buildPlanOptionCard(
            controller: controller,
            planId: 'starter',
            title: 'Starter',
            icon: Icons.person_outline,
            price: '1000',
            userLimit: '100 Max. User Limit',
          ),
          const SizedBox(width: 12),
          _buildPlanOptionCard(
            controller: controller,
            planId: 'enterprise',
            title: 'Enterprise',
            icon: Icons.business,
            price: '5000',
            userLimit: 'Unlimited User Limit',
          ),
        ],
      ),
    );
  }

  Widget _buildPlanOptionCard({
    required PlanManagementController controller,
    required String planId,
    required String title,
    required IconData icon,
    required String price,
    required String userLimit,
  }) {
    return Obx(() {
      final isSelected = controller.selectedPlanId.value == planId;
      return GestureDetector(
        onTap: () => controller.selectPlan(planId),
        child: Container(
          width: 165,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF264731) : AppColors.slateCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSelected ? AppColors.primaryBright : AppColors.slateBorder,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryBright.withValues(alpha: 0.25),
                      blurRadius: 10,
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryBright.withValues(alpha: 0.2) : AppColors.slateCardLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: isSelected ? AppColors.primaryBright : Colors.white70, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(
                  text: '₹ ',
                  style: TextStyle(
                    color: isSelected ? AppColors.primaryLight : Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: price,
                      style: TextStyle(
                        color: isSelected ? AppColors.primaryLight : Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const TextSpan(
                      text: ' Per Month',
                      style: TextStyle(color: AppColors.greyMuted, fontSize: 10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Container(height: 1, color: AppColors.slateBorder),
              const SizedBox(height: 6),
              Text(
                userLimit,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryLight : AppColors.greyMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
