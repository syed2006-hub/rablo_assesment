/// D1MM5 – Model representing a linked Bank Account.
class LinkedBankAccountModel {
  final String bankName;
  final String accountNumberMasked;
  final String status;
  final double balance;
  final int membershipsSold;
  final String iconCode;

  LinkedBankAccountModel({
    required this.bankName,
    required this.accountNumberMasked,
    required this.status,
    required this.balance,
    required this.membershipsSold,
    required this.iconCode,
  });
}
