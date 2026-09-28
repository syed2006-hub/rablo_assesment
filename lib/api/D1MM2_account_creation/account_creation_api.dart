import '../../constants/app_constants.dart';

/// D1MM2 – Account Creation API module.
/// Establishes the structure for user and business account creation.
class AccountCreationApi {
  final String baseUrl;

  AccountCreationApi({this.baseUrl = AppConstants.apiBaseUrl});

  /// Create individual customer account
  Future<void> createCustomerAccount() async {
    throw UnimplementedError('createCustomerAccount is not yet implemented');
  }

  /// Create business account (D1MM2.2)
  Future<void> createBusinessAccount() async {
    throw UnimplementedError('createBusinessAccount is not yet implemented');
  }
}
