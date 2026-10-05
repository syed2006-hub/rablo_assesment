/// Model representing a gym trainer with JSON & Firestore serialization
class TrainerModel {
  final String id;
  final String name;
  final String role;
  final String specialty;
  final String rating;
  final String reviewsCount;
  final int sessionsCompleted;
  final String timing;
  final String avatarChar;
  final String status;

  TrainerModel({
    required this.id,
    required this.name,
    required this.role,
    required this.specialty,
    required this.rating,
    required this.reviewsCount,
    required this.sessionsCompleted,
    required this.timing,
    required this.avatarChar,
    required this.status,
  });

  factory TrainerModel.fromJson(Map<String, dynamic> json) {
    return TrainerModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Trainer Name',
      role: json['role']?.toString() ?? 'Fitness Coach',
      specialty: json['specialty']?.toString() ?? 'Functional Training',
      rating: json['rating']?.toString() ?? '4.8',
      reviewsCount: json['reviewsCount']?.toString() ?? '50',
      sessionsCompleted: (json['sessionsCompleted'] as num?)?.toInt() ?? 0,
      timing: json['timing']?.toString() ?? 'Mon - Fri',
      avatarChar: json['avatarChar']?.toString() ??
          (json['name'] != null && json['name'].toString().isNotEmpty
              ? json['name'].toString()[0].toUpperCase()
              : 'T'),
      status: json['status']?.toString() ?? 'Assigned',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'role': role,
        'specialty': specialty,
        'rating': rating,
        'reviewsCount': reviewsCount,
        'sessionsCompleted': sessionsCompleted,
        'timing': timing,
        'avatarChar': avatarChar,
        'status': status,
      };

  factory TrainerModel.fromFirestore(Map<String, dynamic> data) =>
      TrainerModel.fromJson(data);

  Map<String, dynamic> toFirestore() => toJson();
}
