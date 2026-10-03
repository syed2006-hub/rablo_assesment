import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/D1CM1_login/user_model.dart';
import '../../models/D1MM2_account_creation/account_model.dart';
import '../D1CM1_login/firebase_auth_service.dart';
import '../D1MM5_my_profile/profile_service.dart';

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

      // If not resolved from current Firebase user, inspect stored credentials and last user session
      if (!found && (isLoggedIn || lastUserId != null || lastUserEmail != null)) {
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
    } catch (e) {
      debugPrint('AccountCreationService storage initialization note: $e');
    }
  }

  /// Check and restore saved onboarding for a specific user (checks uid, email variants, and global backup)
  Future<bool> loadStoredOnboardingForUser(String? uid, String? email) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();

      final keysToTry = <String>[];
      if (uid != null && uid.isNotEmpty) keysToTry.add(uid);
      if (email != null && email.isNotEmpty) {
        keysToTry.add(email);
        keysToTry.add(email.toLowerCase());
        keysToTry.add(email.replaceAll('.', '_').replaceAll('@', '_'));
        keysToTry.add(email.toLowerCase().replaceAll('.', '_').replaceAll('@', '_'));
        keysToTry.add(email.replaceAll('.', '_'));
      }

      final lastUserId = _prefs?.getString('last_user_id');
      if (lastUserId != null && lastUserId.isNotEmpty && !keysToTry.contains(lastUserId)) {
        keysToTry.add(lastUserId);
      }
      final lastUserEmail = _prefs?.getString('last_user_email');
      if (lastUserEmail != null && lastUserEmail.isNotEmpty) {
        keysToTry.add(lastUserEmail);
        keysToTry.add(lastUserEmail.toLowerCase());
        keysToTry.add(lastUserEmail.replaceAll('.', '_').replaceAll('@', '_'));
      }

      for (final key in keysToTry) {
        final isSavedOnboarded = _prefs?.getBool('onboarded_$key') ?? false;
        final accountJsonString = _prefs?.getString('account_data_$key');

        if (accountJsonString != null && accountJsonString.isNotEmpty) {
          final Map<String, dynamic> data = jsonDecode(accountJsonString) as Map<String, dynamic>;
          final account = AccountModel.fromJson(data);
          activeAccount.value = account;
          isOnboarded.value = true;

          if (!registeredAccounts.any((a) => a.accountId == account.accountId)) {
            registeredAccounts.insert(0, account);
          }

          if (Get.isRegistered<ProfileService>()) {
            ProfileService.to.syncWithAccountModel(account);
          }
          return true;
        } else if (isSavedOnboarded) {
          isOnboarded.value = true;
          return true;
        }
      }

      // Check global active_account_data as fallback
      final globalAccountJson = _prefs?.getString('active_account_data');
      final isGlobalOnboarded =
          _prefs?.getBool('is_onboarded') ?? (_prefs?.getBool('last_user_onboarded') ?? false);

      if (globalAccountJson != null && globalAccountJson.isNotEmpty) {
        final Map<String, dynamic> data = jsonDecode(globalAccountJson) as Map<String, dynamic>;
        final account = AccountModel.fromJson(data);
        activeAccount.value = account;
        isOnboarded.value = account.isOnboarded || isGlobalOnboarded;

        if (!registeredAccounts.any((a) => a.accountId == account.accountId)) {
          registeredAccounts.insert(0, account);
        }

        if (Get.isRegistered<ProfileService>()) {
          ProfileService.to.syncWithAccountModel(account);
        }

        if (isOnboarded.value) {
          // Re-link with candidate keys so next lookup is immediate
          if (uid != null && uid.isNotEmpty) {
            await _prefs?.setBool('onboarded_$uid', true);
            await _prefs?.setString('account_data_$uid', globalAccountJson);
          }
          if (email != null && email.isNotEmpty) {
            final emailKey = email.replaceAll('.', '_').replaceAll('@', '_');
            await _prefs?.setBool('onboarded_$emailKey', true);
            await _prefs?.setString('account_data_$emailKey', globalAccountJson);
          }
          return true;
        }
      } else if (isGlobalOnboarded) {
        isOnboarded.value = true;
        return true;
      }
    } catch (e) {
      debugPrint('Error loading stored onboarding for user: $e');
    }

    isOnboarded.value = false;
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
      await _prefs?.setBool('is_onboarded', true);
      await _prefs?.setBool('last_user_onboarded', true);
      await _prefs?.setString('last_user_id', completedAccount.accountId);
      await _prefs?.setString('last_user_email', completedAccount.email);
      await _prefs?.setString('active_account_data', jsonString);

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
