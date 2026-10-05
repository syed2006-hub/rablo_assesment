import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants/app_colors.dart';
import '../../controllers/D1CM5_dashboard_v1/dashboard_v1_controller.dart' as cm5_ctrl;
import '../../services/firebase/customer_firebase_service.dart';
import '../../widgets/customer_floating_nav_bar.dart';
import '../D1CC6_attendance/customer_scanner_screen.dart';
import '../D1CM5_dashboard_v1/dashboard_v1_screen.dart' as cm5;
import '../D1CM6_my_profile/my_profile_screen.dart' as cm6;
import '../D1CM9_dashboard_v2/dashboard_v2_screen.dart' as cm9;

/// Customer Home Shell housing the floating navigation bar.
/// Houses the Customer Modules (D1CM):
/// - Tab 0: Stepper Progression (V1 at 20%/60%) -> Full Dashboard (V2 once completed)
/// - Tab 1: Live QR Scanner (D1CC6 Attendance & Pass Scanning)
/// - Tab 2: My Profile (D1CM6 Customer Profile & Account Management)
class CustomerHomeShell extends StatefulWidget {
  final int initialIndex;

  const CustomerHomeShell({super.key, this.initialIndex = 0});

  @override
  State<CustomerHomeShell> createState() => _CustomerHomeShellState();
}

class _CustomerHomeShellState extends State<CustomerHomeShell> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Widget _buildDashboardTab() {
    final v1Controller = Get.isRegistered<cm5_ctrl.DashboardV1Controller>()
        ? cm5_ctrl.DashboardV1Controller.to
        : Get.put(cm5_ctrl.DashboardV1Controller());

    return Obx(() {
      final hasFbPlan = Get.isRegistered<CustomerFirebaseService>() &&
          (CustomerFirebaseService.to.isDashboardV2Active.value ||
              CustomerFirebaseService.to.activePlan.value != null);
      final isV2Active = v1Controller.isDashboardV2Active.value ||
          v1Controller.activeStep.value >= 2 ||
          hasFbPlan;
      if (isV2Active) {
        return const cm9.DashboardV2Screen();
      }
      return const cm5.DashboardV1Screen();
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildDashboardTab(),
      CustomerScannerScreen(
        onBackToHome: () {
          setState(() => _currentIndex = 0);
        },
      ),
      const cm6.MyProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: AppColors.slateScaffold,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: pages,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: CustomerFloatingNavBar(
              currentIndex: _currentIndex,
              onTabSelected: (index) {
                setState(() => _currentIndex = index);
              },
              onQrScanPressed: () {
                setState(() => _currentIndex = 1);
              },
            ),
          ),
        ],
      ),
    );
  }
}
