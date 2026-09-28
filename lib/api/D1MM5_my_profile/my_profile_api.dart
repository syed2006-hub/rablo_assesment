import '../../constants/app_constants.dart';

/// D1MM5 – My Profile API module.
/// Establishes the structure for profile management and user details.
class MyProfileApi {
  final String baseUrl;

  MyProfileApi({this.baseUrl = AppConstants.apiBaseUrl});

  /// Fetch user profile details
  Future<void> getUserProfile() async {
    throw UnimplementedError('getUserProfile is not yet implemented');
  }

  /// Update user profile details
  Future<void> updateUserProfile() async {
    throw UnimplementedError('updateUserProfile is not yet implemented');
  }
}
