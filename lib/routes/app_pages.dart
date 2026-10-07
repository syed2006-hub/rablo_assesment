import 'package:get/get.dart';
import '../screens/D1CC6_attendance/attendance_screen.dart';
import '../screens/D1CM1_login/login_screen.dart';
import '../screens/D1CM1_login/signup_screen.dart';
import '../screens/D1CM1_login/welcome_screen.dart';
import '../screens/D1CM2_account_creation/account_creation_form_screen.dart';
import '../screens/D1CM3_affiliation_scanning/affiliation_scanning_screen.dart';
import '../screens/D1CM4_membership_joining/membership_detail_screen.dart';
import '../screens/D1CM4_membership_joining/membership_joining_screen.dart';
import '../screens/D1CM4_membership_joining/membership_list_screen.dart';
import '../screens/D1CM4_membership_joining/membership_plans_list_screen.dart';
import '../screens/D1CM4_membership_joining/plan_listing_screen.dart';
import '../screens/D1CM4_membership_joining/plan_overview_screen.dart';
import '../screens/D1CM4_membership_joining/subscription_plans_screen.dart';
import '../screens/D1CM4_membership_joining/webpage_plans_screen.dart';
import '../screens/D1CM5_dashboard_v1/dashboard_v1_screen.dart';
import '../screens/D1CM6_my_profile/bank_account_screen.dart';
import '../screens/D1CM6_my_profile/my_business_connects_screen.dart';
import '../screens/D1CM6_my_profile/my_profile_screen.dart';
import '../screens/D1CM6_my_profile/my_trainers_screen.dart';
import '../screens/D1CM6_my_profile/personal_details_screen.dart';
import '../screens/D1CM9_dashboard_v2/dashboard_screen.dart';
import '../screens/D1CM9_dashboard_v2/dashboard_v2_screen.dart';
import '../screens/home/customer_home_shell.dart';
import '../screens/home/home_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/widget_screen.dart';
import 'app_routes.dart';

/// GetX route configurations for Rablo Customer Application.
class AppPages {
  AppPages._();

  static const String initial = AppRoutes.welcome;

  static final List<GetPage> routes = [
    // Customer Module Routes (Figma Implementation)
    GetPage(
      name: AppRoutes.welcome,
      page: () => const WelcomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.customerHome,
      page: () => const CustomerHomeShell(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.customerDashboard,
      page: () => const DashboardV2Screen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.customerPlans,
      page: () => const SubscriptionPlansScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.customerPlanListing,
      page: () => const PlanListingScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.customerPlanOverview,
      page: () => const PlanOverviewScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.customerQr,
      page: () => const CustomerHomeShell(initialIndex: 1),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.customerTransactions,
      page: () => const BankAccountScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.customerWebpage,
      page: () => const WebpagePlansScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.personalDetails,
      page: () => const PersonalDetailsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.businessConnects,
      page: () => const MyBusinessConnectsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.myTrainers,
      page: () => const MyTrainersScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.membershipPlansList,
      page: () => const MembershipPlansListScreen(),
      transition: Transition.rightToLeft,
    ),

    // D1CM Customer Module Explicit Routes (DRD Specifications)
    GetPage(
      name: AppRoutes.customerAccountCreation,
      page: () => const AccountCreationFormScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.affiliationScanning,
      page: () => const AffiliationScanningScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.membershipJoining,
      page: () => const MembershipJoiningScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.customerDashboardV1,
      page: () => const DashboardV1Screen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.customerDashboardV2,
      page: () => const DashboardV2Screen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.customerProfile,
      page: () => const MyProfileScreen(),
      transition: Transition.rightToLeft,
    ),

    // Authentication & Core Navigation Routes
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.signup,
      page: () => const SignupScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.members,
      page: () => const MembershipListScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.memberDetail,
      page: () => const MembershipDetailScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.forms,
      page: () => const AccountCreationFormScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.accountCreation,
      page: () => const AccountCreationFormScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const AccountCreationFormScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const MyProfileScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.attendance,
      page: () => const AttendanceScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: AppRoutes.widgets,
      page: () => const WidgetScreen(),
      transition: Transition.rightToLeft,
    ),
  ];
}
