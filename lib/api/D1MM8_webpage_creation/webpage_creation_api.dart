import '../../constants/app_constants.dart';

/// D1MM8 – Webpage Creation API module.
/// Establishes the structure for online gym webpage creation and templates.
class WebpageCreationApi {
  final String baseUrl;

  WebpageCreationApi({this.baseUrl = AppConstants.apiBaseUrl});

  /// Create online webpage configuration
  Future<void> createWebpage() async {
    throw UnimplementedError('createWebpage is not yet implemented');
  }

  /// Get webpage templates (D1MM8.2)
  Future<void> getWebpageTemplates() async {
    throw UnimplementedError('getWebpageTemplates is not yet implemented');
  }
}
