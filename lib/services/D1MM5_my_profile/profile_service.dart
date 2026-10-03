import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../models/D1CM1_login/user_model.dart';
import '../../models/D1MM2_account_creation/account_model.dart';
import '../../models/D1MM5_my_profile/profile_model.dart';
import '../D1CM1_login/firebase_auth_service.dart';
import '../D1MM2_account_creation/account_creation_service.dart';

/// D1MM5 – Profile Service managing gym administrator / customer profile details.
/// Automatically synchronizes with Firebase Auth and AccountCreationService.
class ProfileService extends GetxService {
  static ProfileService get to => Get.find<ProfileService>();

  final Rx<ProfileModel> profile = ProfileModel(
    id: 'MEM-001',
    fullName: 'Manager Name',
    email: 'member@fitness.com',
    phoneNumber: '+91 98765 - 43210',
    gender: 'Male',
    role: 'Manager/Owner',
    dob: '09 - 11 - 2024',
    addressLine1: 'User input, Sample text',
    addressLine2: 'Enter your colony or locality',
    country: 'India',
    state: 'Karnataka',
    city: 'Bengaluru',
    pincode: '560038',
    preferredLanguages: const ['English', 'Hindi', 'Kannada'],
    isVerified: false,
    photoUrl: 'assets/images/profile_avatar.png',
    gymBranch: 'Koramangala Prime Club, Bengaluru',
    bio: 'Fitness and gym management profile.',
    memberSince: DateTime(2024, 1, 1),
    totalWorkoutsSupervised: 1420,
    rating: 4.9,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    syncFromCurrentAuth();

    // Listen to AccountCreationService updates
    if (Get.isRegistered<AccountCreationService>()) {
      ever(AccountCreationService.to.currentUser, (UserModel? user) {
        if (user != null) {
          syncWithUserModel(user);
        }
      });
      ever(AccountCreationService.to.activeAccount, (AccountModel? account) {
        if (account != null) {
          syncWithAccountModel(account);
        }
      });
    }
  }

  /// Sync with current Firebase Auth user
  void syncFromCurrentAuth() {
    final fbUser = FirebaseAuthService.instance.currentFirebaseUser;
    if (fbUser != null) {
      String name = 'Manager Name';
      if (fbUser.displayName != null && fbUser.displayName!.isNotEmpty) {
        name = fbUser.displayName!;
      } else if (fbUser.email != null && fbUser.email!.isNotEmpty) {
        final prefix = fbUser.email!.split('@').first;
        if (prefix.isNotEmpty) {
          name = prefix[0].toUpperCase() + prefix.substring(1);
        }
      }

      profile.value = profile.value.copyWith(
        id: fbUser.uid,
        fullName: name,
        email: fbUser.email ?? profile.value.email,
        photoUrl: fbUser.photoURL,
        isVerified: fbUser.emailVerified,
      );
    }
  }

  void syncWithUserModel(UserModel user) {
    profile.value = profile.value.copyWith(
      id: user.uid,
      fullName: user.displayName,
      email: user.email,
      photoUrl: user.photoUrl,
    );
  }

  void syncWithAccountModel(AccountModel account) {
    profile.value = profile.value.copyWith(
      fullName: account.fullName.isNotEmpty ? account.fullName : profile.value.fullName,
      phoneNumber: account.phoneNumber.isNotEmpty ? account.phoneNumber : profile.value.phoneNumber,
      gender: account.gender.isNotEmpty ? account.gender : profile.value.gender,
      dob: (account.dateOfBirth != null && account.dateOfBirth!.isNotEmpty)
          ? account.dateOfBirth!
          : profile.value.dob,
      addressLine1: (account.addressLine1 != null && account.addressLine1!.isNotEmpty)
          ? account.addressLine1!
          : profile.value.addressLine1,
      city: (account.city != null && account.city!.isNotEmpty)
          ? account.city!
          : profile.value.city,
      state: (account.state != null && account.state!.isNotEmpty)
          ? account.state!
          : profile.value.state,
      pincode: (account.pinCode != null && account.pinCode!.isNotEmpty)
          ? account.pinCode!
          : profile.value.pincode,
      preferredLanguages: (account.preferredLanguages != null && account.preferredLanguages!.isNotEmpty)
          ? account.preferredLanguages!
          : profile.value.preferredLanguages,
    );
  }

  /// Update profile details and sync display name to Firebase Auth if possible
  Future<void> updateProfile(ProfileModel updated) async {
    profile.value = updated;

    try {
      final fbUser = FirebaseAuthService.instance.currentFirebaseUser;
      if (fbUser != null && updated.fullName.isNotEmpty) {
        await fbUser.updateDisplayName(updated.fullName);
      }
    } catch (e) {
      debugPrint('Firebase updateDisplayName notice: $e');
    }
  }

  void toggleVerification() {
    profile.value = profile.value.copyWith(
      isVerified: !profile.value.isVerified,
    );
  }

  void setPhotoUrl(String url) {
    profile.value = profile.value.copyWith(photoUrl: url);
  }
}
