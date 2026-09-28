import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'constants/app_colors.dart';
import 'constants/app_constants.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'services/D1CC6_attendance/attendance_service.dart';
import 'services/D1MM3_membership_planning/membership_service.dart';
import 'services/D1MM4_dashboard/dashboard_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  runApp(const FitnessApp());
}

/// Root widget of the application.
class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.backgroundLight,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          surface: AppColors.white,
        ),
      ),
      initialBinding: BindingsBuilder(() {
        if (!Get.isRegistered<MembershipService>()) {
          Get.put(MembershipService(), permanent: true);
        }
        if (!Get.isRegistered<AttendanceService>()) {
          Get.put(AttendanceService(), permanent: true);
        }
        if (!Get.isRegistered<DashboardService>()) {
          Get.put(DashboardService(), permanent: true);
        }
      }),
      initialRoute: AppPages.initial,
      getPages: AppPages.routes,
    );
  }
}
