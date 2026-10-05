import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/D1CM1_login/user_model.dart';
import '../../models/D1MM2_account_creation/account_model.dart';
import '../D1CM1_login/firebase_auth_service.dart';
import '../D1MM5_my_profile/profile_service.dart';
import '../firebase/customer_firebase_service.dart';

/// D1MM2 – Account Creation Service.
/// Handles member account persistence, onboarding state, and profile synchronization.
class AccountCreationService extends GetxService {
  static AccountCreationService get to => Get.find<AccountCreationService>();

  final RxList<AccountModel> registeredAccounts = <AccountModel>[].obs;
  final RxBool isOnboarded = false.obs;
  final Rx<UserModel?> currentUser = Rx<UserModel?>(null);
  final Rx<AccountModel?> activeAccount = Rx<AccountModel?>(null);

  SharedPreferences? _prefs;

  bool get hasActiveSession => _prefs?.getBool('is_logged_in') ?? false;

  @override
  void onInit() {
    super.onInit();
    initStorage();
  }

  /// Initialize persistent storage and restore onboarding state if available
  Future<void> initStorage() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final fbUser = FirebaseAuthService.instance.currentFirebaseUser;
      final lastUserId = _prefs?.getString('last_user_id');
      final lastUserEmail = _prefs?.getString('last_user_email');
      final isLoggedIn = _prefs?.getBool('is_logged_in') ?? false;

      bool found = false;

      if (fbUser != null) {
        found = await loadStoredOnboardingForUser(fbUser.uid, fbUser.email);
        if (currentUser.value == null) {
          currentUser.value = UserModel(
            uid: fbUser.uid,
            email: fbUser.email ?? '',
            displayName: (fbUser.displayName != null && fbUser.displayName!.isNotEmpty)
                ? fbUser.displayName!
                : (fbUser.email?.split('@').first ?? 'Fitness Member'),
            photoUrl: fbUser.photoURL,
            role: 'Customer',
            createdAt: DateTime.now(),
            isOnboarded: found,
          );
        }
      }

      // Only inspect stored credentials if is_logged_in flag is actively true and user is known
      if (!found && isLoggedIn && (lastUserId != null || lastUserEmail != null)) {
        found = await loadStoredOnboardingForUser(lastUserId, lastUserEmail);
        if (found && currentUser.value == null && activeAccount.value != null) {
          final acc = activeAccount.value!;
          currentUser.value = UserModel(
            uid: acc.uid ?? acc.accountId,
            email: acc.email,
            displayName: acc.fullName,
            role: 'Customer',
            createdAt: acc.registrationDate,
            isOnboarded: true,
          );
        }
      }

      if (!found) {
        isOnboarded.value = false;
        activeAccount.value = null;
      }
    } catch (e) {
      debugPrint('AccountCreationService storage initialization note: $e');
    }
  }

  /// Check and restore saved onboarding directly from Cloud Firestore (users/{uid})
  Future<bool> loadStoredOnboardingForUser(String? uid, String? email) async {
    final candidateUid = (uid != null && uid.isNotEmpty)
        ? uid
        : (email != null && email.isNotEmpty ? email.replaceAll('.', '_').replaceAll('@', '_') : null);

    if (candidateUid == null || candidateUid.isEmpty) {
      isOnboarded.value = false;
      activeAccount.value = null;
      return false;
    }

    // Reset previous account state for the new user check
    activeAccount.value = null;

    // 1. Primary Source of Truth: Cloud Firestore at users/{candidateUid}
    if (Get.isRegistered<CustomerFirebaseService>()) {
      try {
        final profileData = await CustomerFirebaseService.to.fetchUserProfile(candidateUid);
        if (profileData != null && profileData.isNotEmpty && profileData['isOnboarded'] == true) {
          final account = AccountModel(
            uid: candidateUid,
            accountId: profileData['accountId']?.toString() ?? candidateUid,
            fullName: profileData['fullName']?.toString() ?? '',
            email: profileData['email']?.toString() ?? (email ?? ''),
            phoneNumber: profileData['contactNumber']?.toString() ?? profileData['phoneNumber']?.toString() ?? '',
            gender: profileData['gender']?.toString() ?? 'Male',
            dateOfBirth: profileData['dateOfBirth']?.toString() ?? profileData['dob']?.toString() ?? '',
            profession: profileData['profession']?.toString() ?? 'Student',
            objectives: (profileData['objectives'] as List?)?.map((e) => e.toString()).toList() ?? [],
            addressLine1: profileData['personalAddress']?.toString() ?? profileData['addressLine1']?.toString() ?? '',
            addressLine2: profileData['addressLine2']?.toString() ?? '',
            city: profileData['city']?.toString() ?? '',
            state: profileData['state']?.toString() ?? '',
            country: profileData['country']?.toString() ?? 'India',
            pinCode: profileData['pinCode']?.toString() ?? profileData['pincode']?.toString() ?? '',
            preferredLanguages: (profileData['preferredLanguages'] as List?)?.map((e) => e.toString()).toList() ?? ['English'],
            acceptedTerms: profileData['termsAccepted'] == true,
            promotionalConsent: profileData['promotionalConsent'] == true,
            registrationDate: DateTime.now(),
            isOnboarded: true,
          );
          activeAccount.value = account;
          isOnboarded.value = true;
          if (!registeredAccounts.any((a) => a.accountId == account.accountId)) {
            registeredAccounts.insert(0, account);
          }
          if (Get.isRegistered<ProfileService>()) {
            ProfileService.to.syncWithAccountModel(account);
          }
          return true;
        } else {
          // Document does not exist or isOnboarded is false in Cloud Firestore
          isOnboarded.value = false;
          activeAccount.value = null;
          return false;
        }
      } catch (e) {
        debugPrint('Firestore loadStoredOnboarding notice: $e');
      }
    }

    // 2. Offline fallback ONLY for THIS specific candidateUid
    try {
      _prefs ??= await SharedPreferences.getInstance();
      final isSavedOnboarded = _prefs?.getBool('onboarded_$candidateUid') ?? false;
      final accountJsonString = _prefs?.getString('account_data_$candidateUid');

      if (accountJsonString != null && accountJsonString.isNotEmpty && isSavedOnboarded) {
        final Map<String, dynamic> data = jsonDecode(accountJsonString) as Map<String, dynamic>;
        final account = AccountModel.fromJson(data);
        if (account.isOnboarded) {
          activeAccount.value = account;
          isOnboarded.value = true;
          if (!registeredAccounts.any((a) => a.accountId == account.accountId)) {
            registeredAccounts.insert(0, account);
          }
          if (Get.isRegistered<ProfileService>()) {
            ProfileService.to.syncWithAccountModel(account);
          }
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error loading stored onboarding for user: $e');
    }

    isOnboarded.value = false;
    activeAccount.value = null;
    return false;
  }

  /// Save account creation details and mark onboarding as complete
  Future<AccountModel> createAccount(AccountModel account) async {
    // Simulate async network request
    await Future.delayed(const Duration(milliseconds: 300));

    final completedAccount = account.copyWith(isOnboarded: true);

    try {
      _prefs ??= await SharedPreferences.getInstance();
      final jsonString = jsonEncode(completedAccount.toJson());

      // 1. Mark device and active session flags
      await _prefs?.setBool('is_logged_in', true);
      await _prefs?.setString('last_user_id', completedAccount.accountId);
      await _prefs?.setString('last_user_email', completedAccount.email);

      // 2. Persist across all candidate keys
      final candidateKeys = <String>{};
      if (completedAccount.accountId.isNotEmpty) candidateKeys.add(completedAccount.accountId);
      if (completedAccount.uid != null && completedAccount.uid!.isNotEmpty) {
        candidateKeys.add(completedAccount.uid!);
      }
      if (completedAccount.email.isNotEmpty) {
        candidateKeys.add(completedAccount.email);
        candidateKeys.add(completedAccount.email.toLowerCase());
        candidateKeys.add(completedAccount.email.replaceAll('.', '_').replaceAll('@', '_'));
        candidateKeys.add(completedAccount.email.toLowerCase().replaceAll('.', '_').replaceAll('@', '_'));
      }

      final fbUser = FirebaseAuthService.instance.currentFirebaseUser;
      if (fbUser != null) {
        if (fbUser.uid.isNotEmpty) candidateKeys.add(fbUser.uid);
        if (fbUser.email != null && fbUser.email!.isNotEmpty) {
          candidateKeys.add(fbUser.email!);
          candidateKeys.add(fbUser.email!.toLowerCase());
          candidateKeys.add(fbUser.email!.replaceAll('.', '_').replaceAll('@', '_'));
          candidateKeys.add(fbUser.email!.toLowerCase().replaceAll('.', '_').replaceAll('@', '_'));
        }
      }

      final curUser = currentUser.value;
      if (curUser != null) {
        if (curUser.uid.isNotEmpty) candidateKeys.add(curUser.uid);
        if (curUser.email.isNotEmpty) {
          candidateKeys.add(curUser.email);
          candidateKeys.add(curUser.email.toLowerCase());
          candidateKeys.add(curUser.email.replaceAll('.', '_').replaceAll('@', '_'));
          candidateKeys.add(curUser.email.toLowerCase().replaceAll('.', '_').replaceAll('@', '_'));
        }
      }

      for (final key in candidateKeys) {
        await _prefs?.setBool('onboarded_$key', true);
        await _prefs?.setString('account_data_$key', jsonString);
      }
    } catch (e) {
      debugPrint('Error saving account to SharedPreferences: $e');
    }

    // Save directly to Cloud Firestore
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final userUid = completedAccount.uid ?? completedAccount.accountId;
      await CustomerFirebaseService.to.saveUserProfile(userUid, {
        'accountId': completedAccount.accountId,
        'fullName': completedAccount.fullName,
        'email': completedAccount.email,
        'contactNumber': completedAccount.phoneNumber,
        'phoneNumber': completedAccount.phoneNumber,
        'gender': completedAccount.gender,
        'dateOfBirth': completedAccount.dateOfBirth,
        'dob': completedAccount.dateOfBirth,
        'profession': completedAccount.profession,
        'objectives': completedAccount.objectives,
        'personalAddress': completedAccount.addressLine1,
        'addressLine1': completedAccount.addressLine1,
        'addressLine2': completedAccount.addressLine2,
        'city': completedAccount.city,
        'state': completedAccount.state,
        'country': completedAccount.country,
        'pinCode': completedAccount.pinCode,
        'preferredLanguages': completedAccount.preferredLanguages,
        'termsAccepted': completedAccount.acceptedTerms,
        'promotionalConsent': completedAccount.promotionalConsent,
        'isOnboarded': true,
        'role': 'Customer',
      });
    }

    registeredAccounts.insert(0, completedAccount);
    activeAccount.value = completedAccount;
    isOnboarded.value = true;

    // Update currentUser with isOnboarded = true
    if (currentUser.value != null) {
      currentUser.value = currentUser.value!.copyWith(isOnboarded: true);
    }

    // Sync into ProfileService
    if (Get.isRegistered<ProfileService>()) {
      ProfileService.to.syncWithAccountModel(completedAccount);
    }

    return completedAccount;
  }

  /// Clear active session on logout (preserves persistent records for future logins)
  Future<void> clearActiveSession() async {
    currentUser.value = null;
    activeAccount.value = null;
    isOnboarded.value = false;
    try {
      _prefs ??= await SharedPreferences.getInstance();
      await _prefs?.setBool('is_logged_in', false);
    } catch (e) {
      debugPrint('Notice clearing session in SharedPreferences: $e');
    }
  }
}
