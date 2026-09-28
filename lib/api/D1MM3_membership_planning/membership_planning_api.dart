import '../../constants/app_constants.dart';

/// D1MM3 – Membership Planning API module.
/// Establishes the structure for gym and fitness membership planning operations.
class MembershipPlanningApi {
  final String baseUrl;

  MembershipPlanningApi({this.baseUrl = AppConstants.apiBaseUrl});

  /// Fetch membership plans
  Future<void> getMembershipPlans() async {
    throw UnimplementedError('getMembershipPlans is not yet implemented');
  }

  /// Create or configure a membership plan
  Future<void> createMembershipPlan() async {
    throw UnimplementedError('createMembershipPlan is not yet implemented');
  }
}
