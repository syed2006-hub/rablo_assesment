import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../models/D1CM1_login/user_model.dart';
import '../../models/D1CM2_account_creation/account_model.dart';
import '../../models/D1CM4_membership_joining/member_model.dart';
import '../../routes/app_routes.dart';
import '../../services/D1CM1_login/firebase_auth_service.dart';
import '../../services/D1CM2_account_creation/account_creation_service.dart';
import '../../services/D1CM4_membership_joining/membership_service.dart';
import '../../services/D1CM6_my_profile/profile_service.dart';
import '../../services/firebase/customer_firebase_service.dart';
import '../../utils/validators.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_popup.dart';
import '../../widgets/form_feedback_widgets.dart';

/// D1CM2 – Account Creation & Onboarding Controller.
/// Implements DRD D1CM2 specifications:
/// - Social Media auto-fill
/// - Contact Number (18+ validation)
/// - Gender (Male, Female, Other)
/// - Date of Birth (Calendar picker, 18+ validation)
/// - Profession (Single-select tabs: Student, Employed, HomeMaker, Retired, Business Person)
/// - Objective (Checkboxes matching DRD)
/// - Personal Address, Language Preference, Terms & Conditions
/// - Navigation to Affiliation Scanning or Dashboard V1
class AccountCreationController extends GetxController {
  static AccountCreationController get to => Get.find<AccountCreationController>();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final AccountCreationService _accountService =
      Get.put(AccountCreationService(), permanent: true);
  final MembershipService _membershipService =
      Get.put(MembershipService(), permanent: true);

  // Form Field Controllers
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController dobController =
      TextEditingController(text: '15 - 08 - 1998');
  final TextEditingController address1Controller = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController countryController =
      TextEditingController(text: 'India');
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController address2Controller = TextEditingController();

  // Observables for selections
  final RxString selectedGender = 'Male'.obs; // 'Male', 'Female', 'Others'
  final RxString selectedProfession = 'Student'.obs;
  final RxList<String> selectedObjectives =
      <String>['Fat Loss', 'Muscle Gain', 'Muscle Toning', 'Strength Building'].obs;
  final RxList<String> selectedLanguages = <String>['English', 'Hindi'].obs;
  final RxBool acceptedTerms = false.obs;
  final RxBool promotionalConsent = true.obs;
  final RxBool isLoading = false.obs;

  // Calendar picker state
  final Rx<DateTime> selectedCalendarDate = DateTime(1998, 8, 15).obs;
  final Rx<DateTime> displayedMonth = DateTime(1998, 8, 1).obs;

  // DRD Gender Options
  final List<String> genderOptions = const ['Male', 'Female', 'Others'];

  // DRD Profession Options (Single-select Tabs)
  final List<String> professionOptions = const [
    'Student',
    'Employed',
    'HomeMaker',
    'Retired',
    'Business Person',
  ];

  // DRD Primary 8 objectives shown on screen + "See all.."
  final List<String> primaryObjectives = const [
    'Fat Loss',
    'Muscle Gain',
    'Muscle Toning',
    'Strength Building',
    'Weight Gain',
    'Endurance Improvement',
    'Flexibility & Mobility',
  ];

  // Full 12 DRD objectives for the "See all.." modal
  final List<String> allObjectives = const [
    'Fat Loss',
    'Muscle Gain',
    'Muscle Toning',
    'Strength Building',
    'Weight Gain',
    'Endurance Improvement',
    'Flexibility & Mobility',
    'General Fitness & Wellness',
    'Posture & Balance Improvement',
    'Sports-Specific Training',
    'Rehabilitation & Recovery',
    'Stress Relief & Relaxation',
  ];

  // Available Languages
  final List<String> languageOptions = const [
    'English',
    'Hindi',
    'Bengali',
    'Marathi',
    'Tamil',
    'Malayalam',
    'Kannada',
    'Odia',
    'Punjabi',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    // Pre-fill user details from Google Social Media Login or Firebase Auth if available
    final googleUser = _accountService.currentUser.value;
    final fbUser = FirebaseAuthService.instance.currentFirebaseUser;

    if (googleUser != null && googleUser.displayName.isNotEmpty) {
      fullNameController.text = googleUser.displayName;
    } else if (fbUser != null && fbUser.displayName != null && fbUser.displayName!.isNotEmpty) {
      fullNameController.text = fbUser.displayName!;
    }
  }

  void toggleGender(String gender) {
    selectedGender.value = gender;
  }

  void selectProfession(String profession) {
    selectedProfession.value = profession;
  }

  void toggleObjective(String objective) {
    if (selectedObjectives.contains(objective)) {
      selectedObjectives.remove(objective);
    } else {
      selectedObjectives.add(objective);
    }
  }

  void toggleLanguage(String lang) {
    if (selectedLanguages.contains(lang)) {
      selectedLanguages.remove(lang);
    } else {
      selectedLanguages.add(lang);
    }
  }

  /// Custom Calendar Dialog
  void openCalendarDialog() {
    CommonPopup.show(
      title: null,
      backgroundColor: const Color(0xFF163238),
      content: Obx(() {
        final currentMonth = displayedMonth.value;
        final monthName = _getMonthName(currentMonth.month);
        final year = currentMonth.year;
        final daysInMonth = DateTime(year, currentMonth.month + 1, 0).day;
        final firstWeekday = DateTime(year, currentMonth.month, 1).weekday; // 1 = Mon, 7 = Sun

        return SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Calendar Month Navigation Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primaryBright),
                    onPressed: () {
                      displayedMonth.value = DateTime(year, currentMonth.month - 1, 1);
                    },
                  ),
                  Text(
                    '$monthName , $year',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primaryBright),
                    onPressed: () {
                      displayedMonth.value = DateTime(year, currentMonth.month + 1, 1);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Weekday Letters: M T W Th F S S
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('M', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('T', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('W', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('Th', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('F', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('S', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                  Text('S', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),

              // Days Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 35,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 6,
                  crossAxisSpacing: 6,
                ),
                itemBuilder: (context, index) {
                  final dayOffset = index - (firstWeekday - 1);
                  if (dayOffset < 0 || dayOffset >= daysInMonth) {
                    return const SizedBox.shrink();
                  }

                  final dayNumber = dayOffset + 1;
                  final isSelected = selectedCalendarDate.value.year == year &&
                      selectedCalendarDate.value.month == currentMonth.month &&
                      selectedCalendarDate.value.day == dayNumber;

                  return InkWell(
                    onTap: () {
                      selectedCalendarDate.value = DateTime(year, currentMonth.month, dayNumber);
                      final dayStr = dayNumber.toString().padLeft(2, '0');
                      final monthStr = currentMonth.month.toString().padLeft(2, '0');
                      dobController.text = '$dayStr - $monthStr - $year';
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBright : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? null
                            : Border.all(color: Colors.white10, width: 0.5),
                      ),
                      child: Text(
                        '$dayNumber',
                        style: TextStyle(
                          color: isSelected ? Colors.black : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Select & Close Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBright,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      // Check 18+ age validation
                      final age = DateTime.now().year - selectedCalendarDate.value.year;
                      if (age < 18) {
                        Get.snackbar(
                          'Age Requirement',
                          'You must be at least 18 years old to register.',
                          backgroundColor: const Color(0xFF163238),
                          colorText: Colors.redAccent,
                        );
                        return;
                      }
                      Get.back();
                    },
                    child: const Text('Select', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Full 12 Objectives Selection Modal
  void openObjectivesModal() {
    CommonPopup.show(
      title: 'Fitness Objectives',
      backgroundColor: const Color(0xFF142B31),
      content: Obx(() {
        final currentSelected = selectedObjectives.toList();
        return SizedBox(
          width: 340,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select your health & fitness objectives',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 340),
                child: SingleChildScrollView(
                  child: Column(
                    children: allObjectives.map((obj) {
                      final isSelected = currentSelected.contains(obj);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap: () => toggleObjective(obj),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF1D3B42) : const Color(0xFF284E56),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryBright : Colors.white12,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    obj,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13.5,
                                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(Icons.check_circle_rounded,
                                      color: AppColors.primaryBright, size: 18),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Selected CTA Button
              CommonButton(
                text: 'Confirm Selection (${selectedObjectives.length})',
                backgroundColor: AppColors.primaryBright,
                textColor: Colors.black,
                onPressed: () {
                  if (selectedObjectives.isEmpty) {
                    Get.snackbar(
                      'Selection Required',
                      'Please select at least 1 fitness objective.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: const Color(0xFF163238),
                      colorText: AppColors.primaryBright,
                    );
                    return;
                  }
                  Get.back();
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Submit Account Creation Form and complete registration
  Future<void> submitAccountCreation() async {
    // 1. Duplicate submission guard
    if (isLoading.value) return;

    // 2. Comprehensive Validation Checks
    final nameErr = Validators.validateRequired(fullNameController.text, 'Full Name');
    if (nameErr != null) {
      AppFeedback.showError(title: 'Full Name Required', message: nameErr);
      return;
    }

    final phoneErr = Validators.validatePhone(phoneController.text);
    if (phoneErr != null) {
      AppFeedback.showError(title: 'Valid Phone Required', message: phoneErr);
      return;
    }

    if (dobController.text.trim().isEmpty) {
      AppFeedback.showError(
        title: 'Date of Birth Required',
        message: 'Please select your date of birth (must be 18+).',
      );
      return;
    }

    // Age validation (Min age 18+)
    final ageErr = Validators.validateAge18Plus(selectedCalendarDate.value);
    if (ageErr != null) {
      AppFeedback.showError(
        title: 'Age Requirement (18+)',
        message: ageErr,
      );
      return;
    }

    if (selectedObjectives.isEmpty) {
      AppFeedback.showError(
        title: 'Objective Required',
        message: 'Please select at least 1 fitness objective.',
      );
      return;
    }

    if (!acceptedTerms.value) {
      AppFeedback.showError(
        title: 'Terms Acceptance Required',
        message: 'Please accept the company terms and conditions to create your account.',
      );
      return;
    }

    isLoading.value = true;

    final now = DateTime.now();
    final generatedId = 'MBR-${1000 + _membershipService.members.length + 1}';

    final fbUser = FirebaseAuthService.instance.currentFirebaseUser;
    final activeUser = _accountService.currentUser.value;

    final userEmail = (activeUser != null && activeUser.email.isNotEmpty && !activeUser.email.contains('member@fitness.com'))
        ? activeUser.email
        : (fbUser?.email?.isNotEmpty == true
            ? fbUser!.email!
            : (activeUser?.email ?? 'member@fitness.com'));

    final userUid = activeUser?.uid ?? fbUser?.uid ?? generatedId;
    final userName = fullNameController.text.trim();

    final account = AccountModel(
      uid: userUid,
      accountId: generatedId,
      fullName: userName,
      email: userEmail,
      phoneNumber: '+91 ${phoneController.text.trim()}',
      gender: selectedGender.value,
      dateOfBirth: dobController.text.trim(),
      profession: selectedProfession.value,
      objectives: selectedObjectives.toList(),
      addressLine1: address1Controller.text.trim(),
      city: cityController.text.trim(),
      state: stateController.text.trim(),
      country: countryController.text.trim(),
      pinCode: pinCodeController.text.trim(),
      addressLine2: address2Controller.text.trim(),
      preferredLanguages: selectedLanguages.toList(),
      acceptedTerms: acceptedTerms.value,
      promotionalConsent: promotionalConsent.value,
      registrationDate: now,
      isOnboarded: true,
    );

    // Update currentUser with isOnboarded = true
    if (_accountService.currentUser.value != null) {
      _accountService.currentUser.value = _accountService.currentUser.value!.copyWith(
        displayName: userName,
        email: userEmail,
        isOnboarded: true,
      );
    } else {
      _accountService.currentUser.value = UserModel(
        uid: userUid,
        email: userEmail,
        displayName: userName,
        role: 'Customer',
        createdAt: now,
        isOnboarded: true,
      );
    }

    // Save account & set onboarding state to true
    await _accountService.createAccount(account);

    // Sync into ProfileService
    if (Get.isRegistered<ProfileService>()) {
      ProfileService.to.syncWithAccountModel(account);
    }

    // Save directly to Firebase Firestore in real time & persist credentials
    if (Get.isRegistered<CustomerFirebaseService>()) {
      await CustomerFirebaseService.to.saveUserProfile(userUid, {
        'fullName': userName,
        'email': userEmail,
        'contactNumber': account.phoneNumber,
        'gender': selectedGender.value,
        'dateOfBirth': dobController.text.trim(),
        'profession': selectedProfession.value,
        'objectives': selectedObjectives.toList(),
        'personalAddress': address1Controller.text.trim(),
        'addressLine2': address2Controller.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'country': countryController.text.trim(),
        'pinCode': pinCodeController.text.trim(),
        'languagePreference': selectedLanguages.isNotEmpty ? selectedLanguages.first : 'English',
        'preferredLanguages': selectedLanguages.toList(),
        'termsAccepted': acceptedTerms.value,
        'promotionalConsent': promotionalConsent.value,
        'isOnboarded': true,
      });

      await CustomerFirebaseService.to.saveLoginCredentials(
        uid: userUid,
        email: userEmail,
        displayName: userName,
        phoneNumber: account.phoneNumber,
      );
    }

    // Register active member into MembershipService
    final newMember = MemberModel(
      id: generatedId,
      name: account.fullName,
      email: account.email,
      phone: account.phoneNumber,
      gender: account.gender,
      planName: 'Gold Quarterly Plan',
      status: 'Active',
      joinDate: now,
      expiryDate: now.add(const Duration(days: 90)),
      attendanceCount: 1,
      emergencyContact: 'Not Provided',
      notes: 'Objectives: ${selectedObjectives.join(", ")}',
    );
    _membershipService.addMember(newMember);

    isLoading.value = false;

    Get.snackbar(
      'Account Created!',
      'Welcome aboard, ${account.fullName}! Your account has been securely created.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF163238),
      colorText: AppColors.primaryBright,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );

    // Navigate to customerHome shell where Dashboard V1 is accessible via bottom navigation bar
    Get.offAllNamed(AppRoutes.customerHome);
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    dobController.dispose();
    address1Controller.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    pinCodeController.dispose();
    address2Controller.dispose();
    super.onClose();
  }
}
