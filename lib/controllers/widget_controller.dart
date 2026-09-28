import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/common_button.dart';
import '../widgets/common_popup.dart';

/// GetX controller for managing WidgetScreen state and interactions.
class WidgetController extends GetxController {
  final TextEditingController nameController =
      TextEditingController(text: 'Alex Morgan');
  final TextEditingController emailController =
      TextEditingController(text: 'alex@fitnessclub.com');
  final TextEditingController passwordController =
      TextEditingController(text: 'SecurePass123!');

  final RxBool isPasswordHidden = true.obs;
  final RxBool isButtonLoading = false.obs;

  final RxString selectedPlan = 'Gold Quarterly (Recommended)'.obs;
  final List<String> planOptions = [
    'Basic Monthly Plan',
    'Silver Standard (6 Months)',
    'Gold Quarterly (Recommended)',
    'VIP Platinum Annual',
  ];

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleButtonLoading() {
    isButtonLoading.value = !isButtonLoading.value;
  }

  void onPlanChanged(String? newPlan) {
    if (newPlan != null) {
      selectedPlan.value = newPlan;
    }
  }

  /// Displays the CommonPopup dialog
  void showPopupDemo() {
    CommonPopup.show(
      title: 'CommonPopup Component',
      message:
          'This is a demonstration of CommonPopup widget. It supports custom headers, modal descriptions, and action callbacks.',
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
        SizedBox(
          width: 100,
          child: CommonButton(
            text: 'OK',
            height: 40,
            onPressed: () => Get.back(),
          ),
        ),
      ],
    );
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
