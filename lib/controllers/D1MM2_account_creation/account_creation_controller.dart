import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../models/D1MM2_account_creation/account_model.dart';
import '../../models/D1MM3_membership_planning/member_model.dart';
import '../../models/D1MM3_membership_planning/membership_plan_model.dart';
import '../../routes/app_routes.dart';
import '../../services/D1MM2_account_creation/account_creation_service.dart';
import '../../services/D1MM3_membership_planning/membership_service.dart';
import '../home/home_controller.dart';

/// D1MM2 – Account Creation & Registration Form Controller.
class AccountCreationController extends GetxController {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final AccountCreationService _accountService =
      Get.put(AccountCreationService());
  final MembershipService _membershipService =
      Get.put(MembershipService());

  // Input Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emergencyContactController =
      TextEditingController();
  final TextEditingController healthNotesController = TextEditingController();
  final TextEditingController businessNameController = TextEditingController();
  final TextEditingController gstNumberController = TextEditingController();

  // Reactive Selections
  final RxString selectedAccountType = 'Individual'.obs; // 'Individual', 'Business'
  final RxString selectedGender = 'Male'.obs;
  final Rx<MembershipPlanModel?> selectedPlan = Rx<MembershipPlanModel?>(null);
  final RxBool sendWelcomeEmail = true.obs;
  final RxBool autoRenewEnabled = false.obs;
  final RxBool isLoading = false.obs;

  List<String> get accountTypes => const ['Individual', 'Business'];
  List<String> get genderOptions => const ['Male', 'Female', 'Other'];
  List<MembershipPlanModel> get availablePlans => _membershipService.plans;

  @override
  void onInit() {
    super.onInit();
    if (availablePlans.isNotEmpty) {
      selectedPlan.value = availablePlans.first;
    }
  }

  void resetForm() {
    formKey.currentState?.reset();
    fullNameController.clear();
    emailController.clear();
    phoneController.clear();
    emergencyContactController.clear();
    healthNotesController.clear();
    businessNameController.clear();
    gstNumberController.clear();
    selectedAccountType.value = 'Individual';
    selectedGender.value = 'Male';
    if (availablePlans.isNotEmpty) {
      selectedPlan.value = availablePlans.first;
    }
  }

  Future<void> submitAccountCreation() async {
    if (formKey.currentState?.validate() ?? false) {
      final plan = selectedPlan.value;
      if (plan == null) {
        Get.snackbar('Plan Required', 'Please select a membership plan.');
        return;
      }

      isLoading.value = true;

      final now = DateTime.now();
      final expiryDate = now.add(Duration(days: plan.durationMonths * 30));
      final generatedId = 'M-${1000 + _membershipService.members.length + 1}';

      final account = AccountModel(
        accountId: generatedId,
        fullName: fullNameController.text.trim(),
        email: emailController.text.trim(),
        phoneNumber: phoneController.text.trim(),
        gender: selectedGender.value,
        accountType: selectedAccountType.value,
        planId: plan.id,
        planName: plan.name,
        emergencyContact: emergencyContactController.text.trim().isEmpty
            ? 'Not Provided'
            : emergencyContactController.text.trim(),
        businessName: selectedAccountType.value == 'Business'
            ? businessNameController.text.trim()
            : null,
        gstNumber: selectedAccountType.value == 'Business'
            ? gstNumberController.text.trim()
            : null,
        healthNotes: healthNotesController.text.trim().isEmpty
            ? null
            : healthNotesController.text.trim(),
        registrationDate: now,
      );

      // Save to Account Service
      await _accountService.createAccount(account);

      // Add to active Membership repository
      final newMember = MemberModel(
        id: generatedId,
        name: account.fullName,
        email: account.email,
        phone: account.phoneNumber,
        gender: account.gender,
        planName: account.planName,
        status: 'Active',
        joinDate: now,
        expiryDate: expiryDate,
        attendanceCount: 0,
        emergencyContact: account.emergencyContact,
        notes: account.healthNotes,
      );
      _membershipService.addMember(newMember);

      isLoading.value = false;

      Get.snackbar(
        'Account Registered!',
        'Member ${newMember.name} ($generatedId) added successfully.',
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );

      resetForm();

      // Navigate to Member Directory Tab
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().changeTab(1);
      } else {
        Get.toNamed(AppRoutes.members);
      }
    }
  }

  @override
  void onClose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    emergencyContactController.dispose();
    healthNotesController.dispose();
    businessNameController.dispose();
    gstNumberController.dispose();
    super.onClose();
  }
}
