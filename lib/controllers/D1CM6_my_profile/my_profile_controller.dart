import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../models/D1CM6_my_profile/profile_model.dart';
import '../../routes/app_routes.dart';
import '../../services/api/business_connect_api_service.dart';
import '../../services/D1CM1_login/firebase_auth_service.dart';
import '../../services/D1CM2_account_creation/account_creation_service.dart';
import '../../services/D1CM6_my_profile/profile_service.dart';
import '../../services/firebase/customer_firebase_service.dart';

/// D1CM6 – My Profile Controller.
/// Implements DRD D1CM6 requirements:
/// - Profile Overview & personal info updating
/// - Business Connects with DRD Delete Affiliation flow:
///   1. "D1CM6 What went wrong" reason popup
///   2. Remaining sessions warning popup
///   3. User agreement T&C confirmation
///   4. Affiliation removed popup (Join New Business -> Dashboard V1 / Logout)
/// - My Trainers list (Expertise & Achievement tabs)
/// - Promotional Message Consent & 30-day Account Deactivation review
/// - Logout confirmation ("Leaving So Soon?")
class MyProfileController extends GetxController {
  static MyProfileController get to {
    if (!Get.isRegistered<MyProfileController>()) {
      return Get.put(MyProfileController(), permanent: true);
    }
    return Get.find<MyProfileController>();
  }

  ProfileService get profileService {
    if (!Get.isRegistered<ProfileService>()) {
      Get.put(ProfileService(), permanent: true);
    }
    return ProfileService.to;
  }

  final BusinessConnectApiService _businessService =
      Get.isRegistered<BusinessConnectApiService>()
          ? BusinessConnectApiService.to
          : Get.put(BusinessConnectApiService());

  ProfileModel get profile => profileService.profile.value;

  // Personal Info Form Controllers
  late TextEditingController fullNameController;
  late TextEditingController phoneController;
  late TextEditingController dobController;
  late TextEditingController addressLine1Controller;
  late TextEditingController addressLine2Controller;
  late TextEditingController countryController;
  late TextEditingController cityController;
  late TextEditingController pincodeController;
  TextEditingController otherReasonController = TextEditingController();

  final RxString selectedGender = 'Male'.obs;
  final RxString selectedRole = 'Member'.obs;
  final RxString selectedState = 'Karnataka'.obs;
  final RxList<String> selectedLanguages = <String>['English', 'Hindi', 'Kannada'].obs;
  final RxBool promotionalConsent = true.obs;
  final RxString uploadedPhotoPath = ''.obs;

  // Active Membership Status
  final RxString activePlanName = 'Gold Quarterly Plan'.obs;
  final RxInt remainingSessions = 18.obs;
  final RxString expiryDate = '15 Nov 2026'.obs;

  // "What went wrong" Reason options (DRD 2.1)
  final List<String> deletionReasons = const [
    'Poor service quality',
    'Unresponsive support',
    'Found a better alternative',
    'No longer need the service',
    'Business closed',
    'Other',
  ];
  final RxString selectedDeletionReason = 'Poor service quality'.obs;

  // Deletion Agreement Checkbox
  final RxBool agreeToDelete = false.obs;

  final List<String> genderOptions = const ['Male', 'Female', 'Others'];
  final List<String> roleOptions = const [
    'Member',
    'Manager/Owner',
    'Master Trainer',
    'Fitness Coach',
  ];

  /// Ensures all TextEditingControllers are active, initialized, and non-disposed.
  void ensureControllersValid() {
    final current = profile;

    try {
      final _ = fullNameController.text;
    } catch (_) {
      fullNameController = TextEditingController(text: current.fullName);
    }

    try {
      final _ = phoneController.text;
    } catch (_) {
      phoneController = TextEditingController(text: current.phoneNumber.replaceAll('+91', '').trim());
    }

    try {
      final _ = dobController.text;
    } catch (_) {
      dobController = TextEditingController(text: current.dob);
    }

    try {
      final _ = addressLine1Controller.text;
    } catch (_) {
      addressLine1Controller = TextEditingController(text: current.addressLine1);
    }

    try {
      final _ = addressLine2Controller.text;
    } catch (_) {
      addressLine2Controller = TextEditingController(text: current.addressLine2);
    }

    try {
      final _ = countryController.text;
    } catch (_) {
      countryController = TextEditingController(text: current.country);
    }

    try {
      final _ = cityController.text;
    } catch (_) {
      cityController = TextEditingController(text: current.city);
    }

    try {
      final _ = pincodeController.text;
    } catch (_) {
      pincodeController = TextEditingController(text: current.pincode);
    }

    try {
      final _ = otherReasonController.text;
    } catch (_) {
      otherReasonController = TextEditingController();
    }
  }

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
    otherReasonController = TextEditingController();

    selectedGender.value = current.gender;
    selectedRole.value = current.role;
    selectedState.value = current.state;
    selectedLanguages.assignAll(current.preferredLanguages);
    uploadedPhotoPath.value = current.photoUrl ?? '';

    // Real-time synchronization with CustomerFirebaseService
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final fbProfile = CustomerFirebaseService.to.currentUserProfile.value;
      if (fbProfile != null) {
        if (fbProfile['fullName'] != null && fbProfile['fullName'].toString().isNotEmpty) {
          fullNameController.text = fbProfile['fullName'].toString();
        }
        if (fbProfile['contactNumber'] != null) {
          phoneController.text = fbProfile['contactNumber'].toString().replaceAll('+91', '').trim();
        }
        if (fbProfile['dateOfBirth'] != null) {
          dobController.text = fbProfile['dateOfBirth'].toString();
        }
        if (fbProfile['gender'] != null) {
          selectedGender.value = fbProfile['gender'].toString();
        }
        if (fbProfile['personalAddress'] != null) {
          addressLine1Controller.text = fbProfile['personalAddress'].toString();
        }
      }

      final fbPlan = CustomerFirebaseService.to.activePlan.value;
      if (fbPlan != null) {
        activePlanName.value = fbPlan['planName']?.toString() ?? activePlanName.value;
        remainingSessions.value = (fbPlan['sessionsLeft'] as num?)?.toInt() ?? remainingSessions.value;
        expiryDate.value = fbPlan['validity']?.toString() ?? expiryDate.value;
      }

      // Listen to real-time changes
      ever(CustomerFirebaseService.to.currentUserProfile, (profileData) {
        if (profileData != null) {
          ensureControllersValid();
          if (profileData['fullName'] != null && profileData['fullName'].toString().isNotEmpty) {
            fullNameController.text = profileData['fullName'].toString();
          }
          if (profileData['contactNumber'] != null) {
            phoneController.text = profileData['contactNumber'].toString().replaceAll('+91', '').trim();
          }
        }
      });
    }
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

  final RxBool agreeToTerms = true.obs;

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

  Future<void> pickDateOfBirth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1998, 8, 15),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primaryBright,
              onPrimary: Colors.black,
              surface: Color(0xFF162D34),
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
      dobController.text = '$day - $month - ${picked.year}';
    }
  }

  void simulateUploadPhoto(String source) {
    uploadedPhotoPath.value = 'assets/images/user_avatar.png';
    Get.snackbar(
      'Photo Uploaded',
      'Profile photo selected from $source.',
      backgroundColor: const Color(0xFF163238),
      colorText: AppColors.primaryBright,
    );
  }

  /// Save Personal Details updates
  void saveProfileDetails() {
    savePersonalDetails();
  }

  void savePersonalDetails() {
    final updated = profile.copyWith(
      fullName: fullNameController.text.trim(),
      phoneNumber: '+91 ${phoneController.text.trim()}',
      gender: selectedGender.value,
      dob: dobController.text.trim(),
      addressLine1: addressLine1Controller.text.trim(),
      addressLine2: addressLine2Controller.text.trim(),
      city: cityController.text.trim(),
      state: selectedState.value,
      country: countryController.text.trim(),
      pincode: pincodeController.text.trim(),
      role: selectedRole.value,
      preferredLanguages: selectedLanguages.toList(),
      photoUrl: uploadedPhotoPath.value.isNotEmpty ? uploadedPhotoPath.value : null,
    );

    profileService.updateProfile(updated);

    // Sync to Cloud Firestore in real time
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = CustomerFirebaseService.to.currentUid.value;
      if (uid.isNotEmpty) {
        CustomerFirebaseService.to.updateUserFields(uid, {
          'fullName': fullNameController.text.trim(),
          'contactNumber': '+91 ${phoneController.text.trim()}',
          'gender': selectedGender.value,
          'dateOfBirth': dobController.text.trim(),
          'personalAddress': addressLine1Controller.text.trim(),
          'addressLine2': addressLine2Controller.text.trim(),
          'city': cityController.text.trim(),
          'state': selectedState.value,
          'country': countryController.text.trim(),
          'pinCode': pincodeController.text.trim(),
          'preferredLanguages': selectedLanguages.toList(),
        });
      }
    }

    _showUpdateSuccessDialog();
  }

  void _showUpdateSuccessDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF163238),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: Color(0xFF1E5B2A),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, color: Colors.white, size: 44),
              ),
              const SizedBox(height: 18),
              const Text(
                'Update Successful!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your profile details have been successfully saved.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBright,
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Get.back(); // Close dialog
                    Get.back(); // Return to profile
                  },
                  child: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // DRD D1CM6: DELETE AFFILIATION POP-UP FLOW
  // ============================================================

  /// Step 1: "D1CM6 What went wrong" Pop-Up
  void startDeleteAffiliationFlow(String businessName) {
    agreeToDelete.value = false;
    otherReasonController.clear();

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF152A2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'What went wrong?',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white60),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Please help us understand why you want to delete your affiliation with $businessName.',
                style: const TextStyle(color: Colors.white70, fontSize: 12.5),
              ),
              const SizedBox(height: 16),

              // Single-selection Reason Tabs
              Obx(() {
                return Column(
                  children: deletionReasons.map((reason) {
                    final isSelected = selectedDeletionReason.value == reason;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6.0),
                      child: InkWell(
                        onTap: () => selectedDeletionReason.value = reason,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                          decoration: BoxDecoration(
                            color: isSelected ? const Color(0xFF1E4048) : const Color(0xFF102124),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: isSelected ? AppColors.primaryBright : Colors.white10,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                color: isSelected ? AppColors.primaryBright : Colors.white38,
                                size: 18,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                reason,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.white70,
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),

              // If "Other" selected, show text input
              Obx(() {
                if (selectedDeletionReason.value == 'Other') {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: TextField(
                      controller: otherReasonController,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Please specify the reason...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF102124),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              const SizedBox(height: 20),

              // CTAs: "Cancel" and "Next"
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBright,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Get.back();
                        // Proceed to remaining sessions warning if sessions left
                        if (remainingSessions.value > 0) {
                          _showRemainingSessionsWarningDialog(businessName);
                        } else {
                          _showFinalDeleteConfirmationDialog(businessName);
                        }
                      },
                      child: const Text('Next', style: TextStyle(fontWeight: FontWeight.bold)),
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

  /// Step 2: Warning for remaining sessions or Plan validity left
  void _showRemainingSessionsWarningDialog(String businessName) {
    agreeToDelete.value = false;

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF152A2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF4C2A1E),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.orangeAccent, size: 40),
              ),
              const SizedBox(height: 14),
              const Text(
                'Active Sessions Remaining!',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'You still have ${remainingSessions.value} unused sessions in ${activePlanName.value} (valid until ${expiryDate.value}). Deleting your affiliation will forfeit these remaining sessions immediately.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
              ),
              const SizedBox(height: 16),

              // User Agreement (T&C Checkbox, Required)
              Obx(() {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: agreeToDelete.value,
                      activeColor: Colors.redAccent,
                      checkColor: Colors.white,
                      onChanged: (val) => agreeToDelete.value = val ?? false,
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'I acknowledge that I will lose all remaining sessions and plan benefits with this fitness centre.',
                          style: TextStyle(color: Colors.white70, fontSize: 11.5),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 18),

              // CTAs: "Stay Affiliated" & "Delete Anyway"
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text('Stay Affiliated'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: agreeToDelete.value ? const Color(0xFFBE1E2D) : Colors.grey.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: agreeToDelete.value
                            ? () {
                                Get.back();
                                _showFinalDeleteConfirmationDialog(businessName);
                              }
                            : null,
                        child: const Text('Delete Anyway', style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Step 3: Final Confirmation Pop-up
  void _showFinalDeleteConfirmationDialog(String businessName) {
    agreeToDelete.value = false;

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF152A2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.delete_forever_rounded, color: Colors.redAccent, size: 48),
              const SizedBox(height: 14),
              const Text(
                'Final Confirmation',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Are you completely sure you want to permanently remove your connection with $businessName?',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 12.5),
              ),
              const SizedBox(height: 16),

              Obx(() {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: agreeToDelete.value,
                      activeColor: Colors.redAccent,
                      checkColor: Colors.white,
                      onChanged: (val) => agreeToDelete.value = val ?? false,
                    ),
                    const Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(top: 8.0),
                        child: Text(
                          'I agree to the terms and authorize the removal of this business connection.',
                          style: TextStyle(color: Colors.white70, fontSize: 11.5),
                        ),
                      ),
                    ),
                  ],
                );
              }),

              const SizedBox(height: 18),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text('Stay Affiliated'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {
                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: agreeToDelete.value ? const Color(0xFFBE1E2D) : Colors.grey.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: agreeToDelete.value
                            ? () {
                                Get.back();
                                _showAffiliationRemovedDialog(businessName);
                              }
                            : null,
                        child: const Text('Delete Anyway', style: TextStyle(fontWeight: FontWeight.bold)),
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Step 4: Affiliation Removed Pop-Up
  void _showAffiliationRemovedDialog(String businessName) {
    _businessService.deleteBusinessConnect('b1');

    // Remove affiliation from Cloud Firestore in real time
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = CustomerFirebaseService.to.currentUid.value;
      if (uid.isNotEmpty) {
        CustomerFirebaseService.to.removeAffiliation(
          uid,
          reason: selectedDeletionReason.value,
          customNotes: otherReasonController.text.trim(),
        );
      }
    }

    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF152A2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFF1D3E35),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline_rounded, color: AppColors.primaryBright, size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Affiliation Removed',
                style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Your affiliation with $businessName has been successfully removed.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white30),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Get.back();
                        executeLogout();
                      },
                      child: const Text('Log Out'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBright,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        Get.back();
                        // Redirect to Dashboard V1 (DRD requirement)
                        Get.offAllNamed(AppRoutes.customerDashboardV1);
                      },
                      child: const Text('Join New Business', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5)),
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

  // ============================================================
  // ACCOUNT DEACTIVATION (IN-REVIEW FOR 30 DAYS)
  // ============================================================
  void showAccountDeactivationDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF152A2F),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(22.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person_off_rounded, color: Colors.orangeAccent, size: 48),
              const SizedBox(height: 14),
              const Text(
                'Deactivate Account',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your account will be placed in review for 30 days. You will be logged out immediately. You can reactivate your account anytime within 30 days by signing back in.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 12.5, height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white70,
                        side: const BorderSide(color: Colors.white24),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFBE1E2D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Get.back();
                        executeLogout();
                      },
                      child: const Text('Deactivate', style: TextStyle(fontWeight: FontWeight.bold)),
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

  // ============================================================
  // LOGOUT DIALOG ("Leaving So Soon?")
  // ============================================================
  void showLogoutConfirmationDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 320,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A42),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2E5762), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Leaving So Soon?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 8),
              Container(height: 1, color: Colors.white30, margin: const EdgeInsets.symmetric(horizontal: 20)),
              const SizedBox(height: 12),
              const Text(
                'By Pressing Logout, You will exit the app.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white, width: 2),
                          backgroundColor: Colors.white.withValues(alpha: 0.15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          Get.back();
                          await executeLogout();
                        },
                        child: const Text('Logout', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBE1E2D),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => Get.back(),
                        child: const Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
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

  Future<void> executeLogout() async {
    try {
      await FirebaseAuthService.instance.signOut();
    } catch (e) {
      debugPrint('Logout notice: $e');
    }

    if (Get.isRegistered<CustomerFirebaseService>()) {
      await CustomerFirebaseService.to.clearLoginCredentials();
    }

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

    Get.offAllNamed(AppRoutes.welcome);
  }

  @override
  void onClose() {
    // Note: Do not dispose form controllers here as MyProfileController
    // is a permanent singleton shared across CustomerHomeShell and PersonalDetailsScreen.
    super.onClose();
  }
}
