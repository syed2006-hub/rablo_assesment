import 'package:get/get.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../api/api_response.dart';
import '../firebase/customer_firebase_service.dart';

/// Backend REST API Service for Trainers Management
class TrainerApiService extends GetxService {
  static TrainerApiService get to => Get.find<TrainerApiService>();

  late final ApiClient _client;

  @override
  void onInit() {
    super.onInit();
    _client = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put(ApiClient());
  }

  // 1. HTTP GET - Retrieve Assigned Trainers from Cloud Firestore
  Future<ApiResponse<List<Map<String, dynamic>>>> getTrainers() async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final list = await CustomerFirebaseService.to.getTrainersFromFirestore();
      if (list.isNotEmpty) {
        return ApiResponse.success(data: list, statusCode: 200);
      }
    }

    final response = await _client.get(ApiEndpoints.trainers);
    if (response.isOk && response.body is Map && response.body['data'] is List) {
      final list = (response.body['data'] as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
      return ApiResponse.success(data: list, statusCode: response.statusCode ?? 200);
    }
    return ApiResponse.error(
      message: response.statusText ?? 'Failed to load trainers',
      statusCode: response.statusCode ?? 500,
    );
  }

  // 2. HTTP POST - Assign New Trainer in Cloud Firestore
  Future<ApiResponse<Map<String, dynamic>>> addTrainer(Map<String, dynamic> trainerData) async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      await CustomerFirebaseService.to.saveTrainerToFirestore(trainerData);
    }

    final response = await _client.post(ApiEndpoints.trainers, trainerData);
    return _client.handleResponse<Map<String, dynamic>>(
      response,
      fallback: trainerData,
    );
  }

  // 3. HTTP PUT - Full Update of Trainer Info in Cloud Firestore
  Future<ApiResponse<Map<String, dynamic>>> updateTrainer(
    String trainerId,
    Map<String, dynamic> data,
  ) async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      await CustomerFirebaseService.to.updateTrainerInFirestore(trainerId, data);
    }

    final endpoint = ApiEndpoints.trainerById(trainerId);
    final response = await _client.put(endpoint, data);
    return _client.handleResponse<Map<String, dynamic>>(
      response,
      fallback: data,
    );
  }

  // 4. HTTP PATCH - Update Trainer Sessions in Cloud Firestore
  Future<ApiResponse<Map<String, dynamic>>> patchTrainerSessions(
    String trainerId,
    int sessions,
  ) async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      await CustomerFirebaseService.to.updateTrainerInFirestore(trainerId, {'sessions': sessions});
    }

    final endpoint = ApiEndpoints.trainerSessions(trainerId);
    final response = await _client.patch(endpoint, {'sessions': sessions});
    return _client.handleResponse<Map<String, dynamic>>(
      response,
      fallback: {'sessions': sessions},
    );
  }

  // 5. HTTP DELETE - Remove / Unassign Trainer from Cloud Firestore
  Future<ApiResponse<bool>> deleteTrainer(String trainerId) async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      await CustomerFirebaseService.to.deleteTrainerFromFirestore(trainerId);
    }

    final endpoint = ApiEndpoints.trainerById(trainerId);
    final response = await _client.delete(endpoint);
    return ApiResponse<bool>(
      statusCode: response.statusCode ?? 200,
      isSuccess: true,
      message: 'Trainer removed successfully',
      data: true,
    );
  }
}
