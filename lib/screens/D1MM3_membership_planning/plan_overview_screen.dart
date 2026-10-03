import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../widgets/plan/plan_reviews_card.dart';
import '../../widgets/plan/plan_usage_card.dart';

/// D1MM3 – Plan Overview & Details Screen strictly matching Figma
/// `media_1790870927418.png`, `media_1790870927472.png`, and `media_1790870928333.png`.
class PlanOverviewScreen extends StatefulWidget {
  final bool isSessionBased;
  final bool isActive;
  final String planName;
  final String gymName;

  const PlanOverviewScreen({
    super.key,
    this.isSessionBased = false,
    this.isActive = true,
    this.planName = 'Membership Name',
    this.gymName = 'Gym/Fitness Centre',
  });

  @override
  State<PlanOverviewScreen> createState() => _PlanOverviewScreenState();
}

class _PlanOverviewScreenState extends State<PlanOverviewScreen> {
  int _activeTabIndex = 0; // 0: Reviews, 1: Key Features, 2: Objective

  late bool _isSessionBased;
  late String _planName;

  @override
  void initState() {
    super.initState();
    _isSessionBased = widget.isSessionBased;
    _planName = widget.planName;
  }

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
                // Top App Bar
                _buildTopAppBar(),

                // Scrollable Body
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Membership Header Card
                            _buildMembershipHeaderCard(),

                            const SizedBox(height: 14),

                            // 2. Action Buttons (Edit + Recharge) on Period-Based Plan
                            if (!_isSessionBased) ...[
                              _buildPeriodActionButtons(),
                              const SizedBox(height: 14),
                            ],

                            // 3. Stats Banner Card (3 Columns)
                            _buildStatsCard(),

                            const SizedBox(height: 14),

                            // 4. USAGE Card (for Session-Based Plan)
                            if (_isSessionBased) ...[
                              PlanUsageCard(
                                sessionsRemaining: 29,
                                totalSessions: 30,
                                daysRemaining: 80,
                                totalDays: 90,
                                redemptionsRemaining: 0,
                                totalRedemptions: 1,
                                onTrackUsage: _showTrackUsageSheet,
                                onBuySession: _showBuySessionSheet,
                              ),
                              const SizedBox(height: 14),
                            ],

                            // 5. Segmented Tabs Bar (Reviews | Key Features | Objective)
                            _buildSegmentedTabBar(),

                            const SizedBox(height: 14),

                            // 6. Active Tab Content
                            _buildActiveTabContent(),

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

  Widget _buildTopAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Colors.white,
              size: 20,
            ),
            onPressed: () => Get.back(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Plan Overview',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    letterSpacing: -0.2,
                  ),
                ),
                Text(
                  widget.gymName,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 40), // Balance leading back button
        ],
      ),
    );
  }

  Widget _buildMembershipHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF163238),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF26505A),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active Tag & Badge for Active Session Plan
          if (widget.isActive && _isSessionBased) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'ACTIVE PLAN',
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBright,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],

          Row(
            children: [
              // Lime Green Circular Badge with Crown
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBright,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.workspace_premium_rounded,
                    color: Colors.black,
                    size: 28,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _planName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        fontStyle: FontStyle.italic,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isSessionBased
                          ? 'Session-Based Plan'
                          : 'Period-Based Plan',
                      style: const TextStyle(
                        color: AppColors.primaryBright,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodActionButtons() {
    return Row(
      children: [
        // Outlined Edit Button (Square)
        InkWell(
          onTap: _showEditPlanSheet,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF163238),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white24, width: 1.2),
            ),
            child: const Center(
              child: Icon(
                Icons.edit_outlined,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Recharge Button (Wide Solid Lime)
        Expanded(
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBright,
                foregroundColor: Colors.black,
                elevation: 3,
                shadowColor: AppColors.primaryBright.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _showRechargeSheet,
              child: const Text(
                'Recharge',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF163238),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF26505A),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: _isSessionBased
            ? [
                _buildStatItem('30', 'Count', 'Sessions'),
                Container(width: 1, height: 36, color: Colors.white24),
                _buildStatItem('90', 'Days', 'Validity'),
                Container(width: 1, height: 36, color: Colors.white24),
                _buildStatItem('100', 'INR', 'Per Session'),
              ]
            : [
                _buildStatItem('Unlimited', '', 'Sessions'),
                Container(width: 1, height: 36, color: Colors.white24),
                _buildStatItem('90', 'Days', 'Validity'),
                Container(width: 1, height: 36, color: Colors.white24),
                _buildStatItem('5,000', 'INR', 'Per Year'),
              ],
      ),
    );
  }

  Widget _buildStatItem(String val, String unit, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              val,
              style: const TextStyle(
                color: AppColors.primaryBright,
                fontSize: 22,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 3),
              Text(
                unit,
                style: const TextStyle(
                  color: AppColors.primaryBright,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  List<String> get _currentTabs => _isSessionBased
      ? const ['Reviews', 'Trainers', 'Key Features']
      : const ['Reviews', 'Key Features', 'Objective'];

  Widget _buildSegmentedTabBar() {
    final tabs = _currentTabs;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF163238),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF26505A)),
      ),
      child: Row(
        children: List.generate(tabs.length, (idx) {
          final isSelected = _activeTabIndex == idx;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _activeTabIndex = idx;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFE2F0F3) // Light cyan/white pill
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    tabs[idx],
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildActiveTabContent() {
    final tabs = _currentTabs;
    final activeIndex = _activeTabIndex.clamp(0, tabs.length - 1);
    final activeTab = tabs[activeIndex];

    switch (activeTab) {
      case 'Reviews':
        return const PlanReviewsCard(
          totalReviews: 432,
          averageRating: 4.0,
        );
      case 'Trainers':
        return _buildTrainersGrid();
      case 'Key Features':
        return _buildKeyFeaturesGrid();
      case 'Objective':
      default:
        return _buildObjectiveGrid();
    }
  }

  Widget _buildKeyFeaturesGrid() {
    final features = [
      'Strength Training',
      'Cardio Training',
      'Group Fitness',
      'Nutritional Coaching',
      'Nutritional Guidance',
      'Locker & Steam Bath',
      'Personal Trainer Assistance',
      'Dedicated Hydration Station',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF163238),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF26505A),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Included Key Features',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: features.map((feat) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3F47),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  feat,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildObjectiveGrid() {
    final objectives = [
      'General Fitness & Wellness',
      'Weight Gain',
      'Muscle Gain',
      'Fat Loss',
      'Rehabilitation & Recovery',
      'Endurance Building',
      'Athletic Conditioning',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF163238),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF26505A),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Target Objectives & Goals',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: objectives.map((obj) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3F47),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white12),
                ),
                child: Text(
                  obj,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTrainersGrid() {
    final trainers = [
      {
        'name': 'Rahul Sharma',
        'role': 'Master Trainer & Strength Coach',
        'rating': '4.9 ★',
        'experience': '8+ yrs exp',
        'specialty': 'CrossFit & Muscle Building',
      },
      {
        'name': 'Priya Patel',
        'role': 'Mobility & Conditioning Specialist',
        'rating': '4.8 ★',
        'experience': '5+ yrs exp',
        'specialty': 'HIIT & Functional Fitness',
      },
      {
        'name': 'Ankit Verma',
        'role': 'Senior Rehab & Fitness Coach',
        'rating': '4.9 ★',
        'experience': '6+ yrs exp',
        'specialty': 'Weight Loss & Rehabilitation',
      },
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF163238),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFF26505A),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Assigned Trainers',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryBright.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.4)),
                ),
                child: const Text(
                  '3 Certified',
                  style: TextStyle(
                    color: AppColors.primaryBright,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...trainers.map((t) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3F47),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primaryBright,
                    child: Text(
                      t['name']!.substring(0, 1),
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              t['name']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            Text(
                              t['rating']!,
                              style: const TextStyle(
                                color: AppColors.primaryBright,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t['role']!,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          t['specialty']!,
                          style: const TextStyle(
                            color: Color(0xFF3B9AB2),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ==========================================
  // INTERACTIVE MODALS & BOTTOM SHEETS
  // ==========================================

  void _showRechargeSheet() {
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
              'Select duration to recharge your plan instantly',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildRechargeOption('Yearly Renewal', '₹5,000 /year', 'Best Value (Save 30%)'),
            const SizedBox(height: 10),
            _buildRechargeOption('Quarterly Plan', '₹2,400 /3 months', 'Popular Choice'),
            const SizedBox(height: 10),
            _buildRechargeOption('Monthly Pass', '₹1,000 /month', 'Flexible Standard'),
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
                    'Recharge Successful',
                    'Your membership has been renewed for 1 Year!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF163238),
                    colorText: AppColors.primaryBright,
                  );
                },
                child: const Text(
                  'Confirm & Pay Now',
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

  Widget _buildRechargeOption(String title, String price, String badge) {
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

  void _showBuySessionSheet() {
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
              'Buy Additional Workout Sessions',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Add extra sessions to your active pass at ₹100/session',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildRechargeOption('10 Workout Sessions', '₹1,000', '+2 Bonus Sessions'),
            const SizedBox(height: 10),
            _buildRechargeOption('5 Workout Sessions', '₹500', 'Standard Top-Up'),
            const SizedBox(height: 10),
            _buildRechargeOption('1 Single Pass', '₹100', 'Quick Entry'),
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
                    'Sessions Added!',
                    '10 additional workout sessions added to your active pass.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF163238),
                    colorText: AppColors.primaryBright,
                  );
                },
                child: const Text(
                  'Add Sessions to Pass',
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

  void _showTrackUsageSheet() {
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
              'Session Check-In History',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Recent attendance & turnstile entry records',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 16),
            _buildHistoryItem('Gold\'s Gym Arena - Indiranagar', 'Today, 08:15 AM', 'Session 1 / 30'),
            const SizedBox(height: 10),
            _buildHistoryItem('Gold\'s Gym Arena - Indiranagar', 'Yesterday, 07:30 PM', 'Session 2 / 30'),
            const SizedBox(height: 10),
            _buildHistoryItem('Gold\'s Gym Arena - Indiranagar', '28 Sep 2024, 08:00 AM', 'Session 3 / 30'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white38),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () => Get.back(),
                child: const Text('Close', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildHistoryItem(String branch, String time, String sessionNum) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3F47),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                branch,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                time,
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
          Text(
            sessionNum,
            style: const TextStyle(
              color: AppColors.primaryBright,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditPlanSheet() {
    final editController = TextEditingController(text: _planName);

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
              'Edit Plan Preferences',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: editController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Plan Nickname',
                labelStyle: const TextStyle(color: Colors.white70),
                filled: true,
                fillColor: const Color(0xFF1E3F47),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBright,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _planName = editController.text.trim().isNotEmpty
                        ? editController.text.trim()
                        : _planName;
                  });
                  Get.back();
                  Get.snackbar(
                    'Plan Updated',
                    'Plan preferences updated successfully.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: const Color(0xFF163238),
                    colorText: AppColors.primaryBright,
                  );
                },
                child: const Text(
                  'Save Changes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
