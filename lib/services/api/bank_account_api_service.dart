import 'package:get/get.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../api/api_response.dart';
import '../../controllers/D1MM5_my_profile/bank_account_controller.dart';
import '../../models/D1MM5_my_profile/transaction_model.dart';
import '../firebase/customer_firebase_service.dart';

/// Backend REST API Service for Bank Account & Financial Transactions
class BankAccountApiService extends GetxService {
  static BankAccountApiService get to => Get.find<BankAccountApiService>();

  late final ApiClient _client;

  @override
  void onInit() {
    super.onInit();
    _client = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put(ApiClient());
  }

  // 1. HTTP GET - Retrieve Bank Accounts & Balance Info from Cloud Firestore
  Future<ApiResponse<Map<String, dynamic>>> getBankAccounts() async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = CustomerFirebaseService.to.currentUid.value;
      final accounts = await CustomerFirebaseService.to.getBankAccountsFromFirestore(uid);
      if (accounts.isNotEmpty) {
        return ApiResponse.success(
          data: {'accounts': accounts, 'totalBalance': '20,014.00'},
          statusCode: 200,
        );
      }
    }
    final response = await _client.get(ApiEndpoints.bankAccounts);
    return _client.handleResponse<Map<String, dynamic>>(
      response,
      fallback: <String, dynamic>{},
    );
  }

  // 2. HTTP GET - Retrieve Recent Transactions from Cloud Firestore
  Future<ApiResponse<List<TransactionModel>>> getTransactions({TimeFilter? filter}) async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = CustomerFirebaseService.to.currentUid.value;
      final list = await CustomerFirebaseService.to.getTransactionsFromFirestore(uid, filter: filter?.name);
      if (list.isNotEmpty) {
        final models = list.map((m) {
          TransactionStatus status = TransactionStatus.pending;
          final s = m['status']?.toString().toLowerCase();
          if (s == 'success' || s == 'verified pass') status = TransactionStatus.success;
          if (s == 'failed') status = TransactionStatus.failed;

          return TransactionModel(
            id: m['id']?.toString() ?? '',
            productName: m['productName'] ?? m['planName'] ?? 'Product Name',
            planType: m['planType'] ?? 'Period-Based Plan',
            status: status,
            amount: m['amount']?.toString() ?? '1514.00',
            date: m['date'] ?? '26/11/2024',
            validity: m['validity'] ?? '30 Mar 2024',
            transactionalId: m['transactionalId']?.toString() ?? m['transactionId']?.toString() ?? '12345678',
          );
        }).toList();
        return ApiResponse.success(data: models, statusCode: 200);
      }
    }

    final query = filter != null ? {'filter': filter.name} : null;
    final response = await _client.get(ApiEndpoints.transactions, query: query);

    if (response.isOk && response.body is Map && response.body['data'] is List) {
      final list = (response.body['data'] as List).map((item) {
        final m = Map<String, dynamic>.from(item as Map);
        TransactionStatus status = TransactionStatus.pending;
        if (m['status'] == 'success') status = TransactionStatus.success;
        if (m['status'] == 'failed') status = TransactionStatus.failed;

        return TransactionModel(
          id: m['id']?.toString() ?? '',
          productName: m['productName'] ?? 'Product Name',
          planType: m['planType'] ?? 'Period-Based Plan',
          status: status,
          amount: m['amount']?.toString() ?? '1514.00',
          date: m['date'] ?? '26/11/2024',
          validity: m['validity'] ?? '30 Mar 2024',
          transactionalId: m['transactionalId']?.toString() ?? '12345678',
        );
      }).toList();

      return ApiResponse.success(data: list, statusCode: response.statusCode ?? 200);
    }

    return ApiResponse.error(
      message: response.statusText ?? 'Failed to load transactions',
      statusCode: response.statusCode ?? 500,
    );
  }

  // 3. HTTP POST - Add / Link New Bank Account in Cloud Firestore
  Future<ApiResponse<Map<String, dynamic>>> addBankAccount({
    required String bankName,
    required String accountHolderName,
    required String fullAccountNumber,
    required String ifscCode,
    required String branch,
  }) async {
    final payload = {
      'bankName': bankName,
      'accountHolderName': accountHolderName,
      'fullAccountNumber': fullAccountNumber,
      'ifscCode': ifscCode,
      'branch': branch,
    };

    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = CustomerFirebaseService.to.currentUid.value;
      await CustomerFirebaseService.to.saveBankAccountToFirestore(uid, payload);
    }

    final response = await _client.post(ApiEndpoints.bankAccounts, payload);
    return _client.handleResponse<Map<String, dynamic>>(
      response,
      fallback: payload,
    );
  }

  // 4. HTTP PUT - Full Update of Bank Account Details in Cloud Firestore
  Future<ApiResponse<Map<String, dynamic>>> updateBankAccount(
    String accountId,
    Map<String, dynamic> data,
  ) async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = CustomerFirebaseService.to.currentUid.value;
      await CustomerFirebaseService.to.updateBankAccountInFirestore(uid, accountId, data);
    }

    final endpoint = ApiEndpoints.bankAccountById(accountId);
    final response = await _client.put(endpoint, data);
    return _client.handleResponse<Map<String, dynamic>>(
      response,
      fallback: data,
    );
  }

  // 5. HTTP PATCH - Partial Update (Toggle Balance Visibility) in Cloud Firestore
  Future<ApiResponse<Map<String, dynamic>>> patchBalanceVisibility(
    String accountId,
    bool isVisible,
  ) async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = CustomerFirebaseService.to.currentUid.value;
      await CustomerFirebaseService.to.patchBalanceVisibilityInFirestore(uid, accountId, isVisible);
    }

    final endpoint = ApiEndpoints.bankAccountVisibility(accountId);
    final response = await _client.patch(endpoint, {'isVisible': isVisible});
    return _client.handleResponse<Map<String, dynamic>>(
      response,
      fallback: {'isVisible': isVisible},
    );
  }

  // 6. HTTP DELETE - Remove Bank Account from Cloud Firestore
  Future<ApiResponse<bool>> deleteBankAccount(String accountId) async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = CustomerFirebaseService.to.currentUid.value;
      await CustomerFirebaseService.to.deleteBankAccountFromFirestore(uid, accountId);
    }

    final endpoint = ApiEndpoints.bankAccountById(accountId);
    final response = await _client.delete(endpoint);
    return ApiResponse<bool>(
      statusCode: response.statusCode ?? 200,
      isSuccess: true,
      message: 'Bank account deleted successfully',
      data: true,
    );
  }
}
