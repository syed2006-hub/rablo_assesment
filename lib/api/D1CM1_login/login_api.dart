import '../../constants/app_constants.dart';

/// D1CM1 – Login API module.
/// Establishes the structure for authentication and social login operations.
class LoginApi {
  final String baseUrl;

  LoginApi({this.baseUrl = AppConstants.apiBaseUrl});

  /// Google customer login
  Future<void> googleCustomerLogin() async {
    // Structure ready for future API integration
    throw UnimplementedError('googleCustomerLogin is not yet implemented');
  }

  /// Google Android login
  Future<void> googleAndroidLogin() async {
    // Structure ready for future API integration
    throw UnimplementedError('googleAndroidLogin is not yet implemented');
  }

  /// Facebook customer login
  Future<void> facebookCustomerLogin() async {
    // Structure ready for future API integration
    throw UnimplementedError('facebookCustomerLogin is not yet implemented');
  }

  /// LinkedIn customer login
  Future<void> linkedInCustomerLogin() async {
    // Structure ready for future API integration
    throw UnimplementedError('linkedInCustomerLogin is not yet implemented');
  }
}
