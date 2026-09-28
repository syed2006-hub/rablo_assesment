import 'package:get/get.dart';
import '../screens/login_screen.dart';
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
    ),
    GetPage(
      name: AppRoutes.widgets,
      page: () => const WidgetScreen(),
    ),
  ];
}
