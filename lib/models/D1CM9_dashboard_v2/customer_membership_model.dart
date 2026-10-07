/// D1CM9 – Customer Membership model for Dashboard V2.
class CustomerMembershipModel {
  final String memberName;
  final String membershipPlan;
  final double rating;
  final int validityDays;
  final int sessionsLeft;
  final String validTillDate;
  final int redemptionsLeft;
  final String renewalTime;
  final bool isActive;
  final bool isVerified;
  final String memberId;
  final String businessName;
  final String contactPhone;

  CustomerMembershipModel({
    required this.memberName,
    required this.membershipPlan,
    required this.rating,
    required this.validityDays,
    required this.sessionsLeft,
    required this.validTillDate,
    required this.redemptionsLeft,
    required this.renewalTime,
    this.isActive = true,
    this.isVerified = true,
    this.memberId = 'ID: 123456',
    this.businessName = 'Fitness Centre Rablo',
    this.contactPhone = '+91 98765 43210',
  });

  CustomerMembershipModel copyWith({
    String? memberName,
    String? membershipPlan,
    double? rating,
    int? validityDays,
    int? sessionsLeft,
    String? validTillDate,
    int? redemptionsLeft,
    String? renewalTime,
    bool? isActive,
    bool? isVerified,
    String? memberId,
    String? businessName,
    String? contactPhone,
  }) {
    return CustomerMembershipModel(
      memberName: memberName ?? this.memberName,
      membershipPlan: membershipPlan ?? this.membershipPlan,
      rating: rating ?? this.rating,
      validityDays: validityDays ?? this.validityDays,
      sessionsLeft: sessionsLeft ?? this.sessionsLeft,
      validTillDate: validTillDate ?? this.validTillDate,
      redemptionsLeft: redemptionsLeft ?? this.redemptionsLeft,
      renewalTime: renewalTime ?? this.renewalTime,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      memberId: memberId ?? this.memberId,
      businessName: businessName ?? this.businessName,
      contactPhone: contactPhone ?? this.contactPhone,
    );
  }
}
