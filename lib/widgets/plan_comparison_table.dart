import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/D1MM3_membership_planning/plan_offering_model.dart';

class PlanComparisonTableWidget extends StatelessWidget {
  final List<PlanComparisonRow> rows;
  final String activeColumn; // 'trial', 'business', 'starter'

  const PlanComparisonTableWidget({
    super.key,
    required this.rows,
    this.activeColumn = 'starter',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.slateCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.slateBorder),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        children: [
          // Table Headers
          Row(
            children: [
              const Expanded(
                flex: 4,
                child: Text(
                  'Offerings',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    'Trial',
                    style: TextStyle(
                      color: activeColumn == 'trial' ? AppColors.primaryLight : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: Text(
                    'Business',
                    style: TextStyle(
                      color: activeColumn == 'business' ? AppColors.primaryLight : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
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
                    child: Text(
                      'Starter',
                      style: TextStyle(
                        color: AppColors.primaryBright,
                        fontWeight: FontWeight.w900,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(color: AppColors.slateBorder, thickness: 1),
          const SizedBox(height: 6),

          // Table Rows
          ...rows.map((row) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      row.featureName,
                      style: const TextStyle(
                        color: AppColors.greyMuted,
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        row.trialValue,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Center(
                      child: Text(
                        row.businessValue,
                        style: TextStyle(
                          color: row.businessValue == '✔' ? AppColors.cyanAccent : Colors.white70,
                          fontSize: 11,
                          fontWeight: row.businessValue == '✔' ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
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
                          row.starterValue,
                          style: const TextStyle(
                            color: AppColors.primaryLight,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
}
