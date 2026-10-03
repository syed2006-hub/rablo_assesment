import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/D1MM3_membership_planning/plan_offering_model.dart';
import '../../constants/app_colors.dart';

enum BillingPeriod { monthly, quarterly }

class PlanManagementController extends GetxController {
  final billingPeriod = BillingPeriod.monthly.obs;
  final selectedPlanId = 'starter'.obs;
  final autoSwitchToIndividual = false.obs;

  final plans = <CustomerPlanModel>[
    CustomerPlanModel(
      id: 'business',
      name: 'Business',
      monthlyPrice: 3000,
      quarterlyPrice: 2400,
      userLimitDescription: '500 Max. User Limit',
      iconType: 'business',
    ),
    CustomerPlanModel(
      id: 'starter',
      name: 'Starter',
      monthlyPrice: 1000,
      quarterlyPrice: 800,
      userLimitDescription: '100 Max. User Limit',
      isSelected: true,
      iconType: 'starter',
    ),
    CustomerPlanModel(
      id: 'enterprise',
      name: 'Enterprise',
      monthlyPrice: 5000,
      quarterlyPrice: 4200,
      userLimitDescription: 'Unlimited User Limit',
      iconType: 'enterprise',
    ),
  ].obs;

  final comparisonRows = <PlanComparisonRow>[].obs;

  @override
  void onInit() {
    super.onInit();
    comparisonRows.assignAll(PlanComparisonRow.getFigmaComparisonRows());
  }

  void setBillingPeriod(BillingPeriod period) {
    billingPeriod.value = period;
  }

  void selectPlan(String planId) {
    selectedPlanId.value = planId;
  }

  void toggleAutoSwitch(bool? val) {
    autoSwitchToIndividual.value = val ?? false;
  }

  int get currentPrice {
    final plan = plans.firstWhereOrNull((p) => p.id == selectedPlanId.value) ?? plans[1];
    return (billingPeriod.value == BillingPeriod.monthly)
        ? plan.monthlyPrice
        : plan.quarterlyPrice;
  }

  void executePayment(BuildContext context) {
    final plan = plans.firstWhereOrNull((p) => p.id == selectedPlanId.value) ?? plans[1];
    final price = currentPrice;
    final periodName = (billingPeriod.value == BillingPeriod.monthly) ? 'Monthly' : 'Quarterly';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.slateCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.primaryLight, width: 1.5),
        ),
        title: Row(
          children: const [
            Icon(Icons.verified, color: AppColors.primaryLight, size: 28),
            SizedBox(width: 10),
            Text(
              'Subscription Active',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You have subscribed to the ${plan.name} ($periodName) plan!',
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.slateCardDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Amount Paid:', style: TextStyle(color: Colors.white54)),
                  Text(
                    '₹$price',
                    style: const TextStyle(
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBright,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Awesome!', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
