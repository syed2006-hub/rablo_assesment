import 'package:get/get.dart';

enum TimeFilter { today, thisWeek, thisMonth }

enum AccountViewTab { transactions, bankAccount }

enum TransactionStatus { success, failed, pending }

class TransactionModel {
  final String id;
  final String productName;
  final String planType;
  final TransactionStatus status;
  final String amount;
  final String date;
  final String validity;
  final String transactionalId;

  TransactionModel({
    required this.id,
    required this.productName,
    required this.planType,
    required this.status,
    required this.amount,
    required this.date,
    required this.validity,
    required this.transactionalId,
  });
}

class BankAccountController extends GetxController {
  final isBalanceVisible = false.obs;
  final selectedFilter = TimeFilter.today.obs;
  final activeTab = AccountViewTab.bankAccount.obs;

  final totalAmount = '20,014.00';
  final transactionCount = 3.obs;

  // Mock list of transactions for demonstration
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
    TransactionModel(
      id: '122359',
      productName: 'Product Name',
      planType: 'Session-Based Plan',
      status: TransactionStatus.failed,
      amount: '1514.00',
      date: '21/11/2024',
      validity: '30 Mar 2024',
      transactionalId: '123454883',
    ),
  ].obs;

  void toggleBalanceVisibility() {
    isBalanceVisible.value = !isBalanceVisible.value;
  }

  void setFilter(TimeFilter filter) {
    selectedFilter.value = filter;
  }

  void setActiveTab(AccountViewTab tab) {
    activeTab.value = tab;
  }
}