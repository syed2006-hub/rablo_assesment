import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../widgets/customer_floating_nav_bar.dart';
import '../D1CC6_attendance/customer_scanner_screen.dart';
import '../D1MM10_dashboard_v2/dashboard_v2_screen.dart';
import '../D1MM5_my_profile/my_profile_screen.dart';

/// Customer Home Shell housing the floating navigation bar.
class CustomerHomeShell extends StatefulWidget {
  final int initialIndex;

  const CustomerHomeShell({super.key, this.initialIndex = 0});

  @override
  State<CustomerHomeShell> createState() => _CustomerHomeShellState();
}

class _CustomerHomeShellState extends State<CustomerHomeShell> {
  late int _currentIndex;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pages = [
      const DashboardV2Screen(),
      CustomerScannerScreen(
        onBackToHome: () {
          setState(() => _currentIndex = 0);
        },
      ),
      const MyProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slateScaffold,
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
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
