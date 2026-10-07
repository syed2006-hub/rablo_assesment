import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../api/api_state.dart';
import '../../models/D1CM6_my_profile/transaction_model.dart';
import '../../services/api/bank_account_api_service.dart';
import '../../services/firebase/customer_firebase_service.dart';
import '../../widgets/form_feedback_widgets.dart';

enum TimeFilter { today, thisWeek, thisMonth }

enum AccountViewTab { transactions, bankAccount }

class BankAccountController extends GetxController {
  static BankAccountController get to => Get.find<BankAccountController>();

  final isBalanceVisible = false.obs;
  final selectedFilter = TimeFilter.today.obs;
  final activeTab = AccountViewTab.bankAccount.obs;
  final isLoading = false.obs;
  final isSubmittingBankAccount = false.obs;

  // View States for Day 9 state handling (Loading, Success, Empty, Error)
  final Rx<ViewState> accountsState = ViewState.initial.obs;
  final Rx<ViewState> transactionsState = ViewState.initial.obs;
  final RxString accountsErrorMessage = ''.obs;
  final RxString transactionsErrorMessage = ''.obs;
  final Rx<int?> accountsStatusCode = Rx<int?>(null);
  final Rx<int?> transactionsStatusCode = Rx<int?>(null);

  // Form API Validation Errors for Day 10
  final Rx<Map<String, dynamic>?> bankFormErrors = Rx<Map<String, dynamic>?>(null);
  final RxString bankFormGeneralError = ''.obs;

  final totalAmount = '20,014.00';
  final transactionCount = 3.obs;

  // Connected REST API Service
  late final BankAccountApiService _apiService;

  // Reactive Bank Accounts list from REST Backend / Cloud Firestore
  final RxList<Map<String, dynamic>> bankAccounts = <Map<String, dynamic>>[
    {
      'id': 'acc_1',
      'bankName': 'HDFC Bank',
      'accountHolderName': 'Alex Morgan',
      'accountNumber': '**** **** 4892',
      'fullAccountNumber': '50100234564892',
      'ifscCode': 'HDFC0001234',
      'branch': 'Indiranagar, Bengaluru',
      'isPrimary': true,
      'isVerified': true,
      'balance': '20,014.00',
    },
  ].obs;

  // Reactive Transactions list from REST Backend / Cloud Firestore
  final RxList<TransactionModel> transactions = <TransactionModel>[
    TransactionModel(
      id: '122354',
      productName: 'Product Name',
      planType: 'Period-Based Plan',
      status: TransactionStatus.success,
      amount: '1514.00',
      date: '26/11/2024',
      validity: '30 Mar 2024',
      transactionalId: '123454878',
    ),
    TransactionModel(
      id: '122355',
      productName: 'Product Name',
      planType: 'Session-Based Plan',
      status: TransactionStatus.pending,
      amount: '1514.00',
      date: '25/11/2024',
      validity: '30 Mar 2024',
      transactionalId: '123454879',
    ),
    TransactionModel(
      id: '122356',
      productName: 'Product Name',
      planType: 'Session-Based Plan',
      status: TransactionStatus.failed,
      amount: '1514.00',
      date: '24/11/2024',
      validity: '30 Mar 2024',
      transactionalId: '123454880',
    ),
    TransactionModel(
      id: '122357',
      productName: 'Product Name',
      planType: 'Period-Based Plan',
      status: TransactionStatus.pending,
      amount: '1514.00',
      date: '23/11/2024',
      validity: '30 Mar 2024',
      transactionalId: '123454881',
    ),
    TransactionModel(
      id: '122358',
      productName: 'Product Name',
      planType: 'Session-Based Plan',
      status: TransactionStatus.success,
      amount: '1514.00',
      date: '22/11/2024',
      validity: '30 Mar 2024',
      transactionalId: '123454882',
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    _apiService = Get.isRegistered<BankAccountApiService>()
        ? Get.find<BankAccountApiService>()
        : Get.put(BankAccountApiService());

    // Asynchronously synchronize with Backend REST APIs and Firestore
    fetchBankAccounts();
    fetchTransactions();
  }

  // ---------------------------------------------------------------------------
  // 1. Fetch Bank Accounts with Loading, Success, Empty, Error state handling
  // ---------------------------------------------------------------------------
  Future<void> fetchBankAccounts() async {
    accountsState.value = ViewState.loading;
    isLoading.value = true;
    accountsErrorMessage.value = '';
    accountsStatusCode.value = null;

    try {
      if (Get.isRegistered<CustomerFirebaseService>()) {
        final uid = CustomerFirebaseService.to.currentUid.value;
        final list = await CustomerFirebaseService.to.getBankAccountsFromFirestore(uid);
        if (list.isNotEmpty) {
          bankAccounts.assignAll(list);
          if (list.first['isBalanceVisible'] != null) {
            isBalanceVisible.value = list.first['isBalanceVisible'] == true;
          }
          accountsState.value = ViewState.success;
          return;
        }
      }

      final res = await _apiService.getBankAccounts();
      if (res.isSuccess && res.data != null && res.data!['accounts'] is List) {
        final list = (res.data!['accounts'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        if (list.isNotEmpty) {
          bankAccounts.assignAll(list);
          accountsState.value = ViewState.success;
        } else {
          bankAccounts.clear();
          accountsState.value = ViewState.empty;
        }
      } else {
        accountsState.value = ViewState.error;
        accountsErrorMessage.value = res.message;
        accountsStatusCode.value = res.statusCode;
      }
    } catch (e) {
      debugPrint('[BankAccountController] fetchBankAccounts error: $e');
      accountsState.value = ViewState.error;
      accountsErrorMessage.value = 'Failed to load bank accounts. Check network connection.';
      accountsStatusCode.value = 503;
    } finally {
      isLoading.value = false;
      if (accountsState.value == ViewState.loading) {
        accountsState.value = bankAccounts.isEmpty ? ViewState.empty : ViewState.success;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 2. Fetch Transactions with Loading, Success, Empty, Error state handling
  // ---------------------------------------------------------------------------
  Future<void> fetchTransactions() async {
    transactionsState.value = ViewState.loading;
    transactionsErrorMessage.value = '';
    transactionsStatusCode.value = null;

    try {
      if (Get.isRegistered<CustomerFirebaseService>()) {
        final uid = CustomerFirebaseService.to.currentUid.value;
        final fsTxList = await CustomerFirebaseService.to.getTransactionsFromFirestore(
          uid,
          filter: selectedFilter.value.name,
        );
        if (fsTxList.isNotEmpty) {
          final mapped = fsTxList.map((m) => TransactionModel.fromJson(m)).toList();
          transactions.assignAll(mapped);
          transactionCount.value = transactions.length;
          transactionsState.value = ViewState.success;
          return;
        }
      }

      final res = await _apiService.getTransactions(filter: selectedFilter.value);
      if (res.isSuccess && res.data != null) {
        if (res.data!.isNotEmpty) {
          transactions.assignAll(res.data!);
          transactionCount.value = transactions.length;
          transactionsState.value = ViewState.success;
        } else {
          transactions.clear();
          transactionCount.value = 0;
          transactionsState.value = ViewState.empty;
        }
      } else {
        transactionsState.value = ViewState.error;
        transactionsErrorMessage.value = res.message;
        transactionsStatusCode.value = res.statusCode;
      }
    } catch (e) {
      debugPrint('[BankAccountController] fetchTransactions error: $e');
      transactionsState.value = ViewState.error;
      transactionsErrorMessage.value = 'Network error while loading transactions.';
      transactionsStatusCode.value = 503;
    } finally {
      if (transactionsState.value == ViewState.loading) {
        transactionsState.value = transactions.isEmpty ? ViewState.empty : ViewState.success;
      }
    }
  }

  // ---------------------------------------------------------------------------
  // 3. Add Bank Account with Validation, Error Handling & Duplicate Guard
  // ---------------------------------------------------------------------------
  Future<bool> addBankAccount({
    required String bankName,
    required String accountHolderName,
    required String fullAccountNumber,
    required String ifscCode,
    required String branch,
  }) async {
    // Duplicate submission protection
    if (isSubmittingBankAccount.value) return false;
    isSubmittingBankAccount.value = true;
    bankFormErrors.value = null;
    bankFormGeneralError.value = '';

    try {
      // Duplicate account check
      final exists = bankAccounts.any((a) =>
          a['fullAccountNumber'] == fullAccountNumber ||
          (a['accountNumber'] != null && a['accountNumber'].toString().endsWith(
              fullAccountNumber.length > 4 ? fullAccountNumber.substring(fullAccountNumber.length - 4) : fullAccountNumber)));
      if (exists) {
        bankFormGeneralError.value = 'This bank account number is already linked.';
        bankFormErrors.value = {'accountNumber': 'Account already exists in system'};
        AppFeedback.showError(
          title: 'Duplicate Account',
          message: 'This bank account is already linked to your profile.',
        );
        isSubmittingBankAccount.value = false;
        return false;
      }

      final maskedNumber = fullAccountNumber.length > 4
          ? '**** **** ${fullAccountNumber.substring(fullAccountNumber.length - 4)}'
          : fullAccountNumber;
      final accId = 'acc_${DateTime.now().millisecondsSinceEpoch}';
      final newAcc = {
        'id': accId,
        'bankName': bankName,
        'accountHolderName': accountHolderName,
        'accountNumber': maskedNumber,
        'fullAccountNumber': fullAccountNumber,
        'ifscCode': ifscCode.toUpperCase(),
        'branch': branch,
        'isPrimary': bankAccounts.isEmpty,
        'isVerified': true,
        'balance': '0.00',
        'isBalanceVisible': false,
      };

      if (Get.isRegistered<CustomerFirebaseService>()) {
        final uid = CustomerFirebaseService.to.currentUid.value;
        await CustomerFirebaseService.to.saveBankAccountToFirestore(uid, newAcc);
      }

      final res = await _apiService.addBankAccount(
        bankName: bankName,
        accountHolderName: accountHolderName,
        fullAccountNumber: fullAccountNumber,
        ifscCode: ifscCode.toUpperCase(),
        branch: branch,
      );

      if (!res.isSuccess) {
        bankFormGeneralError.value = res.message;
        bankFormErrors.value = res.errors;
        AppFeedback.showError(
          title: 'API Validation Error',
          message: res.message,
          onRetry: () => addBankAccount(
            bankName: bankName,
            accountHolderName: accountHolderName,
            fullAccountNumber: fullAccountNumber,
            ifscCode: ifscCode,
            branch: branch,
          ),
        );
        isSubmittingBankAccount.value = false;
        return false;
      }

      bankAccounts.add(newAcc);
      accountsState.value = ViewState.success;

      AppFeedback.showSuccess(
        title: 'Bank Account Linked',
        message: '$bankName ending with ${maskedNumber.split(' ').last} added successfully.',
      );
      return true;
    } catch (e) {
      debugPrint('[BankAccountController] addBankAccount error: $e');
      bankFormGeneralError.value = 'Network failure during bank account linking.';
      AppFeedback.showNetworkError(
        onRetry: () => addBankAccount(
          bankName: bankName,
          accountHolderName: accountHolderName,
          fullAccountNumber: fullAccountNumber,
          ifscCode: ifscCode,
          branch: branch,
        ),
      );
      return false;
    } finally {
      isSubmittingBankAccount.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 4. Update Bank Account in Cloud Firestore & REST API
  // ---------------------------------------------------------------------------
  Future<bool> updateBankAccount(String id, Map<String, dynamic> data) async {
    isLoading.value = true;
    try {
      if (Get.isRegistered<CustomerFirebaseService>()) {
        final uid = CustomerFirebaseService.to.currentUid.value;
        await CustomerFirebaseService.to.updateBankAccountInFirestore(uid, id, data);
      }
      try {
        await _apiService.updateBankAccount(id, data);
      } catch (_) {}
      await fetchBankAccounts();
      AppFeedback.showSuccess(
        title: 'Account Updated',
        message: 'Bank account details updated successfully.',
      );
      return true;
    } catch (e) {
      debugPrint('[BankAccountController] updateBankAccount error: $e');
      AppFeedback.showError(
        title: 'Update Failed',
        message: 'Could not update bank details: $e',
        onRetry: () => updateBankAccount(id, data),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // 5. Toggle Balance Visibility
  // ---------------------------------------------------------------------------
  Future<void> toggleBalanceVisibility() async {
    isBalanceVisible.value = !isBalanceVisible.value;
    try {
      final primaryId = bankAccounts.isNotEmpty ? bankAccounts.first['id'] ?? 'acc_1' : 'acc_1';
      if (Get.isRegistered<CustomerFirebaseService>()) {
        final uid = CustomerFirebaseService.to.currentUid.value;
        await CustomerFirebaseService.to.patchBalanceVisibilityInFirestore(uid, primaryId, isBalanceVisible.value);
      }
      try {
        await _apiService.patchBalanceVisibility(primaryId, isBalanceVisible.value);
      } catch (_) {}
    } catch (e) {
      debugPrint('[BankAccountController] toggleBalanceVisibility error: $e');
    }
  }

  // ---------------------------------------------------------------------------
  // 6. Delete Bank Account from Cloud Firestore & REST API
  // ---------------------------------------------------------------------------
  Future<bool> deleteBankAccount(String id) async {
    isLoading.value = true;
    try {
      if (Get.isRegistered<CustomerFirebaseService>()) {
        final uid = CustomerFirebaseService.to.currentUid.value;
        await CustomerFirebaseService.to.deleteBankAccountFromFirestore(uid, id);
      }
      try {
        await _apiService.deleteBankAccount(id);
      } catch (_) {}
      bankAccounts.removeWhere((acc) => acc['id'] == id);
      if (bankAccounts.isEmpty) {
        accountsState.value = ViewState.empty;
      }
      AppFeedback.showSuccess(
        title: 'Account Removed',
        message: 'Bank account unlinked from profile.',
      );
      return true;
    } catch (e) {
      debugPrint('[BankAccountController] deleteBankAccount error: $e');
      AppFeedback.showError(
        title: 'Removal Failed',
        message: 'Could not remove bank account.',
        onRetry: () => deleteBankAccount(id),
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(TimeFilter filter) {
    selectedFilter.value = filter;
    fetchTransactions();
  }

  void setActiveTab(AccountViewTab tab) {
    activeTab.value = tab;
  }
}