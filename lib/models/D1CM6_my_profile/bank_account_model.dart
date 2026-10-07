/// D1CM6 – Model representing a linked Bank Account with JSON and Firestore serialization.
class LinkedBankAccountModel {
  final String id;
  final String bankName;
  final String accountHolderName;
  final String accountNumberMasked;
  final String fullAccountNumber;
  final String ifscCode;
  final String branch;
  final String status;
  final double balance;
  final int membershipsSold;
  final String iconCode;
  final bool isPrimary;
  final bool isVerified;
  final bool isBalanceVisible;

  LinkedBankAccountModel({
    required this.id,
    required this.bankName,
    required this.accountHolderName,
    required this.accountNumberMasked,
    this.fullAccountNumber = '',
    this.ifscCode = '',
    this.branch = '',
    this.status = 'Active',
    required this.balance,
    this.membershipsSold = 0,
    this.iconCode = 'account_balance',
    this.isPrimary = false,
    this.isVerified = true,
    this.isBalanceVisible = false,
  });

  factory LinkedBankAccountModel.fromJson(Map<String, dynamic> json) {
    double parsedBalance = 0.0;
    if (json['balance'] is num) {
      parsedBalance = (json['balance'] as num).toDouble();
    } else if (json['balance'] is String) {
      parsedBalance = double.tryParse((json['balance'] as String).replaceAll(',', '')) ?? 0.0;
    }

    return LinkedBankAccountModel(
      id: json['id']?.toString() ?? '',
      bankName: json['bankName']?.toString() ?? 'Bank Name',
      accountHolderName: json['accountHolderName']?.toString() ?? 'Account Holder',
      accountNumberMasked: json['accountNumber']?.toString() ??
          json['accountNumberMasked']?.toString() ??
          '**** **** 0000',
      fullAccountNumber: json['fullAccountNumber']?.toString() ?? '',
      ifscCode: json['ifscCode']?.toString() ?? '',
      branch: json['branch']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      balance: parsedBalance,
      membershipsSold: (json['membershipsSold'] as num?)?.toInt() ?? 0,
      iconCode: json['iconCode']?.toString() ?? 'account_balance',
      isPrimary: json['isPrimary'] == true,
      isVerified: json['isVerified'] ?? true,
      isBalanceVisible: json['isBalanceVisible'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bankName': bankName,
        'accountHolderName': accountHolderName,
        'accountNumber': accountNumberMasked,
        'accountNumberMasked': accountNumberMasked,
        'fullAccountNumber': fullAccountNumber,
        'ifscCode': ifscCode,
        'branch': branch,
        'status': status,
        'balance': balance.toStringAsFixed(2),
        'membershipsSold': membershipsSold,
        'iconCode': iconCode,
        'isPrimary': isPrimary,
        'isVerified': isVerified,
        'isBalanceVisible': isBalanceVisible,
      };

  factory LinkedBankAccountModel.fromFirestore(Map<String, dynamic> data) =>
      LinkedBankAccountModel.fromJson(data);

  Map<String, dynamic> toFirestore() => toJson();
}
