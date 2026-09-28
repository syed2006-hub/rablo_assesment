/// D1CM1 – User Model for authenticated user session.
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role; // 'Admin', 'Trainer', 'Member'
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.role = 'Admin',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'role': role,
        'createdAt': createdAt.toIso8601String(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String? ?? 'User',
        photoUrl: json['photoUrl'] as String?,
        role: json['role'] as String? ?? 'Member',
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
