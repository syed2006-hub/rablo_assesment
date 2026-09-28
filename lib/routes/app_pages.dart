import 'package:get/get.dart';
import '../screens/D1CC6_attendance/attendance_screen.dart';
import '../screens/D1CM1_login/login_screen.dart';
import '../screens/D1CM1_login/signup_screen.dart';
import '../screens/D1MM2_account_creation/account_creation_form_screen.dart';
import '../screens/D1MM3_membership_planning/membership_detail_screen.dart';
import '../screens/D1MM3_membership_planning/membership_list_screen.dart';
import '../screens/D1MM4_dashboard/dashboard_screen.dart';
import '../screens/D1MM5_my_profile/my_profile_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/widget_screen.dart';
import 'app_routes.dart';

/// GetX route configurations.
class AppPages {
  AppPages._();

  static const String initial = AppRoutes.login;

  static final List<GetPage> routes = [
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
