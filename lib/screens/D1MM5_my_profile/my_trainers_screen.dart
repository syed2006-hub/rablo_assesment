import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';

/// D1MM5 – My Trainers Screen strictly implementing Figma Row 4
/// with Trainer cards, Add Trainer form modal, Remove warning dialog, and Success modal.
class MyTrainersScreen extends StatefulWidget {
  const MyTrainersScreen({super.key});

  @override
  State<MyTrainersScreen> createState() => _MyTrainersScreenState();
}

class _MyTrainersScreenState extends State<MyTrainersScreen> {
  final List<Map<String, dynamic>> _trainers = [
    {
      'id': 't1',
      'name': 'Rahul Sharma',
      'role': 'Master Trainer & Strength Coach',
      'specialty': 'CrossFit, Powerlifting & Muscle Gain',
      'rating': '4.9',
      'reviewsCount': '128',
      'sessionsCompleted': 48,
      'timing': 'Mon, Wed, Fri • 07:00 AM - 08:30 AM',
      'avatarChar': 'R',
      'status': 'Assigned',
    },
    {
      'id': 't2',
      'name': 'Priya Patel',
      'role': 'Mobility & Conditioning Coach',
      'specialty': 'HIIT, Functional Fitness & Flexibility',
      'rating': '4.8',
      'reviewsCount': '94',
      'sessionsCompleted': 24,
      'timing': 'Tue, Thu, Sat • 06:00 PM - 07:30 PM',
      'avatarChar': 'P',
      'status': 'Assigned',
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
                // Top App Bar
                _buildTopAppBar(context),

                // Main Content
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
                              'Assigned Coaches',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Your designated personal fitness trainers and workout schedule.',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 18),

                            // List of Trainers
                            ..._trainers.map((t) => _buildTrainerCard(t)),

                            const SizedBox(height: 20),

                            // Add New Trainer Button matching Figma
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryBright,
                                  foregroundColor: Colors.black,
                                  elevation: 6,
                                  shadowColor: AppColors.primaryBright.withValues(alpha: 0.4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                onPressed: _showAddTrainerModal,
                                icon: const Icon(Icons.person_add_alt_1, color: Colors.black),
                                label: const Text(
                                  '+ Assign New Trainer',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ),
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
                    'My Trainers',
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

          // Notification Bell
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

  Widget _buildTrainerCard(Map<String, dynamic> t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Avatar + Name + Rating badge
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.primaryBright,
                  child: Text(
                    t['avatarChar'],
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t['role'],
                        style: const TextStyle(
                          color: AppColors.primaryBright,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                // Rating pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3F47),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.primaryBright, size: 14),
                      const SizedBox(width: 3),
                      Text(
                        t['rating'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(color: Color(0xFF26505A)),
            const SizedBox(height: 8),

            // Specialty & Timing
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.fitness_center, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t['specialty'],
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.white54, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t['timing'],
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Action Buttons matching Figma
            Row(
              children: [
                // Book session button
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBright,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () {
                      Get.snackbar(
                        'Session Booked',
                        'Scheduled personal session with ${t['name']}',
                        backgroundColor: const Color(0xFF1E3F47),
                        colorText: AppColors.primaryBright,
                      );
                    },
                    child: const Text(
                      'Book Session',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Message button
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Get.snackbar(
                      'Trainer Chat',
                      'Opening direct message with ${t['name']}',
                      backgroundColor: const Color(0xFF1E3F47),
                      colorText: Colors.white,
                    );
                  },
                  child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                // Remove button
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Color(0xFFEF5350), size: 20),
                  onPressed: () => _showRemoveTrainerDialog(t),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // FIGMA MODALS (r4_form, r4_dialog1, r4_dialog2)
  // ============================================================

  // 1. Add Trainer Form Modal (r4_form.png)
  void _showAddTrainerModal() {
    String selectedTrainer = 'Ankit Verma';
    String selectedFocus = 'Strength Training & Hypertrophy';
    String selectedSlot = 'Morning (07:00 AM - 08:30 AM)';

    Get.bottomSheet(
      StatefulBuilder(
        builder: (ctx, setModalState) {
          return Container(
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
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
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

                  const Text(
                    'Assign New Trainer',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Select a certified personal trainer from your fitness centre.',
                    style: TextStyle(color: Colors.white60, fontSize: 12),
                  ),

                  const SizedBox(height: 18),

                  // Select Trainer
                  const Text(
                    'Available Trainer',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3F47),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedTrainer,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF163238),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        items: const [
                          DropdownMenuItem(value: 'Ankit Verma', child: Text('Ankit Verma (Rehab & Fat Loss)')),
                          DropdownMenuItem(value: 'Sneha Rao', child: Text('Sneha Rao (Yoga & Core Pilates)')),
                          DropdownMenuItem(value: 'Karan Mehra', child: Text('Karan Mehra (Bodybuilding & Strength)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedTrainer = val);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Focus Area
                  const Text(
                    'Training Focus Area',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3F47),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFocus,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF163238),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        items: const [
                          DropdownMenuItem(value: 'Strength Training & Hypertrophy', child: Text('Strength Training & Hypertrophy')),
                          DropdownMenuItem(value: 'Fat Loss & HIIT Conditioning', child: Text('Fat Loss & HIIT Conditioning')),
                          DropdownMenuItem(value: 'Mobility, Flexibility & Posture', child: Text('Mobility, Flexibility & Posture')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedFocus = val);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Preferred Time Slot
                  const Text(
                    'Preferred Schedule',
                    style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3F47),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSlot,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF163238),
                        icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                        items: const [
                          DropdownMenuItem(value: 'Morning (07:00 AM - 08:30 AM)', child: Text('Morning (07:00 AM - 08:30 AM)')),
                          DropdownMenuItem(value: 'Afternoon (01:00 PM - 02:30 PM)', child: Text('Afternoon (01:00 PM - 02:30 PM)')),
                          DropdownMenuItem(value: 'Evening (06:00 PM - 07:30 PM)', child: Text('Evening (06:00 PM - 07:30 PM)')),
                        ],
                        onChanged: (val) {
                          if (val != null) setModalState(() => selectedSlot = val);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white30),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => Get.back(),
                          child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBright,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            Get.back();
                            setState(() {
                              _trainers.add({
                                'id': 't${_trainers.length + 1}',
                                'name': selectedTrainer,
                                'role': 'Certified Coach',
                                'specialty': selectedFocus,
                                'rating': '4.9',
                                'reviewsCount': '64',
                                'sessionsCompleted': 0,
                                'timing': selectedSlot,
                                'avatarChar': selectedTrainer[0],
                                'status': 'Assigned',
                              });
                            });
                            _showSuccessModal(selectedTrainer);
                          },
                          child: const Text('Confirm Assignment', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  // 2. Remove Trainer Confirmation Dialog (r4_dialog1.png)
  void _showRemoveTrainerDialog(Map<String, dynamic> t) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF163238),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  color: Color(0xFFBE1E2D),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Remove Trainer?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Are you sure you want to unassign ${t['name']}? Your scheduled sessions with this coach will be paused.',
                style: const TextStyle(color: Colors.white60, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white30),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBE1E2D),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Get.back();
                        setState(() {
                          _trainers.removeWhere((item) => item['id'] == t['id']);
                        });
                        Get.snackbar(
                          'Trainer Removed',
                          '${t['name']} has been removed from your coaches.',
                          backgroundColor: const Color(0xFF1E3F47),
                          colorText: Colors.white,
                        );
                      },
                      child: const Text('Remove', style: TextStyle(fontWeight: FontWeight.bold)),
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

  // 3. Trainer Assigned Success Modal (r4_dialog2.png)
  void _showSuccessModal(String trainerName) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF163238),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  color: AppColors.primaryBright,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.check, color: Colors.black, size: 32),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Trainer Assigned!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Your sessions with $trainerName have been successfully registered.',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBright,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
