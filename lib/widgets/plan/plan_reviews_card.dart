import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';

/// Reviews & Ratings Histogram strictly matching Figma `media_1790870927472.png`.
class PlanReviewsCard extends StatelessWidget {
  final int totalReviews;
  final double averageRating;

  const PlanReviewsCard({
    super.key,
    this.totalReviews = 432,
    this.averageRating = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. Dual KPI Review Summary Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
            children: [
              // Total Reviews
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Reviews',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$totalReviews',
                          style: const TextStyle(
                            color: AppColors.primaryBright,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Count',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          color: AppColors.primaryBright,
                          size: 13,
                        ),
                        SizedBox(width: 2),
                        Text(
                          '2.1%',
                          style: TextStyle(
                            color: AppColors.primaryBright,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'vs last 7 days Avg.',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              Container(
                width: 1,
                height: 64,
                color: Colors.white12,
                margin: const EdgeInsets.symmetric(horizontal: 12),
              ),

              // Average Rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Average Rating',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          averageRating.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Color(0xFF3B9AB2),
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.star_rounded,
                          color: Color(0xFF3B9AB2),
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Row(
                      children: [
                        Icon(
                          Icons.arrow_upward_rounded,
                          color: AppColors.primaryBright,
                          size: 13,
                        ),
                        SizedBox(width: 2),
                        Text(
                          '2.1%',
                          style: TextStyle(
                            color: AppColors.primaryBright,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'vs last 7 days Avg.',
                          style: TextStyle(
                            color: Colors.white54,
                            fontSize: 10,
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

        const SizedBox(height: 14),

        // 2. Ratings Breakdown Histogram
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ratings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),

              // 5 Star
              _buildRatingBar(
                stars: 5,
                starColor: AppColors.primaryBright,
                barColor: AppColors.primaryBright,
                ratio: 0.86,
                count: 86,
              ),
              const SizedBox(height: 10),

              // 4 Star
              _buildRatingBar(
                stars: 4,
                starColor: const Color(0xFF3B9AB2),
                barColor: const Color(0xFF3B9AB2),
                ratio: 0.60,
                count: 233,
              ),
              const SizedBox(height: 10),

              // 3 Star
              _buildRatingBar(
                stars: 3,
                starColor: const Color(0xFF3B9AB2),
                barColor: const Color(0xFF3B9AB2),
                ratio: 0.78,
                count: 369,
              ),
              const SizedBox(height: 10),

              // 2 Star
              _buildRatingBar(
                stars: 2,
                starColor: const Color(0xFFBE1E2D),
                barColor: const Color(0xFFBE1E2D),
                ratio: 0.12,
                count: 26,
              ),
              const SizedBox(height: 10),

              // 1 Star
              _buildRatingBar(
                stars: 1,
                starColor: const Color(0xFFBE1E2D),
                barColor: const Color(0xFFBE1E2D),
                ratio: 0.18,
                count: 65,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingBar({
    required int stars,
    required Color starColor,
    required Color barColor,
    required double ratio,
    required int count,
  }) {
    return Row(
      children: [
        // Stars label: "5 ★"
        SizedBox(
          width: 32,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$stars',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 3),
              Icon(Icons.star_rounded, color: starColor, size: 14),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Progress bar
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 7,
              color: Colors.white.withValues(alpha: 0.15),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: ratio.clamp(0.04, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: barColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 12),

        // Count label
        SizedBox(
          width: 34,
          child: Text(
            '$count',
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
