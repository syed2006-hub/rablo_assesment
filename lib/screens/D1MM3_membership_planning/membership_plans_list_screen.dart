import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import 'plan_overview_screen.dart';

/// D1MM3 – Membership Plans List Screen strictly implementing Figma Row 5
/// with Active, Period-Based, and Monthly plans, and detail card modals.
class MembershipPlansListScreen extends StatefulWidget {
  const MembershipPlansListScreen({super.key});

  @override
  State<MembershipPlansListScreen> createState() =>
      _MembershipPlansListScreenState();
}

class _MembershipPlansListScreenState extends State<MembershipPlansListScreen> {
  final List<Map<String, dynamic>> _plans = [
    {
      'id': 'p1',
      'name': 'Membership Name',
      'type': 'Session-Based Plan',
      'isSessionBased': true,
      'isActive': true,
      'price': '100',
      'period': 'INR / session',
      'sessions': '30 Count',
      'validity': '90 Days',
      'perks': [
        '30 Full Access Training Sessions',
        'Certified Trainer Support on Floor',
        'Locker & Shower Facility Included',
        'Valid for 90 Days across Branches',
      ],
    },
    {
      'id': 'p2',
      'name': 'Membership Name',
      'type': 'Period-Based Plan',
      'isSessionBased': false,
      'isActive': false,
      'price': '5,000',
      'period': 'INR / year',
      'sessions': 'Unlimited',
      'validity': '90 Days',
      'perks': [
        'Unlimited Daily Gym & Cardio Access',
        'Dedicated Personal Locker Allocation',
        'Steam Bath & Sauna Weekly Access',
        'Quarterly Health & Diet Consultation',
      ],
    },
    {
      'id': 'p3',
      'name': 'Monthly Pro Membership',
      'type': 'Period-Based Plan',
      'isSessionBased': false,
      'isActive': false,
      'price': '1,500',
      'period': 'INR / month',
      'sessions': 'Unlimited',
      'validity': '30 Days',
      'perks': [
        'Unlimited Access for 30 Days',
        'Standard Fitness Equipment Access',
        'Locker Facility Included',
      ],
    },
  ];

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
                  Colors.black.withValues(alpha: 0.70),
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
                _buildTopAppBar(context),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Available Memberships',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Select or renew your active membership pass.',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 18),

                            ..._plans.map((p) => _buildPlanTile(p)),

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
                    'Membership Plans',
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

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A42).withValues(alpha: 0.8),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF2E5762)),
            ),
            child: Center(
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {},
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanTile(Map<String, dynamic> p) {
    final isActive = p['isActive'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF163238),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isActive ? AppColors.primaryBright : const Color(0xFF26505A),
          width: isActive ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: () => _showPlanDetailModal(p),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Crown Circular Badge matching Figma
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
                      size: 26,
                    ),
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            p['name'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          if (isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryBright,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p['type'],
                        style: const TextStyle(
                          color: AppColors.primaryBright,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            '₹${p['price']} ${p['period']}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '• ${p['validity']}',
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white38,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FIGMA MODAL CARDS (r5_card1, r5_card2)
  // ============================================================
  void _showPlanDetailModal(Map<String, dynamic> p) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
        decoration: const BoxDecoration(
          color: Color(0xFF163238),
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
          boxShadow: [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 20,
              offset: Offset(0, -6),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white30,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Crown Badge matching Figma
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: AppColors.primaryBright,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: Colors.black,
                  size: 32,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Text(
              p['name'],
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              p['type'],
              style: const TextStyle(
                color: AppColors.primaryBright,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            // Large Price
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  p['price'],
                  style: const TextStyle(
                    color: AppColors.primaryBright,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  p['period'],
                  style: const TextStyle(
                    color: AppColors.primaryBright,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Perks Checklist
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3F47),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF26505A)),
              ),
              child: Column(
                children: (p['perks'] as List<String>).map((perk) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primaryBright,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            perk,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            // Actions: View Full Overview & Select / Recharge
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white30),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      Get.to(() => PlanOverviewScreen(
                            isSessionBased: p['isSessionBased'],
                            isActive: p['isActive'],
                            planName: p['name'],
                          ));
                    },
                    child: const Text('View Overview', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBright,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Get.back();
                      Get.snackbar(
                        'Plan Selected',
                        'Proceeding to recharge / checkout for ${p['name']}',
                        backgroundColor: const Color(0xFF1E3F47),
                        colorText: AppColors.primaryBright,
                      );
                    },
                    child: const Text('Select Plan', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
