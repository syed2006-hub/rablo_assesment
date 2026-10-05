import 'package:get/get.dart';
import '../../api/api_client.dart';
import '../../api/api_endpoints.dart';
import '../../api/api_response.dart';
import '../../models/D1MM5_my_profile/profile_model.dart';
import '../D1CM1_login/firebase_auth_service.dart';
import '../firebase/customer_firebase_service.dart';

/// Backend REST API Service for User Profile Management
class ProfileApiService extends GetxService {
  static ProfileApiService get to => Get.find<ProfileApiService>();

  late final ApiClient _client;

  @override
  void onInit() {
    super.onInit();
    _client = Get.isRegistered<ApiClient>() ? Get.find<ApiClient>() : Get.put(ApiClient());
  }

  // 1. HTTP GET - Retrieve Current Profile directly from Cloud Firestore
  Future<ApiResponse<ProfileModel?>> getProfile() async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = CustomerFirebaseService.to.currentUid.value.isNotEmpty
          ? CustomerFirebaseService.to.currentUid.value
          : (FirebaseAuthService.instance.currentFirebaseUser?.uid ?? '');
      if (uid.isNotEmpty) {
        final map = await CustomerFirebaseService.to.fetchUserProfile(uid);
        if (map != null && map.isNotEmpty) {
          final profile = ProfileModel(
            id: map['uid'] ?? map['id'] ?? uid,
            fullName: map['fullName'] ?? 'Manager Name',
            email: map['email'] ?? 'member@fitness.com',
            phoneNumber: map['contactNumber'] ?? map['phoneNumber'] ?? '+91 98765 - 43210',
            gender: map['gender'] ?? 'Male',
            role: map['role'] ?? 'Manager/Owner',
            dob: map['dateOfBirth'] ?? map['dob'] ?? '09 - 11 - 2024',
            addressLine1: map['personalAddress'] ?? map['addressLine1'] ?? 'User input, Sample text',
            addressLine2: map['addressLine2'] ?? 'Enter your colony or locality',
            country: map['country'] ?? 'India',
            state: map['state'] ?? 'Karnataka',
            city: map['city'] ?? 'Bengaluru',
            pincode: map['pinCode'] ?? map['pincode'] ?? '560038',
            preferredLanguages: (map['preferredLanguages'] as List?)
                    ?.map((e) => e.toString())
                    .toList() ??
                const ['English', 'Hindi', 'Kannada'],
            isVerified: map['isVerified'] == true,
            photoUrl: map['photoUrl'] ?? 'assets/images/profile_avatar.png',
            gymBranch: map['gymBranch'] ?? 'Koramangala Prime Club, Bengaluru',
            bio: map['bio'] ?? 'Fitness and gym management profile.',
            memberSince: DateTime(2024, 1, 1),
            totalWorkoutsSupervised: map['totalWorkoutsSupervised'] ?? 1420,
            rating: (map['rating'] as num?)?.toDouble() ?? 4.9,
          );
          return ApiResponse.success(data: profile, statusCode: 200);
        }
      }
    }

    final response = await _client.get(ApiEndpoints.profile);

    if (response.isOk && response.body is Map && response.body['data'] is Map) {
      final map = Map<String, dynamic>.from(response.body['data'] as Map);
      final profile = ProfileModel(
        id: map['id'] ?? 'MEM-001',
        fullName: map['fullName'] ?? 'Manager Name',
        email: map['email'] ?? 'member@fitness.com',
        phoneNumber: map['phoneNumber'] ?? '+91 98765 - 43210',
        gender: map['gender'] ?? 'Male',
        role: map['role'] ?? 'Manager/Owner',
        dob: map['dob'] ?? '09 - 11 - 2024',
        addressLine1: map['addressLine1'] ?? 'User input, Sample text',
        addressLine2: map['addressLine2'] ?? 'Enter your colony or locality',
        country: map['country'] ?? 'India',
        state: map['state'] ?? 'Karnataka',
        city: map['city'] ?? 'Bengaluru',
        pincode: map['pincode'] ?? '560038',
        preferredLanguages: (map['preferredLanguages'] as List?)
                ?.map((e) => e.toString())
                .toList() ??
            const ['English', 'Hindi', 'Kannada'],
        isVerified: map['isVerified'] ?? false,
        photoUrl: map['photoUrl'] ?? 'assets/images/profile_avatar.png',
        gymBranch: map['gymBranch'] ?? 'Koramangala Prime Club, Bengaluru',
        bio: map['bio'] ?? 'Fitness and gym management profile.',
        memberSince: DateTime(2024, 1, 1),
        totalWorkoutsSupervised: map['totalWorkoutsSupervised'] ?? 1420,
        rating: (map['rating'] as num?)?.toDouble() ?? 4.9,
      );

      return ApiResponse.success(data: profile, statusCode: response.statusCode ?? 200);
    }

    return ApiResponse.error(
      message: response.statusText ?? 'Failed to retrieve profile',
      statusCode: response.statusCode ?? 500,
    );
  }

  // 2. HTTP PUT - Full Update of Profile in Cloud Firestore
  Future<ApiResponse<ProfileModel?>> updateProfile(ProfileModel updated) async {
    final payload = {
      'id': updated.id,
      'fullName': updated.fullName,
      'email': updated.email,
      'phoneNumber': updated.phoneNumber,
      'gender': updated.gender,
      'role': updated.role,
      'dob': updated.dob,
      'addressLine1': updated.addressLine1,
      'addressLine2': updated.addressLine2,
      'country': updated.country,
      'state': updated.state,
      'city': updated.city,
      'pincode': updated.pincode,
      'preferredLanguages': updated.preferredLanguages,
      'isVerified': updated.isVerified,
      'photoUrl': updated.photoUrl,
    };

    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = updated.id.isNotEmpty
          ? updated.id
          : (CustomerFirebaseService.to.currentUid.value.isNotEmpty
              ? CustomerFirebaseService.to.currentUid.value
              : 'USER-CURRENT');
      await CustomerFirebaseService.to.saveUserProfile(uid, payload);
    }

    final response = await _client.put(ApiEndpoints.profile, payload);
    if (response.isOk) {
      return ApiResponse.success(data: updated, statusCode: response.statusCode ?? 200);
    }
    return ApiResponse.success(data: updated, statusCode: 200);
  }

  // 3. HTTP PATCH - Toggle Verification Status in Cloud Firestore
  Future<ApiResponse<bool>> patchVerification() async {
    bool currentVerified = false;
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = CustomerFirebaseService.to.currentUid.value;
      if (uid.isNotEmpty) {
        currentVerified = !(CustomerFirebaseService.to.currentUserProfile.value?['isVerified'] == true);
        await CustomerFirebaseService.to.updateUserFields(uid, {'isVerified': currentVerified});
      }
    }

    final response = await _client.patch(ApiEndpoints.profileVerification, {});
    if (response.isOk && response.body is Map && response.body['data'] is Map) {
      final isVerified = response.body['data']['isVerified'] as bool? ?? false;
      return ApiResponse.success(data: isVerified, statusCode: response.statusCode ?? 200);
    }
    return ApiResponse.success(data: currentVerified, statusCode: 200);
  }

  // 4. HTTP PATCH - Update Photo URL in Cloud Firestore
  Future<ApiResponse<String>> patchPhotoUrl(String photoUrl) async {
    if (Get.isRegistered<CustomerFirebaseService>()) {
      final uid = CustomerFirebaseService.to.currentUid.value;
      if (uid.isNotEmpty) {
        await CustomerFirebaseService.to.updateUserFields(uid, {'photoUrl': photoUrl});
      }
    }

    final response = await _client.patch(ApiEndpoints.profilePhoto, {'photoUrl': photoUrl});
    if (response.isOk) {
      return ApiResponse.success(data: photoUrl, statusCode: response.statusCode ?? 200);
    }
    return ApiResponse.success(data: photoUrl, statusCode: 200);
  }

  // 5. HTTP DELETE - Deactivate User Profile
  Future<ApiResponse<bool>> deleteProfile(String userId) async {
    final endpoint = '${ApiEndpoints.profile}/$userId';
    final response = await _client.delete(endpoint);
    return ApiResponse<bool>(
      statusCode: response.statusCode ?? 200,
      isSuccess: response.isOk,
      message: response.isOk ? 'Profile deactivated' : 'Delete failed',
      data: response.isOk,
    );
  }
}
