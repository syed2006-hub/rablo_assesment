import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';

/// D1CM4 – Webpage Plans Screen.
/// Strictly implements Webpage Plans Page 1.
class WebpagePlansScreen extends StatefulWidget {
  const WebpagePlansScreen({super.key});

  @override
  State<WebpagePlansScreen> createState() => _WebpagePlansScreenState();
}

class _WebpagePlansScreenState extends State<WebpagePlansScreen> {
  String _selectedPlan = 'business';

  @override
  Widget build(BuildContext context) {
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
            const Text(
              'Build Your Webpage',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Choose your Web Presence Plan',
              style: TextStyle(color: AppColors.greyMuted, fontSize: 14),
            ),

            const SizedBox(height: 20),

            // Plan Options Carousel
            SizedBox(
              height: 160,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildWebPlanCard(
                    id: 'trial',
                    icon: Icons.track_changes,
                    title: 'Trial',
                    price: 'FREE',
                    period: 'For 1 Month',
                    subtext: 'No Auto Renewal',
                  ),
                  const SizedBox(width: 12),
                  _buildWebPlanCard(
                    id: 'business',
                    icon: Icons.military_tech_rounded,
                    title: 'Business',
                    price: '400',
                    period: 'Per Month',
                    subtext: 'Billed Quarterly',
                  ),
                  const SizedBox(width: 12),
                  _buildWebPlanCard(
                    id: 'starter',
                    icon: Icons.person_outline,
                    title: 'Starter',
                    price: '500',
                    period: '/Month',
                    subtext: 'Billed Monthly',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Terms Disclaimer
            Row(
              children: const [
                Icon(Icons.info_outline, color: AppColors.greyMuted, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "By clicking the Update button, you'll agree to the T&C.",
                    style: TextStyle(color: AppColors.greyMuted, fontSize: 11.5),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Neon Green Pay Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBright,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 6,
                  shadowColor: AppColors.primaryBright.withValues(alpha: 0.5),
                ),
                onPressed: () {
                  Get.snackbar(
                    'Web Presence Activated',
                    'Your branded gym webpage has been published at rablofitness.com/fit-centre',
                    backgroundColor: AppColors.slateCard,
                    colorText: AppColors.primaryLight,
                  );
                },
                child: Text(
                  _selectedPlan == 'trial' ? 'Start Free Trial' : 'Pay 1200/-',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Center(
              child: Text(
                'Billed Quarterly, Cancel Anytime.',
                style: TextStyle(color: AppColors.greyMuted, fontSize: 11),
              ),
            ),

            const SizedBox(height: 24),

            _buildWebMatrix(),
          ],
        ),
      ),
    );
  }

  Widget _buildWebPlanCard({
    required String id,
    required IconData icon,
    required String title,
    required String price,
    required String period,
    required String subtext,
  }) {
    final isSelected = _selectedPlan == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = id),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(14),
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
            Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            Text.rich(
              TextSpan(
                text: price == 'FREE' ? 'FREE ' : '$price ',
                style: TextStyle(
                  color: isSelected ? AppColors.primaryLight : Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
                children: [
                  TextSpan(
                    text: period,
                    style: const TextStyle(color: AppColors.greyMuted, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Container(height: 1, color: AppColors.slateBorder),
            const SizedBox(height: 6),
            Text(
              subtext,
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
  }

  Widget _buildWebMatrix() {
    final rows = [
      {'name': 'Validity', 'trial': '30 Days', 'business': '30 Days', 'starter': '30 Days'},
      {'name': 'Key Services Promoted', 'trial': 'Up to 1', 'business': 'Unlimited', 'starter': 'Up to 3'},
      {'name': 'Membership Promoted', 'trial': 'Up to 1', 'business': 'Unlimited', 'starter': 'Up to 3'},
      {'name': 'Custom Branding', 'trial': '-', 'business': '✔', 'starter': '-'},
      {'name': "Trainer's Profile Building", 'trial': '-', 'business': 'Up to 6', 'starter': 'Up to 6'},
      {'name': 'Contact Options', 'trial': 'Basic', 'business': 'Advance', 'starter': 'Advance'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.slateCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slateBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(
                flex: 4,
                child: Text('Offerings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
              ),
              const Expanded(
                flex: 2,
                child: Center(child: Text('Trial', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12))),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBright.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.6)),
                  ),
                  child: const Center(
                    child: Text('Business', style: TextStyle(color: AppColors.primaryBright, fontWeight: FontWeight.w900, fontSize: 12)),
                  ),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Center(child: Text('Starter', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12))),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.slateBorder),
          ...rows.map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Text(r['name']!, style: const TextStyle(color: AppColors.greyMuted, fontSize: 11.5)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(child: Text(r['trial']!, style: const TextStyle(color: Colors.white70, fontSize: 11))),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBright.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Center(
                          child: Text(
                            r['business']!,
                            style: TextStyle(
                              color: r['business'] == '✔' ? AppColors.cyanAccent : AppColors.primaryLight,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(child: Text(r['starter']!, style: const TextStyle(color: Colors.white70, fontSize: 11))),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
