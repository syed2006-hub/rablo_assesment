/// D1MM5 – Profile Model for user / admin profile information.
class ProfileModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;
  final String gymBranch;
  final String bio;
  final DateTime memberSince;
  final int totalWorkoutsSupervised;
  final double rating;

  const ProfileModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.gymBranch,
    required this.bio,
    required this.memberSince,
    required this.totalWorkoutsSupervised,
    required this.rating,
  });

  ProfileModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? role,
    String? gymBranch,
    String? bio,
    DateTime? memberSince,
    int? totalWorkoutsSupervised,
    double? rating,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      gymBranch: gymBranch ?? this.gymBranch,
      bio: bio ?? this.bio,
      memberSince: memberSince ?? this.memberSince,
      totalWorkoutsSupervised:
          totalWorkoutsSupervised ?? this.totalWorkoutsSupervised,
      rating: rating ?? this.rating,
    );
  }
}
