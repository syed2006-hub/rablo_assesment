import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/D1MM10_dashboard_v2/customer_membership_model.dart';

class MembershipHeroCard extends StatelessWidget {
  final CustomerMembershipModel membership;
  final VoidCallback? onTap;

  const MembershipHeroCard({
    super.key,
    required this.membership,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 120),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.primaryBright.withValues(alpha: 0.8), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.5),
          child: Stack(
            fit: StackFit.loose,
            children: [
              // Background gym photo
              Positioned.fill(
                child: Image.asset(
                  'assets/images/gym_hero_bg.png',
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, err, stack) => Container(
                    color: AppColors.slateCardDark,
                  ),
                ),
              ),

              // Gradient Overlay for readability
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF0C191B).withValues(alpha: 0.88),
                        const Color(0xFF163238).withValues(alpha: 0.75),
                        const Color(0xFF0C191B).withValues(alpha: 0.92),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                ),
              ),

              // Card Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Row(
                  children: [
                    // Crown Icon Badge
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primaryBright.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primaryBright.withValues(alpha: 0.6),
                          width: 1,
                        ),
                      ),
                      child: const Icon(
                        Icons.military_tech_rounded,
                        color: AppColors.primaryBright,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Plan details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Membership Name',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            membership.membershipPlan,
                            style: const TextStyle(
                              color: AppColors.greyMuted,
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (membership.businessName.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              membership.businessName,
                              style: const TextStyle(
                                color: AppColors.primaryLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                '${membership.rating.toStringAsFixed(1)} ★',
                                style: const TextStyle(
                                  color: AppColors.cyanAccent,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                width: 3,
                                height: 3,
                                decoration: const BoxDecoration(
                                  color: Colors.white38,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${membership.validityDays} Days validity',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Active Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBright,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBright.withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
