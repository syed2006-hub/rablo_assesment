import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';

/// Reusable Trainer Bottom Sheet strictly matching the Figma UI image:
/// - Drag handle
/// - Trainer Header Card with Avatar, Online status dot, Name, Title, and Star Rating
/// - 3 Stat Badges: Experience (8+ Yrs), Sessions Done (48), Sessions Left (12)
/// - Specialization tags
/// - Training Schedule card
/// - Call, Chat, and Big Bright Neon Green "Book Session" CTA
class TrainerBottomSheet extends StatelessWidget {
  final Map<String, dynamic> trainer;

  const TrainerBottomSheet({
    super.key,
    required this.trainer,
  });

  static Future<void> show(BuildContext context, {Map<String, dynamic>? trainerData}) {
    final defaultTrainer = {
      'id': 'tr_1',
      'name': 'Rahul Sharma',
      'role': 'Master Trainer & Strength Coach',
      'specialty': 'CrossFit, Hypertrophy & Athletic Conditioning',
      'rating': 4.9,
      'reviewsCount': '128',
      'experience': '8+ Yrs',
      'sessionsCompleted': 48,
      'sessionsRemaining': 12,
      'schedule': 'Mon, Wed, Fri • 07:00 AM - 08:30 AM',
      'slot': 'Morning Peak Slot • Studio 1',
      'phone': '+91 98765 43210',
      'bio': 'Certified Olympic Lifting Coach with 8+ years coaching national athletes and bodybuilding enthusiasts.',
      'specializations': [
        'CrossFit & Strength',
        'Hypertrophy Training',
        'Mobility & Balance',
        'Diet & Nutrition',
      ],
    };

    final finalData = trainerData ?? defaultTrainer;

    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TrainerBottomSheet(trainer: finalData),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = trainer['name']?.toString() ?? 'Rahul Sharma';
    final role = trainer['role']?.toString() ?? 'Master Trainer & Strength Coach';
    final rating = trainer['rating']?.toString() ?? '4.9';
    final reviewsCount = trainer['reviewsCount']?.toString() ?? '128';
    final experience = trainer['experience']?.toString() ?? '8+ Yrs';
    final sessionsCompleted = trainer['sessionsCompleted']?.toString() ?? '48';
    final sessionsRemaining = trainer['sessionsRemaining']?.toString() ?? '12';
    final schedule = trainer['schedule']?.toString() ?? 'Mon, Wed, Fri • 07:00 AM - 08:30 AM';
    final slot = trainer['slot']?.toString() ?? 'Morning Peak Slot • Studio 1';
    final specializations = (trainer['specializations'] as List?)?.map((e) => e.toString()).toList() ?? [
      'CrossFit & Strength',
      'Hypertrophy Training',
      'Mobility & Balance',
      'Diet & Nutrition',
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: Color(0xFF14292E), // Exact dark slate cyan from Figma
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        border: Border(
          top: BorderSide(color: Color(0xFF244F59), width: 1.5),
          left: BorderSide(color: Color(0xFF244F59), width: 1.5),
          right: BorderSide(color: Color(0xFF244F59), width: 1.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Top Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // 2. Title & Status Pill Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBright.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          color: AppColors.primaryBright,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Trainer Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF17382B),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primaryBright.withValues(alpha: 0.6),
                            width: 1,
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified_rounded, color: AppColors.primaryBright, size: 13),
                            SizedBox(width: 4),
                            Text(
                              'Certified Coach',
                              style: TextStyle(
                                color: AppColors.primaryBright,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        icon: const Icon(Icons.close_rounded, color: Colors.white70, size: 20),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 3. Hero Trainer Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1B3D44), Color(0xFF12272B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFF2E6370), width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Avatar with online green dot
                    Stack(
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.primaryBright, width: 2),
                            color: const Color(0xFF14292E),
                          ),
                          child: Center(
                            child: Text(
                              name.isNotEmpty ? name[0] : 'T',
                              style: const TextStyle(
                                color: AppColors.primaryBright,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          right: 2,
                          bottom: 2,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: const Color(0xFF22C55E),
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF14292E), width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Trainer Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            role,
                            style: const TextStyle(
                              color: AppColors.primaryBright,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.star_rounded, color: Colors.amber, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                rating,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '($reviewsCount Reviews)',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.6),
                                  fontSize: 11.5,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 4. Three Quick Stats Badges
              Row(
                children: [
                  Expanded(
                    child: _buildStatBadge(
                      title: experience,
                      label: 'Experience',
                      textColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatBadge(
                      title: sessionsCompleted,
                      label: 'Completed',
                      textColor: AppColors.primaryBright,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatBadge(
                      title: sessionsRemaining,
                      label: 'Remaining',
                      textColor: const Color(0xFF38BDF8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // 5. Specializations Section
              const Text(
                'SPECIALIZATIONS',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: specializations.map((spec) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF13282D),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF244F59),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primaryBright,
                          size: 13,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          spec,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),

              // 6. Training Schedule Card
              const Text(
                'TRAINING SCHEDULE',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF102226),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF193B42),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.calendar_month_rounded,
                        color: AppColors.primaryBright,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            schedule,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            slot,
                            style: const TextStyle(
                              color: Colors.white60,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // 7. Action Buttons (Call, Chat, and Big Neon Bright Green CTA)
              Row(
                children: [
                  // Call Button
                  _buildIconButton(
                    icon: Icons.phone_in_talk_rounded,
                    onTap: () {
                      Get.snackbar(
                        'Calling Trainer',
                        'Dialing $name (${trainer['phone'] ?? '+91 98765 43210'})...',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF163238),
                        colorText: AppColors.primaryBright,
                      );
                    },
                  ),
                  const SizedBox(width: 10),

                  // Message / Chat Button
                  _buildIconButton(
                    icon: Icons.chat_bubble_outline_rounded,
                    onTap: () {
                      Get.snackbar(
                        'Direct Chat',
                        'Opening chat with $name...',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF163238),
                        colorText: AppColors.primaryBright,
                      );
                    },
                  ),
                  const SizedBox(width: 12),

                  // Big Neon Bright Green CTA
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBright,
                          foregroundColor: Colors.black,
                          elevation: 4,
                          shadowColor: AppColors.primaryBright.withValues(alpha: 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          Get.snackbar(
                            'Session Requested!',
                            'Session consultation request sent to $name.',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF163238),
                            colorText: AppColors.primaryBright,
                            duration: const Duration(seconds: 3),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 17, color: Colors.black),
                            SizedBox(width: 8),
                            Text(
                              'Book Session',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14.5,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required String title,
    required String label,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF102226),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF152D32),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2E6370)),
        ),
        child: Icon(icon, color: AppColors.primaryBright, size: 20),
      ),
    );
  }
}
