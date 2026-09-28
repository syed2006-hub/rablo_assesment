/// Represents a gym membership tier / package.
class MembershipPlanModel {
  final String id;
  final String name;
  final double price;
  final int durationMonths;
  final List<String> features;
  final bool isPopular;

  const MembershipPlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMonths,
    required this.features,
    this.isPopular = false,
  });

  String get formattedPrice => '₹${price.toStringAsFixed(0)}';
  String get billingDuration => durationMonths == 1 ? 'month' : '$durationMonths months';
}
