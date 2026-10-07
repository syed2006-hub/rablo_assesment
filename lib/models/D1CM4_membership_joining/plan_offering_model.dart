/// D1CM4 – Subscription Plan Offering model for plan cards.
class CustomerPlanModel {
  final String id;
  final String name;
  final int monthlyPrice;
  final int quarterlyPrice;
  final String userLimitDescription;
  final bool isSelected;
  final bool isPopular;
  final String iconType;

  CustomerPlanModel({
    required this.id,
    required this.name,
    required this.monthlyPrice,
    required this.quarterlyPrice,
    required this.userLimitDescription,
    this.isSelected = false,
    this.isPopular = false,
    required this.iconType,
  });
}

/// D1CM4 – Model representing a row in the Offerings Comparison Table.
class PlanComparisonRow {
  final String featureName;
  final String trialValue;
  final String businessValue;
  final String starterValue;
  final bool isStarterActive;

  PlanComparisonRow({
    required this.featureName,
    required this.trialValue,
    required this.businessValue,
    required this.starterValue,
    this.isStarterActive = true,
  });

  /// Default rows matching Figma comparison matrix:
  /// Offerings | Trial | Business | Starter
  static List<PlanComparisonRow> getFigmaComparisonRows() {
    return [
      PlanComparisonRow(
        featureName: 'Plan Payment',
        trialValue: 'Post-Paid',
        businessValue: 'Pre-Paid',
        starterValue: 'Pre-Paid',
      ),
      PlanComparisonRow(
        featureName: 'Validity',
        trialValue: '30 Days',
        businessValue: '30 Days',
        starterValue: '30 Days',
      ),
      PlanComparisonRow(
        featureName: 'Max User Limit',
        trialValue: '1 user',
        businessValue: 'Up to 500',
        starterValue: 'Up to 100',
      ),
      PlanComparisonRow(
        featureName: 'Custom Membership Slots',
        trialValue: 'Up to 1',
        businessValue: 'Up to 6',
        starterValue: 'Up to 3',
      ),
      PlanComparisonRow(
        featureName: 'Additional Slot (Charges)',
        trialValue: 'INR 100',
        businessValue: 'INR 50',
        starterValue: 'INR 80',
      ),
      PlanComparisonRow(
        featureName: 'Live Webpage (addon)',
        trialValue: '-',
        businessValue: '✔',
        starterValue: '-',
      ),
      PlanComparisonRow(
        featureName: "Trainer's Profile Creation",
        trialValue: 'Up to 1',
        businessValue: 'Up to 6',
        starterValue: 'Up to 3',
      ),
    ];
  }
}
