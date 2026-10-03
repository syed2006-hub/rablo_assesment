import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../models/D1MM5_my_profile/profile_model.dart';
import '../../routes/app_routes.dart';
import '../../services/D1CM1_login/firebase_auth_service.dart';
import '../../services/D1MM2_account_creation/account_creation_service.dart';
import '../../services/D1MM5_my_profile/profile_service.dart';

/// D1MM5 – Profile Controller managing user profile, personal details form,
/// verification, and logout confirmation.
class MyProfileController extends GetxController {
  ProfileService get profileService {
    if (!Get.isRegistered<ProfileService>()) {
      Get.put(ProfileService(), permanent: true);
    }
    return ProfileService.to;
  }

  ProfileModel get profile => profileService.profile.value;

  // Form Controllers for Personal Details (Figma D1MM5)
  late final TextEditingController fullNameController;
  late final TextEditingController phoneController;
  late final TextEditingController dobController;
  late final TextEditingController addressLine1Controller;
  late final TextEditingController addressLine2Controller;
  late final TextEditingController countryController;
  late final TextEditingController cityController;
  late final TextEditingController pincodeController;

  final RxString selectedGender = 'Male'.obs;
  final RxString selectedRole = 'Manager/Owner'.obs;
  final RxString selectedState = 'Karnataka'.obs;
  final RxList<String> selectedLanguages = <String>['English', 'Hindi', 'Kannada'].obs;
  final RxBool agreeToTerms = true.obs;
  final RxString uploadedPhotoPath = ''.obs;

  final List<String> genderOptions = const ['Male', 'Female', 'Others'];
  final List<String> roleOptions = const [
    'Manager/Owner',
    'Master Trainer',
    'Fitness Coach',
    'Member',
  ];
  final List<String> stateOptions = const [
    'Karnataka',
    'Maharashtra',
    'Delhi',
    'Tamil Nadu',
    'Telangana',
    'Kerala',
    'Gujarat',
    'Uttar Pradesh',
    'West Bengal',
  ];
  final List<String> languageOptions = const [
    'English',
    'Hindi',
    'Bengali',
    'Marathi',
    'Tamil',
    'Malayalam',
    'Gujarati',
    'Urdu',
    'Kannada',
    'Odia',
    'Punjabi',
    'Assamese',
    'Other',
  ];

  @override
  void onInit() {
    super.onInit();
    final current = profile;
    fullNameController = TextEditingController(text: current.fullName);
    phoneController = TextEditingController(text: current.phoneNumber.replaceAll('+91', '').trim());
    dobController = TextEditingController(text: current.dob);
    addressLine1Controller = TextEditingController(text: current.addressLine1);
    addressLine2Controller = TextEditingController(text: current.addressLine2);
    countryController = TextEditingController(text: current.country);
    cityController = TextEditingController(text: current.city);
    pincodeController = TextEditingController(text: current.pincode);

    selectedGender.value = current.gender;
    selectedRole.value = current.role;
    selectedState.value = current.state;
    selectedLanguages.assignAll(current.preferredLanguages);
    uploadedPhotoPath.value = current.photoUrl ?? '';
  }

  void toggleGender(String gender) {
    selectedGender.value = gender;
  }

  void toggleLanguage(String lang) {
    if (selectedLanguages.contains(lang)) {
      if (selectedLanguages.length > 1) {
        selectedLanguages.remove(lang);
      }
    } else {
      selectedLanguages.add(lang);
    }
  }

  void simulateUploadPhoto(String source) {
    uploadedPhotoPath.value = 'assets/images/welcome_bg.png';
    Get.snackbar(
      'Profile Photo Selected',
      'Photo chosen from $source.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.slateCard,
      colorText: AppColors.primaryLight,
      duration: const Duration(seconds: 2),
    );
  }

  /// Date picker matching Figma calendar
  Future<void> pickDateOfBirth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 11, 9),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryBright,
              onPrimary: Colors.black,
              surface: Color(0xFF1E3A42),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final day = picked.day.toString().padLeft(2, '0');
      final month = picked.month.toString().padLeft(2, '0');
      final year = picked.year.toString();
      dobController.text = '$day - $month - $year';
    }
  }

  /// Update personal details and show Figma "Update Successful!" celebration dialog
  Future<void> savePersonalDetails() async {
    if (!agreeToTerms.value) {
      Get.snackbar(
        'Terms Required',
        'Please agree to the Terms & Conditions before updating.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.slateCard,
        colorText: AppColors.peakRed,
      );
      return;
    }

    final updated = profile.copyWith(
      fullName: fullNameController.text.trim().isNotEmpty ? fullNameController.text.trim() : profile.fullName,
      phoneNumber: '+91 ${phoneController.text.trim()}',
      gender: selectedGender.value,
      role: selectedRole.value,
      dob: dobController.text.trim(),
      addressLine1: addressLine1Controller.text.trim(),
      addressLine2: addressLine2Controller.text.trim(),
      country: countryController.text.trim(),
      state: selectedState.value,
      city: cityController.text.trim(),
      pincode: pincodeController.text.trim(),
      preferredLanguages: selectedLanguages.toList(),
      photoUrl: uploadedPhotoPath.value.isNotEmpty ? uploadedPhotoPath.value : profile.photoUrl,
    );

    await profileService.updateProfile(updated);

    // Show Figma "Update Successful!" celebration dialog
    showUpdateSuccessfulDialog();
  }

  /// Figma "Update Successful!" Celebration Modal (personal_success.png)
  void showUpdateSuccessfulDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: const Color(0xFFC7DEE5), // Exact pale teal background from Figma
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Celebration green circular badge with party icon
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAE3E), // Figma vivid green
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.celebration_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Title: Update Successful!
              const Text(
                'Update Successful!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 10),

              // Divider line
              Container(
                height: 1,
                color: Colors.white30,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),

              const SizedBox(height: 12),

              // Subtitle: Congratulations! Your Details has been updated.
              const Text(
                'Congratulations! Your Details has been\nupdated.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // Done Button (Vibrant Green)
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAE3E),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () {
                    Get.back(); // Dismiss dialog
                    Get.back(); // Return to MyProfileScreen
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Figma "Leaving So Soon?" Logout Modal (logout_dialog.png)
  void showLogoutConfirmationDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
          decoration: BoxDecoration(
            color: const Color(0xFFC7DEE5), // Exact pale teal background from Figma
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Red circular icon with exit/logout symbol
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFBE1E2D), // Figma crimson red
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Title: Leaving So Soon?
              const Text(
                'Leaving So Soon?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.5,
                ),
              ),

              const SizedBox(height: 8),

              // Subtle line
              Container(
                height: 1,
                color: Colors.white30,
                margin: const EdgeInsets.symmetric(horizontal: 20),
              ),

              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'By Pressing Logout, You will exit the app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 24),

              // Dual Buttons: [Logout] (Outlined) & [Cancel] (Red filled)
              Row(
                children: [
                  // Logout button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () async {
                          Get.back(); // Close dialog
                          await executeLogout();
                        },
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Cancel button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBE1E2D),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Get.back(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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

  /// Real logout execution with Firebase & State cleanup
  Future<void> executeLogout() async {
    try {
      await FirebaseAuthService.instance.signOut();
    } catch (e) {
      debugPrint('Logout notice: $e');
    }

    // Reset active session state
    if (Get.isRegistered<AccountCreationService>()) {
      AccountCreationService.to.clearActiveSession();
    }

    Get.snackbar(
      'Signed Out',
      'You have been logged out successfully.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.slateCard,
      colorText: AppColors.primaryLight,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );

    // Route cleanly to Welcome / Login screen
    Get.offAllNamed(AppRoutes.welcome);
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    dobController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    countryController.dispose();
    cityController.dispose();
    pincodeController.dispose();
    super.onClose();
  }
}
