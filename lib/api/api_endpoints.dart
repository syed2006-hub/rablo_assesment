/// Centralized REST API Endpoints Definition
class ApiEndpoints {
  ApiEndpoints._();

  /// Base API URL (can be switched to localhost, staging, or production)
  static const String baseUrl = 'http://localhost:8080/api';
  // 1. Profile & Authentication Endpoints
  static const String profile = '/profile';
  static const String profileVerification = '/profile/verification';
  static const String profilePhoto = '/profile/photo';
  static const String profileDeactivate = '/profile/deactivate';

  // 2. Bank Accounts & Financial Endpoints
  static const String bankAccounts = '/bank-accounts';
  static String bankAccountById(String id) => '/bank-accounts/$id';
  static String bankAccountVisibility(String id) =>
      '/bank-accounts/$id/visibility';

  // 3. Transactions Endpoints
  static const String transactions = '/transactions';
  static String transactionById(String id) => '/transactions/$id';

  // 4. Trainers Endpoints
  static const String trainers = '/trainers';
  static String trainerById(String id) => '/trainers/$id';
  static String trainerSessions(String id) => '/trainers/$id/sessions';

  // 5. Business Connects Endpoints
  static const String businessConnects = '/business-connects';
  static String businessConnectById(String id) => '/business-connects/$id';
  static String businessConnectStatus(String id) =>
      '/business-connects/$id/status';

  // 6. Membership Plans Endpoints
  static const String membershipPlans = '/membership-plans';
  static String membershipPlanById(String id) => '/membership-plans/$id';
  static const String subscribePlan = '/membership-plans/subscribe';

  // 7. Attendance & QR Endpoints
  static const String attendanceCheckIn = '/attendance/check-in';
  static const String attendanceHistory = '/attendance/history';
}
