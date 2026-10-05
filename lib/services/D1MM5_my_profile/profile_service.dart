import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../models/D1CM1_login/user_model.dart';
import '../../models/D1MM2_account_creation/account_model.dart';
import '../../models/D1MM5_my_profile/profile_model.dart';
import '../D1CM1_login/firebase_auth_service.dart';
import '../D1MM2_account_creation/account_creation_service.dart';
import '../api/profile_api_service.dart';
import '../firebase/customer_firebase_service.dart';

/// D1MM5 – Profile Service managing gym administrator / customer profile details.
/// Automatically synchronizes with Cloud Firestore, Backend REST APIs, Firebase Auth, and AccountCreationService.
class ProfileService extends GetxService {
  static ProfileService get to => Get.find<ProfileService>();

  late final ProfileApiService _apiService;

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
    _apiService = Get.isRegistered<ProfileApiService>()
        ? Get.find<ProfileApiService>()
        : Get.put(ProfileApiService());

    syncFromCurrentAuth();
    fetchProfileFromBackend();

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

  /// HTTP GET - Fetch profile directly from Cloud Firestore
  Future<void> fetchProfileFromBackend() async {
    try {
      if (Get.isRegistered<CustomerFirebaseService>()) {
        final uid = CustomerFirebaseService.to.currentUid.value.isNotEmpty
            ? CustomerFirebaseService.to.currentUid.value
            : (FirebaseAuthService.instance.currentFirebaseUser?.uid ?? '');
        if (uid.isNotEmpty) {
          final profileMap = await CustomerFirebaseService.to.fetchUserProfile(uid);
          if (profileMap != null && profileMap.isNotEmpty) {
            _syncWithProfileMap(profileMap);
            return;
          }
        }
      }
      final res = await _apiService.getProfile();
      if (res.isSuccess && res.data != null) {
        profile.value = res.data!;
      }
    } catch (e) {
      debugPrint('[ProfileService] fetchProfileFromBackend error: $e');
    }
  }

  void _syncWithProfileMap(Map<String, dynamic> map) {
    profile.value = profile.value.copyWith(
      id: map['uid'] ?? map['id'] ?? profile.value.id,
      fullName: map['fullName'] ?? profile.value.fullName,
      email: map['email'] ?? profile.value.email,
      phoneNumber: map['contactNumber'] ?? map['phoneNumber'] ?? profile.value.phoneNumber,
      gender: map['gender'] ?? profile.value.gender,
      dob: map['dateOfBirth'] ?? map['dob'] ?? profile.value.dob,
      addressLine1: map['personalAddress'] ?? map['addressLine1'] ?? profile.value.addressLine1,
      addressLine2: map['addressLine2'] ?? profile.value.addressLine2,
      city: map['city'] ?? profile.value.city,
      state: map['state'] ?? profile.value.state,
      country: map['country'] ?? profile.value.country,
      pincode: map['pinCode'] ?? map['pincode'] ?? profile.value.pincode,
      isVerified: map['isVerified'] == true,
      photoUrl: map['photoUrl'] ?? profile.value.photoUrl,
    );
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

  /// HTTP PUT - Update profile details and sync directly to Cloud Firestore & Firebase Auth
  Future<void> updateProfile(ProfileModel updated) async {
    profile.value = updated;

    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = updated.id.isNotEmpty
          ? updated.id
          : (CustomerFirebaseService.to.currentUid.value.isNotEmpty
              ? CustomerFirebaseService.to.currentUid.value
              : 'USER-CURRENT');
      await CustomerFirebaseService.to.saveUserProfile(uid, {
        'fullName': updated.fullName,
        'email': updated.email,
        'contactNumber': updated.phoneNumber,
        'phoneNumber': updated.phoneNumber,
        'gender': updated.gender,
        'role': updated.role,
        'dateOfBirth': updated.dob,
        'personalAddress': updated.addressLine1,
        'addressLine1': updated.addressLine1,
        'addressLine2': updated.addressLine2,
        'city': updated.city,
        'state': updated.state,
        'country': updated.country,
        'pinCode': updated.pincode,
        'preferredLanguages': updated.preferredLanguages,
        'isVerified': updated.isVerified,
        'photoUrl': updated.photoUrl,
        'isOnboarded': true,
      });
    }

    // Send PUT request to backend if active
    try {
      await _apiService.updateProfile(updated);
    } catch (e) {
      debugPrint('[ProfileService] PUT profile error: $e');
    }

    try {
      final fbUser = FirebaseAuthService.instance.currentFirebaseUser;
      if (fbUser != null && updated.fullName.isNotEmpty) {
        await fbUser.updateDisplayName(updated.fullName);
      }
    } catch (e) {
      debugPrint('Firebase updateDisplayName notice: $e');
    }
  }

  /// HTTP PATCH - Toggle verification status in Cloud Firestore
  Future<void> toggleVerification() async {
    final updated = profile.value.copyWith(
      isVerified: !profile.value.isVerified,
    );
    profile.value = updated;

    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = updated.id.isNotEmpty ? updated.id : CustomerFirebaseService.to.currentUid.value;
      if (uid.isNotEmpty) {
        await CustomerFirebaseService.to.updateUserFields(uid, {'isVerified': updated.isVerified});
      }
    }

    try {
      await _apiService.patchVerification();
    } catch (e) {
      debugPrint('[ProfileService] PATCH verification error: $e');
    }
  }

  /// HTTP PATCH - Update photo URL in Cloud Firestore
  Future<void> setPhotoUrl(String url) async {
    final updated = profile.value.copyWith(photoUrl: url);
    profile.value = updated;

    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = updated.id.isNotEmpty ? updated.id : CustomerFirebaseService.to.currentUid.value;
      if (uid.isNotEmpty) {
        await CustomerFirebaseService.to.updateUserFields(uid, {'photoUrl': url});
      }
    }

    try {
      await _apiService.patchPhotoUrl(url);
    } catch (e) {
      debugPrint('[ProfileService] PATCH photo error: $e');
    }
  }

  /// HTTP DELETE - Deactivate account
  Future<bool> deleteProfile() async {
    try {
      final res = await _apiService.deleteProfile(profile.value.id);
      return res.isSuccess;
    } catch (e) {
      debugPrint('[ProfileService] DELETE profile error: $e');
      return false;
    }
  }
}
