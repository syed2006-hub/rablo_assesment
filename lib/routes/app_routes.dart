/// Named routes for the application.
abstract class AppRoutes {
  AppRoutes._();

  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const dashboard = '/dashboard';
  static const members = '/members';
  static const memberDetail = '/member-detail';
  static const forms = '/forms';
  static const accountCreation = '/account-creation';
  static const onboarding = '/onboarding';
  static const profile = '/profile';
  static const attendance = '/attendance';
  static const settings = '/settings';
  static const widgets = '/widgets';

  // Customer Module Routes (Figma Implementation)
  static const welcome = '/welcome';
  static const customerHome = '/customer-home';
  static const customerDashboard = '/customer-dashboard';
  static const customerPlans = '/customer-plans';
  static const customerPlanListing = '/customer-plan-listing';
  static const customerQr = '/customer-qr';
  static const customerTransactions = '/customer-transactions';
  static const customerWebpage = '/customer-webpage';
  static const personalDetails = '/personal-details';
  static const customerPlanOverview = '/customer-plan-overview';
  static const businessConnects = '/business-connects';
  static const myTrainers = '/my-trainers';
  static const membershipPlansList = '/membership-plans-list';

  // D1CM Explicit Customer Routes (DRD Specifications)
  static const customerAccountCreation = '/customer-account-creation';
  static const affiliationScanning = '/affiliation-scanning';
  static const membershipJoining = '/membership-joining';
  static const customerDashboardV1 = '/customer-dashboard-v1';
  static const customerDashboardV2 = '/customer-dashboard-v2';
  static const customerProfile = '/customer-profile';
}


