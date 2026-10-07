/// D1CM6 – Transaction status indicator
enum TransactionStatus { success, failed, pending }

/// Strongly-typed Model representing a Financial Transaction with JSON & Firestore serialization
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

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    TransactionStatus parsedStatus = TransactionStatus.pending;
    final statusStr = json['status']?.toString().toLowerCase();
    if (statusStr == 'success' || statusStr == 'verified pass') {
      parsedStatus = TransactionStatus.success;
    } else if (statusStr == 'failed') {
      parsedStatus = TransactionStatus.failed;
    }

    return TransactionModel(
      id: json['id']?.toString() ?? '',
      productName: json['productName']?.toString() ?? json['planName']?.toString() ?? 'Product Name',
      planType: json['planType']?.toString() ?? 'Period-Based Plan',
      status: parsedStatus,
      amount: json['amount']?.toString() ?? '1514.00',
      date: json['date']?.toString() ?? '26/11/2024',
      validity: json['validity']?.toString() ?? '30 Mar 2024',
      transactionalId: json['transactionalId']?.toString() ?? json['transactionId']?.toString() ?? '12345678',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'productName': productName,
        'planType': planType,
        'status': status.name,
        'amount': amount,
        'date': date,
        'validity': validity,
        'transactionalId': transactionalId,
      };

  factory TransactionModel.fromFirestore(Map<String, dynamic> data) =>
      TransactionModel.fromJson(data);

  Map<String, dynamic> toFirestore() => toJson();
}
