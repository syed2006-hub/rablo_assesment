import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../controllers/home/home_controller.dart';
import '../D1MM2_account_creation/account_creation_form_screen.dart';
import '../D1MM3_membership_planning/membership_list_screen.dart';
import '../D1MM4_dashboard/dashboard_screen.dart';
import '../D1MM5_my_profile/my_profile_screen.dart';
import '../settings/settings_screen.dart';

/// Main Navigation Shell hosting Dashboard, Members Directory, Form, Profile, and Settings.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    final List<Widget> screens = const [
      DashboardScreen(),
      MembershipListScreen(),
      AccountCreationFormScreen(),
      MyProfileScreen(),
      SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Obx(
        () => IndexedStack(
          index: controller.selectedTabIndex.value,
          children: screens,
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.dark,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBarTheme(
          data: NavigationBarThemeData(
            backgroundColor: AppColors.dark,
            indicatorColor: AppColors.primary,
            labelTextStyle:
                WidgetStateProperty.resolveWith<TextStyle>((states) {
              if (states.contains(WidgetState.selected)) {
                return const TextStyle(
                  color: AppColors.primaryBright,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                );
              }
              return const TextStyle(
                color: AppColors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              );
            }),
            iconTheme:
                WidgetStateProperty.resolveWith<IconThemeData>((states) {
              if (states.contains(WidgetState.selected)) {
                return const IconThemeData(
                  color: AppColors.dark,
                  size: 24,
                );
              }
              return const IconThemeData(
                color: AppColors.grey,
                size: 22,
              );
            }),
          ),
          child: Obx(
            () => NavigationBar(
              selectedIndex: controller.selectedTabIndex.value,
              onDestinationSelected: controller.changeTab,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline_rounded),
                  selectedIcon: Icon(Icons.people_rounded),
                  label: 'Members',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_add_outlined),
                  selectedIcon: Icon(Icons.person_add_rounded),
                  label: 'Register',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_circle_outlined),
                  selectedIcon: Icon(Icons.account_circle_rounded),
                  label: 'Profile',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings_rounded),
                  label: 'Settings',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
