import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../models/D1CM1_login/user_model.dart';
import '../../models/D1MM2_account_creation/account_model.dart';
import '../../models/D1MM3_membership_planning/member_model.dart';
import '../../routes/app_routes.dart';
import '../../services/D1CM1_login/firebase_auth_service.dart';
import '../../services/D1MM2_account_creation/account_creation_service.dart';
import '../../services/D1MM3_membership_planning/membership_service.dart';
import '../../services/D1MM5_my_profile/profile_service.dart';
import '../../widgets/common_button.dart';
import '../../widgets/common_popup.dart';

/// D1MM2 – Account Creation & Onboarding Controller.
/// Strictly implements Figma onboarding requirements with social login prefill and validation.
class AccountCreationController extends GetxController {
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

  // Observables for Figma selections
  final RxString selectedGender = 'Male'.obs; // 'Male', 'Female', 'Others'
  final RxString selectedProfession = 'Student'.obs;
  final RxList<String> selectedObjectives =
      <String>['Strength Training', 'Group Classes', 'Cardio Training', 'Personal Training'].obs;
  final RxList<String> selectedLanguages = <String>['English', 'Hindi'].obs;
  final RxBool acceptedTerms = false.obs;
  final RxBool promotionalConsent = false.obs;
  final RxBool isLoading = false.obs;

  // Calendar picker state
  final Rx<DateTime> selectedCalendarDate = DateTime(1998, 8, 15).obs;
  final Rx<DateTime> displayedMonth = DateTime(1998, 8, 1).obs;

  // Figma Dropdown and Options
  final List<String> genderOptions = const ['Male', 'Female', 'Others'];
  final List<String> professionOptions = const [
    'Student',
    'Employed',
    'HomeMaker',
    'Retired',
  ];

  // Primary 7 objectives shown on screen + "See all.."
  final List<String> primaryObjectives = const [
    'Strength Training',
    'Group Classes',
    'Cardio Training',
    'Physical Therapy',
    'Personal Training',
    'KickBoxing',
    'CrossFit Training',
  ];

  // Full 12 objectives for the "See all.." modal
  final List<String> allObjectives = const [
    'Fat Loss',
    'Muscle Gain',
    'Muscle Toning',
    'Strength Training',
    'Weight Gain',
    'Endurance Improvement',
    'Flexibility and Mobility',
    'General Fitness',
    'Posture & Balance',
    'Sport Specific Training',
    'Rehabilitation',
    'Stress relief and Mental Well-being',
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

  /// Custom Calendar Dialog matching Figma middle screen
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
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1.1,
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
                      final newDate = DateTime(year, currentMonth.month, dayNumber);
                      selectedCalendarDate.value = newDate;
                      dobController.text =
                          '${dayNumber.toString().padLeft(2, '0')} - ${currentMonth.month.toString().padLeft(2, '0')} - $year';
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryBright : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: isSelected
                            ? Border.all(color: AppColors.primaryBright, width: 2)
                            : null,
                      ),
                      child: Text(
                        '$dayNumber',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected ? Colors.black : Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Clear Button in Figma Bright Green
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white70),
                    onPressed: () => Get.back(),
                  ),
                  SizedBox(
                    height: 38,
                    width: 100,
                    child: CommonButton(
                      text: 'Clear',
                      height: 38,
                      backgroundColor: AppColors.primaryBright,
                      textColor: Colors.black,
                      borderRadius: 10,
                      onPressed: () {
                        dobController.clear();
                        Get.back();
                      },
                    ),
                  ),
                  SizedBox(
                    height: 38,
                    width: 100,
                    child: CommonButton(
                      text: 'Done',
                      height: 38,
                      backgroundColor: AppColors.primary,
                      textColor: Colors.black,
                      borderRadius: 10,
                      onPressed: () => Get.back(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  /// Full Objectives Modal Dialog matching Figma right screen
  void openObjectivesModal() {
    CommonPopup.show(
      title: 'Objective (Select at-least four options)',
      titleColor: Colors.white,
      backgroundColor: const Color(0xFF163238),
      content: Obx(() {
        return SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 380),
                child: SingleChildScrollView(
                  child: Column(
                    children: allObjectives.map((obj) {
                      final isSelected = selectedObjectives.contains(obj);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: InkWell(
                          onTap: () => toggleObjective(obj),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? const Color(0xFF284E56) : const Color(0xFF1D3B42),
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

              // Selected (X) Bottom CTA Button in Bright Green
              CommonButton(
                text: 'Selected (${selectedObjectives.length})',
                backgroundColor: AppColors.primaryBright,
                textColor: Colors.black,
                onPressed: () {
                  if (selectedObjectives.length < 4) {
                    Get.snackbar(
                      'Selection Required',
                      'Please select at least 4 objectives (${selectedObjectives.length}/4 selected)',
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

  /// Submit Account Creation Form and complete onboarding
  Future<void> submitAccountCreation() async {
    // Validation Checks
    if (fullNameController.text.trim().isEmpty) {
      Get.snackbar('Full Name Required', 'Please enter your full name.',
          backgroundColor: const Color(0xFF163238), colorText: Colors.white);
      return;
    }

    if (phoneController.text.trim().length < 10) {
      Get.snackbar('Valid Phone Required', 'Please enter a valid 10-digit mobile number.',
          backgroundColor: const Color(0xFF163238), colorText: Colors.white);
      return;
    }

    if (dobController.text.trim().isEmpty) {
      Get.snackbar('Date of Birth Required', 'Please select your date of birth (must be 18+).',
          backgroundColor: const Color(0xFF163238), colorText: Colors.white);
      return;
    }

    if (selectedObjectives.length < 4) {
      Get.snackbar(
        'Objectives Required',
        'Please select at least 4 fitness objectives (${selectedObjectives.length}/4 selected).',
        backgroundColor: const Color(0xFF163238),
        colorText: AppColors.primaryBright,
      );
      return;
    }

    if (address1Controller.text.trim().isEmpty) {
      Get.snackbar('Address Required', 'Please enter your address.',
          backgroundColor: const Color(0xFF163238), colorText: Colors.white);
      return;
    }

    if (cityController.text.trim().isEmpty || stateController.text.trim().isEmpty) {
      Get.snackbar('City & State Required', 'Please enter both city and state.',
          backgroundColor: const Color(0xFF163238), colorText: Colors.white);
      return;
    }

    if (pinCodeController.text.trim().isEmpty) {
      Get.snackbar('PIN Code Required', 'Please enter your postal PIN code.',
          backgroundColor: const Color(0xFF163238), colorText: Colors.white);
      return;
    }

    if (!acceptedTerms.value) {
      Get.snackbar(
        'Terms Acceptance Required',
        'Please accept the company terms and conditions to create your account.',
        backgroundColor: const Color(0xFF163238),
        colorText: Colors.white,
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

    // Also register member into MembershipService so dashboards & profiles are populated
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
      'Welcome aboard, ${account.fullName}! Your fitness journey begins now.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFF163238),
      colorText: AppColors.primaryBright,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );

    // Navigate to Customer Home Shell
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
