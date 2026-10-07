/// D1CM6 – Profile Model matching Figma profile specifications.
class ProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String gender;
  final String role;
  final String dob;
  final String addressLine1;
  final String addressLine2;
  final String country;
  final String state;
  final String city;
  final String pincode;
  final List<String> preferredLanguages;
  final bool isVerified;
  final String? photoUrl;
  final String gymBranch;
  final String bio;
  final DateTime memberSince;
  final int totalWorkoutsSupervised;
  final double rating;
  final bool isOnboarded;

  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.gender = 'Male',
    required this.role,
    this.dob = '09 - 11 - 2024',
    this.addressLine1 = 'MG Road, 4th Cross, Indiranagar',
    this.addressLine2 = 'Near Fitness Arena',
    this.country = 'India',
    this.state = 'Karnataka',
    this.city = 'Bengaluru',
    this.pincode = '560038',
    this.preferredLanguages = const ['English', 'Hindi', 'Kannada'],
    this.isVerified = false,
    this.photoUrl,
    required this.gymBranch,
    required this.bio,
    required this.memberSince,
    required this.totalWorkoutsSupervised,
    required this.rating,
    this.isOnboarded = true,
  });

  ProfileModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? gender,
    String? role,
    String? dob,
    String? addressLine1,
    String? addressLine2,
    String? country,
    String? state,
    String? city,
    String? pincode,
    List<String>? preferredLanguages,
    bool? isVerified,
    String? photoUrl,
    String? gymBranch,
    String? bio,
    DateTime? memberSince,
    int? totalWorkoutsSupervised,
    double? rating,
    bool? isOnboarded,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      role: role ?? this.role,
      dob: dob ?? this.dob,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
      pincode: pincode ?? this.pincode,
      preferredLanguages: preferredLanguages ?? this.preferredLanguages,
      isVerified: isVerified ?? this.isVerified,
      photoUrl: photoUrl ?? this.photoUrl,
      gymBranch: gymBranch ?? this.gymBranch,
      bio: bio ?? this.bio,
      memberSince: memberSince ?? this.memberSince,
      totalWorkoutsSupervised:
          totalWorkoutsSupervised ?? this.totalWorkoutsSupervised,
      rating: rating ?? this.rating,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }
}
