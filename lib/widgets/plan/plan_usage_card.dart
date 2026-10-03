import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Plan Usage Tracking Card strictly matching Figma `media_1790870928333.png`.
class PlanUsageCard extends StatelessWidget {
  final int sessionsRemaining;
  final int totalSessions;
  final int daysRemaining;
  final int totalDays;
  final int redemptionsRemaining;
  final int totalRedemptions;
  final VoidCallback onTrackUsage;
  final VoidCallback onBuySession;

  const PlanUsageCard({
    super.key,
    this.sessionsRemaining = 29,
    this.totalSessions = 30,
    this.daysRemaining = 80,
    this.totalDays = 90,
    this.redemptionsRemaining = 0,
    this.totalRedemptions = 1,
    required this.onTrackUsage,
    required this.onBuySession,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF163238), // Exact dark slate teal
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
          // USAGE Header tag
          const Text(
            'USAGE',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
            ),
          ),

          const SizedBox(height: 12),

          // 1. Sessions Progress Box
          _buildUsageItem(
            label: 'Sessions',
            highlight: '$sessionsRemaining of $totalSessions Sessions left',
            progress: totalSessions > 0 ? sessionsRemaining / totalSessions : 0.0,
            indicatorColor: const Color(0xFF3B9AB2),
          ),

          const SizedBox(height: 10),

          // 2. Validity Progress Box
          _buildUsageItem(
            label: 'Validity',
            highlight: '$daysRemaining Days of $totalDays Days left',
            progress: totalDays > 0 ? daysRemaining / totalDays : 0.0,
            indicatorColor: const Color(0xFF3B9AB2),
          ),

          const SizedBox(height: 10),

          // 3. Session Redemption Box
          _buildUsageItem(
            label: 'Session Redemption',
            highlight: '$redemptionsRemaining of $totalRedemptions Redemption left',
            progress: totalRedemptions > 0 ? redemptionsRemaining / totalRedemptions : 0.0,
            indicatorColor: AppColors.primaryBright,
            subtext: 'Auto-Renew after next opening day of the business',
          ),

          const SizedBox(height: 18),

          // Action Buttons: [Track Usage] & [Buy Session]
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF38808E), width: 1.5),
                      backgroundColor: const Color(0xFF163238).withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onTrackUsage,
                    child: const Text(
                      'Track Usage',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 46,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBright,
                      foregroundColor: Colors.black,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: onBuySession,
                    child: const Text(
                      'Buy Session',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem({
    required String label,
    required String highlight,
    required double progress,
    required Color indicatorColor,
    String? subtext,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3F47).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            highlight,
            style: const TextStyle(
              color: AppColors.primaryBright,
              fontSize: 17,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 8),

          // Custom rounded horizontal progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 6,
              width: double.infinity,
              color: Colors.white.withValues(alpha: 0.15),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress.clamp(0.02, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: indicatorColor,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: indicatorColor.withValues(alpha: 0.5),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          if (subtext != null) ...[
            const SizedBox(height: 6),
            Text(
              subtext,
              style: const TextStyle(
                color: Colors.white54,
                fontSize: 10.5,
                height: 1.2,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
