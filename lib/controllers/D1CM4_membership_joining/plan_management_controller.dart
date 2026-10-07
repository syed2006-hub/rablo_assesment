import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/D1CM4_membership_joining/plan_offering_model.dart';
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
    final currentPlan = plans.firstWhereOrNull((p) => p.id == selectedPlanId.value) ?? plans.first;
    return billingPeriod.value == BillingPeriod.monthly
        ? currentPlan.monthlyPrice
        : currentPlan.quarterlyPrice;
  }

  void executePayment([BuildContext? context]) {
    showPlanConfirmationDialog();
  }

  void showPlanConfirmationDialog() {
    final currentPlan = plans.firstWhere((p) => p.id == selectedPlanId.value);
    final price = billingPeriod.value == BillingPeriod.monthly
        ? currentPlan.monthlyPrice
        : currentPlan.quarterlyPrice;

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF163238),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryBright.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline_rounded,
                  color: AppColors.primaryBright,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Confirm ${currentPlan.name} Plan',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'You have selected the ${currentPlan.name} plan at ₹$price/${billingPeriod.value == BillingPeriod.monthly ? "mo" : "qtr"}.\nIncludes ${currentPlan.userLimitDescription}.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white54),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Get.back();
                        Get.snackbar(
                          'Success',
                          'Subscribed to ${currentPlan.name} Plan!',
                          backgroundColor: const Color(0xFF163238),
                          colorText: AppColors.primaryBright,
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      },
                      child: const Text('Proceed', style: TextStyle(fontWeight: FontWeight.bold)),
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
}
