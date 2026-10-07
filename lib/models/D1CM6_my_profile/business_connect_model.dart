/// D1CM6 – Model representing a connected gym affiliate business partner
class BusinessConnectModel {
  final String id;
  final String name;
  final String category;
  final String location;
  final String rating;
  final String status;
  final String connectionDate;
  final String revenueGenerated;
  final String image;

  BusinessConnectModel({
    required this.id,
    required this.name,
    required this.category,
    required this.location,
    required this.rating,
    required this.status,
    required this.connectionDate,
    required this.revenueGenerated,
    required this.image,
  });

  factory BusinessConnectModel.fromJson(Map<String, dynamic> json) {
    return BusinessConnectModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Gym Partner',
      category: json['category']?.toString() ?? 'Gym & Fitness',
      location: json['location']?.toString() ?? 'Bengaluru',
      rating: json['rating']?.toString() ?? '4.8',
      status: json['status']?.toString() ?? 'Active',
      connectionDate: json['connectionDate']?.toString() ?? '01/01/2024',
      revenueGenerated: json['revenueGenerated']?.toString() ?? '0.00',
      image: json['image']?.toString() ?? 'assets/images/welcome_bg.png',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'location': location,
        'rating': rating,
        'status': status,
        'connectionDate': connectionDate,
        'revenueGenerated': revenueGenerated,
        'image': image,
      };

  factory BusinessConnectModel.fromFirestore(Map<String, dynamic> data) =>
      BusinessConnectModel.fromJson(data);

  Map<String, dynamic> toFirestore() => toJson();
}
