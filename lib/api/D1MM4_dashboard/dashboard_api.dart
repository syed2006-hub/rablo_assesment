import '../../constants/app_constants.dart';

/// D1MM4 – Dashboard API module.
/// Establishes the structure for dashboard metrics and overview data.
class DashboardApi {
  final String baseUrl;

  DashboardApi({this.baseUrl = AppConstants.apiBaseUrl});

  /// Fetch dashboard metrics and statistics
  Future<void> getDashboardData() async {
    throw UnimplementedError('getDashboardData is not yet implemented');
  }
}
