/// D1MM2 – Account Model for gym member / onboarding account creation.
class AccountModel {
  final String? uid;
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
  final bool isOnboarded;

  // Figma Customer Onboarding Fields
  final String? dateOfBirth;
  final String? profession;
  final List<String>? objectives;
  final String? addressLine1;
  final String? city;
  final String? state;
  final String? country;
  final String? pinCode;
  final String? addressLine2;
  final List<String>? preferredLanguages;
  final bool acceptedTerms;
  final bool promotionalConsent;

  const AccountModel({
    this.uid,
    required this.accountId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.gender,
    this.accountType = 'Individual',
    this.planId = 'PLAN-001',
    this.planName = 'Standard Fitness Plan',
    this.emergencyContact = 'Not Provided',
    this.businessName,
    this.gstNumber,
    this.healthNotes,
    required this.registrationDate,
    this.isOnboarded = true,
    this.dateOfBirth,
    this.profession,
    this.objectives,
    this.addressLine1,
    this.city,
    this.state,
    this.country,
    this.pinCode,
    this.addressLine2,
    this.preferredLanguages,
    this.acceptedTerms = true,
    this.promotionalConsent = false,
  });

  AccountModel copyWith({
    String? uid,
    String? accountId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? gender,
    String? accountType,
    String? planId,
    String? planName,
    String? emergencyContact,
    String? businessName,
    String? gstNumber,
    String? healthNotes,
    DateTime? registrationDate,
    bool? isOnboarded,
    String? dateOfBirth,
    String? profession,
    List<String>? objectives,
    String? addressLine1,
    String? city,
    String? state,
    String? country,
    String? pinCode,
    String? addressLine2,
    List<String>? preferredLanguages,
    bool? acceptedTerms,
    bool? promotionalConsent,
  }) {
    return AccountModel(
      uid: uid ?? this.uid,
      accountId: accountId ?? this.accountId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      accountType: accountType ?? this.accountType,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      businessName: businessName ?? this.businessName,
      gstNumber: gstNumber ?? this.gstNumber,
      healthNotes: healthNotes ?? this.healthNotes,
      registrationDate: registrationDate ?? this.registrationDate,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      profession: profession ?? this.profession,
      objectives: objectives ?? this.objectives,
      addressLine1: addressLine1 ?? this.addressLine1,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      pinCode: pinCode ?? this.pinCode,
      addressLine2: addressLine2 ?? this.addressLine2,
      preferredLanguages: preferredLanguages ?? this.preferredLanguages,
      acceptedTerms: acceptedTerms ?? this.acceptedTerms,
      promotionalConsent: promotionalConsent ?? this.promotionalConsent,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
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
        'isOnboarded': isOnboarded,
        'dateOfBirth': dateOfBirth,
        'profession': profession,
        'objectives': objectives,
        'addressLine1': addressLine1,
        'city': city,
        'state': state,
        'country': country,
        'pinCode': pinCode,
        'addressLine2': addressLine2,
        'preferredLanguages': preferredLanguages,
        'acceptedTerms': acceptedTerms,
        'promotionalConsent': promotionalConsent,
      };

  factory AccountModel.fromJson(Map<String, dynamic> json) => AccountModel(
        uid: json['uid'] as String?,
        accountId: json['accountId'] as String,
        fullName: json['fullName'] as String,
        email: json['email'] as String,
        phoneNumber: json['phoneNumber'] as String,
        gender: json['gender'] as String,
        accountType: json['accountType'] as String? ?? 'Individual',
        planId: json['planId'] as String? ?? 'PLAN-001',
        planName: json['planName'] as String? ?? 'Standard Fitness Plan',
        emergencyContact: json['emergencyContact'] as String? ?? 'N/A',
        businessName: json['businessName'] as String?,
        gstNumber: json['gstNumber'] as String?,
        healthNotes: json['healthNotes'] as String?,
        registrationDate: DateTime.parse(json['registrationDate'] as String),
        isOnboarded: json['isOnboarded'] as bool? ?? true,
        dateOfBirth: json['dateOfBirth'] as String?,
        profession: json['profession'] as String?,
        objectives: (json['objectives'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        addressLine1: json['addressLine1'] as String?,
        city: json['city'] as String?,
        state: json['state'] as String?,
        country: json['country'] as String?,
        pinCode: json['pinCode'] as String?,
        addressLine2: json['addressLine2'] as String?,
        preferredLanguages: (json['preferredLanguages'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList(),
        acceptedTerms: json['acceptedTerms'] as bool? ?? true,
        promotionalConsent: json['promotionalConsent'] as bool? ?? false,
      );
}
