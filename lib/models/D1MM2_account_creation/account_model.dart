/// D1MM2 – Account Model for gym member / business account creation.
class AccountModel {
  final String accountId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String gender;
  final String accountType; // 'Individual', 'Business'
  final String planId;
  final String planName;
  final String emergencyContact;
  final String? businessName;
  final String? gstNumber;
  final String? healthNotes;
  final DateTime registrationDate;

  const AccountModel({
    required this.accountId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    this.accountType = 'Individual',
    required this.planId,
    required this.planName,
    required this.emergencyContact,
    this.businessName,
    this.gstNumber,
    this.healthNotes,
    required this.registrationDate,
  });

  Map<String, dynamic> toJson() => {
        'accountId': accountId,
        'fullName': fullName,
        'email': email,
        'phoneNumber': phoneNumber,
        'gender': gender,
        'accountType': accountType,
        'planId': planId,
        'planName': planName,
        'emergencyContact': emergencyContact,
        'businessName': businessName,
        'gstNumber': gstNumber,
        'healthNotes': healthNotes,
        'registrationDate': registrationDate.toIso8601String(),
      };

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
        accountId: json['accountId'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        phoneNumber: json['phoneNumber'] as String,
        gender: json['gender'] as String,
        accountType: json['accountType'] as String? ?? 'Individual',
        planId: json['planId'] as String,
        planName: json['planName'] as String,
        emergencyContact: json['emergencyContact'] as String? ?? 'N/A',
        businessName: json['businessName'] as String?,
        gstNumber: json['gstNumber'] as String?,
        healthNotes: json['healthNotes'] as String?,
        registrationDate: DateTime.parse(json['registrationDate'] as String),
      );
}
