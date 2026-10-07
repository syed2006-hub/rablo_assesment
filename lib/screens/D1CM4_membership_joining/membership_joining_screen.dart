import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../controllers/D1CM4_membership_joining/membership_joining_controller.dart';
import '../../widgets/common_button.dart';
import '../../widgets/rush_hour_chart.dart';
import '../../widgets/trainer_bottom_sheet.dart';
import '../../models/D1CM9_dashboard_v2/rush_hour_model.dart';

/// D1CM4 – Membership Joining & Update Screen.
/// Strictly implements DRD specifications for Plan Selection, 2-Hour Preferred Time Slots,
/// Rush Hours Indicator, Plan Overview Tabs, and Payment / Front-desk cash options.
class MembershipJoiningScreen extends StatelessWidget {
  const MembershipJoiningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(MembershipJoiningController());

    return Scaffold(
      backgroundColor: const Color(0xFF0D1B1E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Join / Update Membership',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Current Membership Info Minimal Section (DRD 2.1)
              _buildCurrentMembershipCard(controller),

              const SizedBox(height: 18),

              // 2. Plan Selection Cards Header
              const Text(
                'Available Membership Plans',
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Compare durations, session allocations, and exclusive fitness perks.',
                style: TextStyle(color: Colors.white60, fontSize: 12.5),
              ),
              const SizedBox(height: 14),

              // Plan Cards List
              _buildPlanSelectionCards(controller),

              const SizedBox(height: 22),

              // 3. Preferred Time Slot Selection (2-Hour Range) (DRD 2.1)
              _buildTimeSlotSection(controller),

              const SizedBox(height: 22),

              // 4. Rush Hours Indicator Graph (DRD 2.1: Red=Full, Green=Neutral, Blue=Empty)
              _buildRushHoursSection(),

              const SizedBox(height: 22),

              // 5. Membership Overview & Tabs (Review, Trainers, Key Features, Objective)
              _buildOverviewTabsSection(context, controller),

              const SizedBox(height: 22),

              // 6. Optional Add-On Packages
              _buildAddOnsSection(controller),

              const SizedBox(height: 22),

              // 7. Payment Module (Total = Plan + Transaction + Service Charges)
              _buildPaymentModule(controller),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// Current Membership Info Minimal Section
  Widget _buildCurrentMembershipCard(MembershipJoiningController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF14292E),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF1D3B42),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.verified_user_rounded, color: AppColors.primaryBright, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT MEMBERSHIP STATUS',
                  style: TextStyle(color: Colors.white38, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Obx(() => Text(
                      controller.currentActivePlanName.value,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                    )),
                const SizedBox(height: 2),
                Obx(() => Text(
                      '${controller.remainingDays.value} Days Left • ${controller.remainingSessions.value} Sessions Left',
                      style: const TextStyle(color: AppColors.primaryBright, fontSize: 11.5),
                    )),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBright.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'ACTIVE',
              style: TextStyle(color: AppColors.primaryBright, fontSize: 10.5, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  /// Plan Selection Cards strictly matching the Figma UI reference image
  Widget _buildPlanSelectionCards(MembershipJoiningController controller) {
    return Obx(() {
      if (controller.isLoadingPlans.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(color: AppColors.primaryBright),
          ),
        );
      }

      return Column(
        children: controller.availablePlans.map((plan) {
          final isSelected = controller.selectedPlan.value.id == plan.id;
          final durationLabel = plan.durationMonths == 1
              ? '1 MONTH'
              : plan.durationMonths == 3
                  ? '3 MONTHS'
                  : '12 MONTHS';

          return Padding(
            padding: const EdgeInsets.only(bottom: 14.0),
            child: InkWell(
              onTap: () => controller.selectPlan(plan),
              borderRadius: BorderRadius.circular(18),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: const Color(0xFF13282E),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected ? AppColors.primaryBright : const Color(0xFF244F59),
                    width: isSelected ? 2 : 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primaryBright.withValues(alpha: 0.2),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Hero Banner with gym photography matching Figma
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Stack(
                        children: [
                          SizedBox(
                            height: 105,
                            width: double.infinity,
                            child: Image.asset(
                              'assets/images/card_bg.png',
                              fit: BoxFit.cover,
                              errorBuilder: (ctx, err, st) => Image.asset(
                                'assets/images/welcome_bg.png',
                                fit: BoxFit.cover,
                                errorBuilder: (ctx, err, st) => Container(
                                  color: const Color(0xFF1B3D44),
                                  child: const Center(
                                    child: Icon(Icons.fitness_center_rounded, color: AppColors.primaryBright, size: 40),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Dark gradient overlay
                          Container(
                            height: 105,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.5),
                                  const Color(0xFF13282E),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                          // Top Pills Row: Duration badge + Popular badge + Radio select
                          Positioned(
                            top: 10,
                            left: 12,
                            right: 12,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF14292E).withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.white24),
                                      ),
                                      child: Text(
                                        durationLabel,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                    if (plan.isPopular) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryBright,
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Text(
                                          '🔥 POPULAR',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w900,
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? AppColors.primaryBright : Colors.black45,
                                    border: Border.all(
                                      color: isSelected ? AppColors.primaryBright : Colors.white54,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Center(
                                          child: Icon(Icons.check, size: 16, color: Colors.black),
                                        )
                                      : null,
                                ),
                              ],
                            ),
                          ),
                          // Positioned Plan Name on image banner
                          Positioned(
                            bottom: 8,
                            left: 14,
                            right: 14,
                            child: Text(
                              plan.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Card Body
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${plan.durationMonths * 30} Sessions • ${plan.billingDuration}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Unlimited gym floor access & trainer support',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.45), fontSize: 11),
                                  ),
                                ],
                              ),
                              Text(
                                '₹${plan.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: isSelected ? AppColors.primaryBright : Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Divider(color: Colors.white12, height: 1),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: plan.features.take(4).map((feat) {
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F1E22),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: AppColors.primaryBright, size: 12),
                                    const SizedBox(width: 5),
                                    Text(feat, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }

  /// Preferred Time Slot (2-Hour Range with validation rule)
  Widget _buildTimeSlotSection(MembershipJoiningController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14292E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Preferred Time Slot (2 Hours)',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryBright.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Required', style: TextStyle(color: AppColors.primaryBright, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Select a 2-hour range between gym operating hours (06:00 AM - 10:00 PM).',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 14),

          // Dropdown / Chips for Time Slots
          Obx(() {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: controller.availableTimeSlots.map((slot) {
                final isSelected = controller.selectedTimeSlot.value == slot;
                final isOutOfHours = slot == '11:00 PM - 01:00 AM';
                return InkWell(
                  onTap: () => controller.selectTimeSlot(slot),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primaryBright : const Color(0xFF1D3B42),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isOutOfHours ? Colors.redAccent.withValues(alpha: 0.6) : (isSelected ? AppColors.primaryBright : Colors.white12),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: isSelected ? Colors.black : (isOutOfHours ? Colors.redAccent : Colors.white70),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          slot,
                          style: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  /// Rush Hours Indicator Section (DRD 2.1)
  Widget _buildRushHoursSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14292E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rush Hours Indicator',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              ),
              Row(
                children: [
                  _buildRushLegendDot('Full', Colors.redAccent),
                  const SizedBox(width: 8),
                  _buildRushLegendDot('Neutral', AppColors.primaryBright),
                  const SizedBox(width: 8),
                  _buildRushLegendDot('Empty', Colors.blueAccent),
                ],
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Peak rush occurs between 06:00 PM – 08:30 PM. Booking non-peak slots ensures optimal equipment availability.',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 14),

          // Rush Hour Visual Chart
          RushHourChartWidget(
            points: RushHourDataPoint.getSampleData(),
          ),
        ],
      ),
    );
  }

  Widget _buildRushLegendDot(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      ],
    );
  }

  /// Membership Overview Tabs (Review, Trainers, Key Features, Objective)
  Widget _buildOverviewTabsSection(BuildContext context, MembershipJoiningController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14292E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Membership Overview',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Overview Tabs Bar
          Obx(() {
            return Row(
              children: controller.overviewTabs.map((tab) {
                final isSelected = controller.selectedOverviewTab.value == tab;
                return Expanded(
                  child: InkWell(
                    onTap: () => controller.selectedOverviewTab.value = tab,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected ? AppColors.primaryBright : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        tab,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryBright : Colors.white60,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 14),

          // Dynamic Tab Content
          Obx(() {
            switch (controller.selectedOverviewTab.value) {
              case 'Review':
                return _buildReviewTabContent();
              case 'Trainers':
                return _buildTrainersTabContent(context);
              case 'Key Features':
                return _buildKeyFeaturesTabContent(controller);
              case 'Objective':
                return _buildObjectiveTabContent();
              default:
                return const SizedBox.shrink();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildReviewTabContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 20),
            const SizedBox(width: 4),
            const Text('4.8 / 5.0', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(width: 8),
            Text('(128 verified member reviews)', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: const Color(0xFF0F1E22), borderRadius: BorderRadius.circular(10)),
          child: const Text(
            '“Excellent equipment variety and the trainer support in this plan helped me stay consistent with my fat loss target.” – Rahul K.',
            style: TextStyle(color: Colors.white70, fontSize: 12, fontStyle: FontStyle.italic),
          ),
        ),
      ],
    );
  }

  Widget _buildTrainersTabContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0F1E22),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.touch_app_rounded, color: AppColors.primaryBright, size: 16),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Tap any coach to view full profile, certifications & book personal sessions.',
                  style: TextStyle(color: Colors.white70, fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        _buildTrainerTile(
          context,
          name: 'Rahul Sharma',
          role: 'Master Trainer & Strength Coach',
          expertise: 'CrossFit, Hypertrophy & Conditioning',
          exp: '8+ Yrs',
          completed: 48,
          remaining: 12,
          schedule: 'Mon, Wed, Fri • 07:00 AM - 08:30 AM',
          specs: ['CrossFit & Strength', 'Hypertrophy Training', 'Mobility & Balance', 'Diet & Nutrition'],
          phone: '+91 98765 43210',
        ),
        const SizedBox(height: 8),
        _buildTrainerTile(
          context,
          name: 'Vikram Sharma',
          role: 'Head Olympic Lifting Coach',
          expertise: 'Powerlifting, Strength & Posture',
          exp: '10+ Yrs',
          completed: 62,
          remaining: 14,
          schedule: 'Tue, Thu, Sat • 06:00 PM - 07:30 PM',
          specs: ['Olympic Weightlifting', 'Powerlifting', 'Core Stability', 'Sports Nutrition'],
          phone: '+91 98450 11223',
        ),
        const SizedBox(height: 8),
        _buildTrainerTile(
          context,
          name: 'Ananya Patel',
          role: 'Senior Yoga & Mobility Master',
          expertise: 'Flexibility, Posture & Balance',
          exp: '6+ Yrs',
          completed: 35,
          remaining: 10,
          schedule: 'Daily Morning • 06:00 AM - 07:30 AM',
          specs: ['Hatha Yoga', 'Postural Alignment', 'Breathwork & Recovery', 'Mobility Flows'],
          phone: '+91 91234 56789',
        ),
      ],
    );
  }

  Widget _buildTrainerTile(
    BuildContext context, {
    required String name,
    required String role,
    required String expertise,
    required String exp,
    required int completed,
    required int remaining,
    required String schedule,
    required List<String> specs,
    required String phone,
  }) {
    final trainerData = {
      'id': 'tr_${name.replaceAll(' ', '_').toLowerCase()}',
      'name': name,
      'role': role,
      'specialty': expertise,
      'rating': 4.9,
      'reviewsCount': '128',
      'experience': exp,
      'sessionsCompleted': completed,
      'sessionsRemaining': remaining,
      'schedule': schedule,
      'slot': 'Studio 1 • Personal Training Zone',
      'phone': phone,
      'specializations': specs,
    };

    return InkWell(
      onTap: () => TrainerBottomSheet.show(context, trainerData: trainerData),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1E22),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF244F59)),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFF1D3B42),
                  child: Text(
                    name[0],
                    style: const TextStyle(
                      color: AppColors.primaryBright,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF22C55E),
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF0F1E22), width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBright.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('COACH', style: TextStyle(color: AppColors.primaryBright, fontSize: 9, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(role, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                  const SizedBox(height: 2),
                  Text(expertise, style: const TextStyle(color: AppColors.primaryBright, fontSize: 11)),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF163238),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF244F59)),
              ),
              child: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.primaryBright, size: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyFeaturesTabContent(MembershipJoiningController controller) {
    return Obx(() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: controller.selectedPlan.value.features.map((feat) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.primaryBright, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(feat, style: const TextStyle(color: Colors.white70, fontSize: 12.5))),
              ],
            ),
          );
        }).toList(),
      );
    });
  }

  Widget _buildObjectiveTabContent() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Target Objectives:',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        SizedBox(height: 6),
        Text('• Fat Loss & Metabolic Conditioning', style: TextStyle(color: Colors.white70, fontSize: 12)),
        Text('• Lean Muscle Toning & Strength Building', style: TextStyle(color: Colors.white70, fontSize: 12)),
        Text('• Cardiovascular Endurance & Flexibility', style: TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }

  /// Add-on Packages
  Widget _buildAddOnsSection(MembershipJoiningController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF14292E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Optional Add-On Packages',
            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Enhance your membership with specialized training or recovery perks.',
            style: TextStyle(color: Colors.white60, fontSize: 12),
          ),
          const SizedBox(height: 12),

          Obx(() {
            return Column(
              children: controller.addOnPrices.entries.map((entry) {
                final isSelected = controller.selectedAddOns.contains(entry.key);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: InkWell(
                    onTap: () => controller.toggleAddOn(entry.key),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF1B3D44) : const Color(0xFF112327),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primaryBright : Colors.white10,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                color: isSelected ? AppColors.primaryBright : Colors.white38,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(entry.key, style: const TextStyle(color: Colors.white, fontSize: 12.5)),
                            ],
                          ),
                          Text('+₹${entry.value.toStringAsFixed(0)}', style: const TextStyle(color: AppColors.primaryBright, fontWeight: FontWeight.bold, fontSize: 12.5)),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  /// Payment Module (Online Card / Front Desk Cash)
  Widget _buildPaymentModule(MembershipJoiningController controller) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF14292E),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment Breakdown',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Total Calculation Breakdown (DRD: Plan charge + transaction charges + service charges)
          Obx(() {
            return Column(
              children: [
                _buildPriceRow('Plan Fee (${controller.selectedPlan.value.name})', '₹${controller.subtotal.toStringAsFixed(2)}'),
                if (controller.addOnsTotal > 0)
                  _buildPriceRow('Add-On Packages', '₹${controller.addOnsTotal.toStringAsFixed(2)}'),
                _buildPriceRow('Transaction Charges', '₹${controller.transactionCharge.toStringAsFixed(2)}'),
                _buildPriceRow('Service Charges', '₹${controller.serviceCharge.toStringAsFixed(2)}'),
                const Divider(color: Colors.white24, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Amount', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      '₹${controller.grandTotal.toStringAsFixed(2)}',
                      style: const TextStyle(color: AppColors.primaryBright, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            );
          }),

          const SizedBox(height: 18),

          // Payment Method Selector (Card or Front Desk Cash)
          const Text('Payment Method', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          Obx(() {
            return Row(
              children: [
                Expanded(
                  child: _buildPaymentMethodTile(
                    controller: controller,
                    method: 'Online Card',
                    icon: Icons.credit_card,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildPaymentMethodTile(
                    controller: controller,
                    method: 'Cash at Desk',
                    icon: Icons.point_of_sale,
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 20),

          // Pay CTA
          Obx(() {
            final isCash = controller.selectedPaymentMethod.value == 'Cash at Desk';
            return CommonButton(
              text: isCash ? 'Queue Cash Payment & Join' : 'Pay & Join (₹${controller.grandTotal.toStringAsFixed(0)})',
              backgroundColor: AppColors.primaryBright,
              textColor: Colors.black,
              isLoading: controller.isProcessingPayment.value,
              onPressed: controller.processPayment,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String amount) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
          Text(amount, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile({
    required MembershipJoiningController controller,
    required String method,
    required IconData icon,
  }) {
    final isSelected = controller.selectedPaymentMethod.value == method;
    return InkWell(
      onTap: () => controller.selectedPaymentMethod.value = method,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1D3B42) : const Color(0xFF112327),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryBright : Colors.white12,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? AppColors.primaryBright : Colors.white54, size: 22),
            const SizedBox(height: 6),
            Text(
              method,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
