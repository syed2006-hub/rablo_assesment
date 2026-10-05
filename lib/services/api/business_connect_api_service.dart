import 'package:get/get.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../api/api_response.dart';
import '../firebase/customer_firebase_service.dart';

/// Backend REST API Service for Gym Business Affiliations
class BusinessConnectApiService extends GetxService {
  static BusinessConnectApiService get to => Get.find<BusinessConnectApiService>();

  late final ApiClient _client;

  final RxList<Map<String, dynamic>> connectedBusinesses = <Map<String, dynamic>>[].obs;

  List<Map<String, dynamic>> get businessConnects => connectedBusinesses;

  Future<ApiResponse<Map<String, dynamic>>> connectBusiness(Map<String, dynamic> businessData) async {
    connectedBusinesses.add(businessData);
    return addBusinessConnect(businessData);
  }

  @override
  void onInit() {
    super.onInit();
    _client = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put(ApiClient());
  }

  // 1. HTTP GET - Retrieve Connected Businesses from Cloud Firestore
  Future<ApiResponse<List<Map<String, dynamic>>>> getBusinessConnects() async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = CustomerFirebaseService.to.currentUid.value;
      final list = await CustomerFirebaseService.to.getBusinessConnectsFromFirestore(uid);
      if (list.isNotEmpty) {
        connectedBusinesses.assignAll(list);
        return ApiResponse.success(data: list, statusCode: 200);
      }
    }

    final response = await _client.get(ApiEndpoints.businessConnects);
    if (response.isOk && response.body is Map && response.body['data'] is List) {
      final list = (response.body['data'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      connectedBusinesses.assignAll(list);
      return ApiResponse.success(data: list, statusCode: response.statusCode ?? 200);
    }
    return ApiResponse.error(
      message: response.statusText ?? 'Failed to load business connects',
      statusCode: response.statusCode ?? 500,
    );
  }

  // 2. HTTP POST - Connect with New Gym in Cloud Firestore
  Future<ApiResponse<Map<String, dynamic>>> addBusinessConnect(
    Map<String, dynamic> businessData,
  ) async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = CustomerFirebaseService.to.currentUid.value;
      await CustomerFirebaseService.to.saveBusinessConnectToFirestore(uid, businessData);
    }

    final response = await _client.post(ApiEndpoints.businessConnects, businessData);
    return _client.handleResponse<Map<String, dynamic>>(
      response,
      fallback: businessData,
    );
  }

  // 3. HTTP PUT - Full Update of Gym Affiliation Details in Cloud Firestore
  Future<ApiResponse<Map<String, dynamic>>> updateBusinessConnect(
    String id,
    Map<String, dynamic> data,
  ) async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = CustomerFirebaseService.to.currentUid.value;
      await CustomerFirebaseService.to.saveBusinessConnectToFirestore(uid, {'id': id, ...data});
    }

    final endpoint = ApiEndpoints.businessConnectById(id);
    final response = await _client.put(endpoint, data);
    return _client.handleResponse<Map<String, dynamic>>(
      response,
      fallback: data,
    );
  }

  // 4. HTTP PATCH - Update Affiliation Status (Active, Expired, Switch Active)
  Future<ApiResponse<Map<String, dynamic>>> patchBusinessStatus(
    String id,
    String status,
  ) async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = CustomerFirebaseService.to.currentUid.value;
      await CustomerFirebaseService.to.saveBusinessConnectToFirestore(uid, {'id': id, 'status': status});
    }

    final endpoint = ApiEndpoints.businessConnectStatus(id);
    final response = await _client.patch(endpoint, {'status': status});
    return _client.handleResponse<Map<String, dynamic>>(
      response,
      fallback: {'status': status},
    );
  }

  // 5. HTTP DELETE - Disconnect / Cancel Affiliation Request from Cloud Firestore
  Future<ApiResponse<bool>> deleteBusinessConnect(String id) async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = CustomerFirebaseService.to.currentUid.value;
      await CustomerFirebaseService.to.deleteBusinessConnectFromFirestore(uid, id);
    }

    connectedBusinesses.removeWhere((b) => b['id'] == id);
    final endpoint = ApiEndpoints.businessConnectById(id);
    final response = await _client.delete(endpoint);
    return ApiResponse<bool>(
      statusCode: response.statusCode ?? 200,
      isSuccess: true,
      message: 'Affiliation removed',
      data: true,
    );
  }
}
