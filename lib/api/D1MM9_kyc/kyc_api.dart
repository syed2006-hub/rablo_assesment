import '../../constants/app_constants.dart';

/// D1MM9 – KYC Verification API module.
/// Establishes the structure for customer and business KYC document submission and verification.
class KycApi {
  final String baseUrl;

  KycApi({this.baseUrl = AppConstants.apiBaseUrl});

  /// Submit KYC verification documents
  Future<void> submitKycDocuments() async {
    throw UnimplementedError('submitKycDocuments is not yet implemented');
  }

  /// Check KYC verification status
  Future<void> checkKycStatus() async {
    throw UnimplementedError('checkKycStatus is not yet implemented');
  }
}
