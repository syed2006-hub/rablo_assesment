/// D1MM3 – Member Model for member directories and details.
class MemberModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String planName;
  final String status; // 'Active', 'Expiring', 'Inactive'
  final DateTime joinDate;
  final DateTime expiryDate;
  final int attendanceCount;
  final String emergencyContact;
  final String? notes;

  const MemberModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.planName,
    required this.status,
    required this.joinDate,
    required this.expiryDate,
    required this.attendanceCount,
    required this.emergencyContact,
    this.notes,
  });

  bool get isActive => status == 'Active';
  bool get isExpiring => status == 'Expiring';
  bool get isInactive => status == 'Inactive';

  MemberModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? gender,
    String? planName,
    String? status,
    DateTime? joinDate,
    DateTime? expiryDate,
    int? attendanceCount,
    String? emergencyContact,
    String? notes,
  }) {
    return MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      planName: planName ?? this.planName,
      status: status ?? this.status,
      joinDate: joinDate ?? this.joinDate,
      expiryDate: expiryDate ?? this.expiryDate,
      attendanceCount: attendanceCount ?? this.attendanceCount,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'gender': gender,
        'planName': planName,
        'status': status,
        'joinDate': joinDate.toIso8601String(),
        'expiryDate': expiryDate.toIso8601String(),
        'attendanceCount': attendanceCount,
        'emergencyContact': emergencyContact,
        'notes': notes,
      };

  factory MemberModel.fromJson(Map<String, dynamic> json) => MemberModel(
        id: json['id'] as String,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String,
        gender: json['gender'] as String,
        planName: json['planName'] as String,
        status: json['status'] as String,
        joinDate: DateTime.parse(json['joinDate'] as String),
        expiryDate: DateTime.parse(json['expiryDate'] as String),
        attendanceCount: json['attendanceCount'] as int? ?? 0,
        emergencyContact: json['emergencyContact'] as String? ?? 'N/A',
        notes: json['notes'] as String?,
      );
}
