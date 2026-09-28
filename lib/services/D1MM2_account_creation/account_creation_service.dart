import 'package:get/get.dart';
import '../../models/D1MM2_account_creation/account_model.dart';

/// D1MM2 – Account Creation Service.
/// Handles member account and business account creations.
class AccountCreationService extends GetxService {
  static AccountCreationService get to => Get.find<AccountCreationService>();

  final RxList<AccountModel> registeredAccounts = <AccountModel>[].obs;

  Future<AccountModel> createAccount(AccountModel account) async {
    // Simulate async network request
    await Future.delayed(const Duration(milliseconds: 400));
    registeredAccounts.insert(0, account);
    return account;
  }
}
