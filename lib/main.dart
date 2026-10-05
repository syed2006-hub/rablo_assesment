import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'api/api_client.dart';
import 'api/auth_token_manager.dart';
import 'constants/app_colors.dart';
import 'constants/app_constants.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'services/D1CC6_attendance/attendance_service.dart';
import 'services/D1CM1_login/firebase_auth_service.dart';
import 'services/D1MM2_account_creation/account_creation_service.dart';
import 'services/D1MM3_membership_planning/membership_service.dart';
import 'services/D1MM4_dashboard/dashboard_service.dart';
import 'services/D1MM5_my_profile/profile_service.dart';
import 'services/api/bank_account_api_service.dart';
import 'services/api/business_connect_api_service.dart';
import 'services/api/membership_api_service.dart';
import 'services/api/profile_api_service.dart';
import 'services/api/trainer_api_service.dart';
import 'services/firebase/customer_firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization notice: $e');
  }

  // Pre-initialize Auth Token Manager & Bearer Session
  final tokenManager = Get.put(AuthTokenManager(), permanent: true);
  await tokenManager.initTokenManager();

  // Pre-initialize REST API Client & Backend Services
  Get.put(ApiClient(), permanent: true);
  Get.put(ProfileApiService(), permanent: true);
  Get.put(BankAccountApiService(), permanent: true);
  Get.put(TrainerApiService(), permanent: true);
  Get.put(BusinessConnectApiService(), permanent: true);
  Get.put(MembershipApiService(), permanent: true);

  // Pre-initialize Firebase Customer Service
  final customerFirebase = Get.put(CustomerFirebaseService(), permanent: true);
  await customerFirebase.initService();

  // Pre-initialize and restore persistent onboarding status from SharedPreferences
  final accountService = Get.put(AccountCreationService(), permanent: true);
  await accountService.initStorage();

  final profileService = Get.put(ProfileService(), permanent: true);
  profileService.syncFromCurrentAuth();

  runApp(const FitnessApp());
}

/// Root widget of the application.
class FitnessApp extends StatelessWidget {
  const FitnessApp({super.key});

  static String determineInitialRoute() {
    final fbUser = FirebaseAuthService.instance.currentFirebaseUser;
    final customerFb = Get.isRegistered<CustomerFirebaseService>()
        ? CustomerFirebaseService.to
        : null;
    final accountService = Get.isRegistered<AccountCreationService>()
        ? AccountCreationService.to
        : null;

    final hasUserSession = (fbUser != null) ||
        (customerFb != null && customerFb.isLoggedIn.value && customerFb.currentUid.value.isNotEmpty) ||
        (accountService != null && accountService.currentUser.value != null);

    if (hasUserSession) {
      final bool isOnboarded = (accountService != null && accountService.isOnboarded.value) ||
          (customerFb != null && customerFb.isOnboarded.value);

      if (isOnboarded) {
        return AppRoutes.customerHome;
      } else {
        return AppRoutes.forms;
      }
    }
    return AppRoutes.welcome;
  }

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
        if (!Get.isRegistered<AuthTokenManager>()) {
          Get.put(AuthTokenManager(), permanent: true);
        }
        if (!Get.isRegistered<ApiClient>()) {
          Get.put(ApiClient(), permanent: true);
        }
        if (!Get.isRegistered<ProfileApiService>()) {
          Get.put(ProfileApiService(), permanent: true);
        }
        if (!Get.isRegistered<BankAccountApiService>()) {
          Get.put(BankAccountApiService(), permanent: true);
        }
        if (!Get.isRegistered<TrainerApiService>()) {
          Get.put(TrainerApiService(), permanent: true);
        }
        if (!Get.isRegistered<BusinessConnectApiService>()) {
          Get.put(BusinessConnectApiService(), permanent: true);
        }
        if (!Get.isRegistered<MembershipApiService>()) {
          Get.put(MembershipApiService(), permanent: true);
        }
        if (!Get.isRegistered<MembershipService>()) {
          Get.put(MembershipService(), permanent: true);
        }
        if (!Get.isRegistered<AttendanceService>()) {
          Get.put(AttendanceService(), permanent: true);
        }
        if (!Get.isRegistered<DashboardService>()) {
          Get.put(DashboardService(), permanent: true);
        }
        if (!Get.isRegistered<AccountCreationService>()) {
          Get.put(AccountCreationService(), permanent: true);
        }
        if (!Get.isRegistered<ProfileService>()) {
          Get.put(ProfileService(), permanent: true);
        }
      }),
      initialRoute: determineInitialRoute(),
      getPages: AppPages.routes,
    );
  }
}
