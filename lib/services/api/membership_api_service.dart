import 'package:get/get.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../api/api_response.dart';

/// Backend REST API Service for Membership Plans
class MembershipApiService extends GetxService {
  static MembershipApiService get to => Get.find<MembershipApiService>();

  late final ApiClient _client;

  @override
  void onInit() {
    super.onInit();
    _client = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put(ApiClient());
  }

  // 1. HTTP GET - Retrieve Available Membership Plans
  Future<ApiResponse<List<Map<String, dynamic>>>> getMembershipPlans() async {
    final response = await _client.get(ApiEndpoints.membershipPlans);
    if (response.isOk && response.body is Map && response.body['data'] is List) {
      final list = (response.body['data'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return ApiResponse.success(data: list, statusCode: response.statusCode ?? 200);
    }
    return ApiResponse.error(
      message: response.statusText ?? 'Failed to load plans',
      statusCode: response.statusCode ?? 500,
    );
  }

  // 2. HTTP POST - Subscribe to a Plan
  Future<ApiResponse<Map<String, dynamic>>> subscribePlan(String planId) async {
    final response = await _client.post(ApiEndpoints.subscribePlan, {'planId': planId});
    return _client.handleResponse<Map<String, dynamic>>(
      response,
      fallback: <String, dynamic>{},
    );
  }

  // 3. HTTP PUT - Update Active Subscription
  Future<ApiResponse<Map<String, dynamic>>> updateSubscription(
    String planId,
    Map<String, dynamic> data,
  ) async {
    final endpoint = ApiEndpoints.membershipPlanById(planId);
    final response = await _client.put(endpoint, data);
    return _client.handleResponse<Map<String, dynamic>>(
      response,
      fallback: <String, dynamic>{},
    );
  }

  // 4. HTTP DELETE - Cancel Membership Subscription
  Future<ApiResponse<bool>> cancelSubscription(String planId) async {
    final endpoint = ApiEndpoints.membershipPlanById(planId);
    final response = await _client.delete(endpoint);
    return ApiResponse<bool>(
      statusCode: response.statusCode ?? 200,
      isSuccess: response.isOk,
      message: response.isOk ? 'Subscription cancelled' : 'Cancel failed',
      data: response.isOk,
    );
  }
}
