/// D1CM1 – User Model for authenticated user session.
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String role; // 'Admin', 'Trainer', 'Member', 'Customer'
  final DateTime createdAt;
  final bool isOnboarded;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.role = 'Customer',
    required this.createdAt,
    this.isOnboarded = false,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    String? role,
    DateTime? createdAt,
    bool? isOnboarded,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isOnboarded: isOnboarded ?? this.isOnboarded,
    );
  }

  Map<String, dynamic> toJson() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'role': role,
        'createdAt': createdAt.toIso8601String(),
        'isOnboarded': isOnboarded,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        uid: json['uid'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String? ?? 'User',
        photoUrl: json['photoUrl'] as String?,
        role: json['role'] as String? ?? 'Customer',
        createdAt: DateTime.parse(json['createdAt'] as String),
        isOnboarded: json['isOnboarded'] as bool? ?? false,
      );
}
