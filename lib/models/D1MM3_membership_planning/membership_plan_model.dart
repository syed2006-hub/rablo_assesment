/// D1MM3 – Membership Plan Model.
class MembershipPlanModel {
  final String id;
  final String name;
  final double price;
  final int durationMonths;
  final List<String> features;
  final bool isPopular;
  final String category; // 'General', 'VIP', 'Special'

  const MembershipPlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMonths,
    required this.features,
    this.isPopular = false,
    this.category = 'General',
  });

  String get formattedPrice => '₹${price.toStringAsFixed(0)}';
  String get billingDuration => durationMonths == 1 ? '1 month' : '$durationMonths months';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'price': price,
        'durationMonths': durationMonths,
        'features': features,
        'isPopular': isPopular,
        'category': category,
      };

  factory MembershipPlanModel.fromJson(Map<String, dynamic> json) =>
      MembershipPlanModel(
        id: json['id'] as String,
        name: json['name'] as String,
        price: (json['price'] as num).toDouble(),
        durationMonths: json['durationMonths'] as int,
        features: List<String>.from(json['features'] as List),
        isPopular: json['isPopular'] as bool? ?? false,
        category: json['category'] as String? ?? 'General',
      );
}
