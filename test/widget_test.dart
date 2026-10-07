import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fitness_app_clean/controllers/D1CC6_attendance/scanner_controller.dart';
import 'package:fitness_app_clean/routes/app_routes.dart';
import 'package:fitness_app_clean/main.dart';
import 'package:fitness_app_clean/services/D1CM2_account_creation/account_creation_service.dart';
import 'package:fitness_app_clean/widgets/common_stat_card.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    Get.reset();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Initial Welcome Screen, Google Sign-in & Onboarding flow test',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const FitnessApp());
    await tester.pumpAndSettle();

    // 1. Initial screen is Welcome Screen strictly matching Figma
    expect(find.text('Manage Your'), findsOneWidget);
    expect(find.text('Fitness Centre'), findsOneWidget);
    expect(find.text('with us!'), findsOneWidget);
    expect(find.text('All your business operations in one place, ready for you to take charge.'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);

    // 2. Tap Get Started to navigate to Social Login Screen
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // Verify Social Login Screen strictly matching Figma image
    expect(find.text('Hi there!'), findsOneWidget);
    expect(find.text('Sign in to keep things running smoothly.'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with LinkedIn'), findsOneWidget);
    expect(find.text('Continue with Facebook'), findsOneWidget);

    // 3. Tap Continue with Google: onboarding is false until submitted, so it routes to Account Creation
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    // Verify Account Creation / Onboarding Screen
    expect(find.text("Let's begin!"), findsOneWidget);
    expect(find.text('Create your account to start your journey.'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Select Gender'), findsOneWidget);
    expect(find.text('Date of Birth'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);

    // 4. Fill required fields (Phone, Address, Terms) and submit
    await tester.enterText(find.widgetWithText(TextField, 'Enter mobile number'), '9876543210');
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.widgetWithText(TextField, 'Enter or Pin the Address'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Enter or Pin the Address'), 'MG Road 4th Cross');

    await tester.ensureVisible(find.widgetWithText(TextField, 'Enter City'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Enter City'), 'Bengaluru');
    await tester.enterText(find.widgetWithText(TextField, 'Enter State'), 'Karnataka');
    await tester.enterText(find.widgetWithText(TextField, '------'), '560001');
    await tester.pumpAndSettle();

    // Scroll to Terms Checkbox
    await tester.ensureVisible(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    // Scroll to Create Account CTA Button
    await tester.ensureVisible(find.text('Create Account'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    // Verify User has completed onboarding and enters Customer Dashboard V2
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Membership Name'), findsOneWidget);
    expect(find.text('Rush Hours Indicator'), findsOneWidget);

    // 5. Verify Customer Subscription Plans
    Get.toNamed(AppRoutes.customerPlans);
    await tester.pumpAndSettle();

    expect(find.text('Design your Membership as you wish.'), findsOneWidget);
    expect(find.text('Offerings'), findsOneWidget);
    expect(find.text('Starter'), findsWidgets);
    expect(find.text('Business'), findsWidgets);

    // 6. Verify Live QR Scanner Section (Figma Scan & Connect)
    Get.toNamed(AppRoutes.customerQr);
    await tester.pumpAndSettle();

    expect(find.text('Scan & Connect'), findsOneWidget);
    expect(find.text('Scan the QR code on the machine to start workout'), findsOneWidget);
    expect(find.text('Upload QR'), findsOneWidget);
    expect(find.text('Scan & Join'), findsOneWidget);

    // Test Confirmation Required Modal via controller
    final scannerController = ScannerController.to;
    scannerController.triggerConfirmationRequired();
    await tester.pumpAndSettle();
    expect(
        find.byWidgetPredicate((w) =>
            w is Text &&
            (w.data == 'Confirmation required?' ||
                w.data == 'Connect Your Business?')),
        findsOneWidget);
    final checkInBtn = find.byWidgetPredicate((w) =>
        w is Text && (w.data == 'Check-in' || w.data == 'Confirm & Connect'));
    expect(checkInBtn, findsOneWidget);

    // Tap Check-in / Confirm & Connect to trigger Congratulations Modal
    await tester.tap(checkInBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();
    expect(
        find.byWidgetPredicate((w) =>
            w is Text &&
            (w.data == 'Congratulations!' ||
                w.data == '🎉 Business Connected!')),
        findsOneWidget);

    final passBtn = find.byWidgetPredicate((w) =>
        w is Text &&
        (w.data == 'Access Membership Pass' ||
            w.data == 'Dashboard' ||
            w.data == 'Join Plan'));
    expect(passBtn, findsWidgets);

    // Close Congratulations / Connected Modal
    await tester.tap(passBtn.first);
    await tester.pumpAndSettle();

    // Test Timeout Modal
    scannerController.triggerTimeout();
    await tester.pumpAndSettle();
    expect(find.text('Scanning Timeout'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Test Something went wrong! Modal
    scannerController.triggerSomethingWentWrong();
    await tester.pumpAndSettle();
    expect(find.text('Something went wrong!'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();

    // Settle any active snackbars
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    // 7. Verify My Profile Hub Screen (D1CM6)
    Get.toNamed(AppRoutes.profile);
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Manage your account as your wish.'), findsOneWidget);
    expect(find.text('Personal & Business'), findsOneWidget);
    expect(find.text('Bank Account'), findsOneWidget);
    expect(find.text('Transactions'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);

    // 8. Verify Personal Details Screen & Update celebration dialog
    await tester.tap(find.text('Personal Details'));
    await tester.pumpAndSettle();

    expect(find.text('My Profiles > Personal Details'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Select Gender'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);

    // Tap Update to trigger Figma "Update Successful!" celebration dialog
    await tester.ensureVisible(find.text('Update'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Update'));
    await tester.pumpAndSettle();

    expect(find.text('Update Successful!'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // 9. Verify Logout Confirmation Dialog (Leaving So Soon?)
    await tester.ensureVisible(find.text('Logout'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Leaving So Soon?'), findsOneWidget);
    expect(find.text('By Pressing Logout, You will exit the app.'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Tap Cancel to dismiss dialog cleanly
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Leaving So Soon?'), findsNothing);
  });

  testWidgets('Staff & Admin Management navigation smoke test',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const FitnessApp());
    await tester.pumpAndSettle();

    // Navigate to Staff Desk via route
    Get.toNamed(AppRoutes.home);
    await tester.pumpAndSettle();

    // Verify Dashboard Screen
    expect(find.text('Gym Management Overview'), findsOneWidget);
    expect(find.byType(CommonStatCard), findsWidgets);
    expect(find.text('Quick Operations'), findsOneWidget);
    expect(find.text('⚡ Check-In Pass'), findsOneWidget);

    // Navigate to Members tab
    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();
    expect(find.text('Gym Members Directory'), findsOneWidget);
    expect(find.text('Alex Turner'), findsOneWidget);

    // Navigate to Settings tab
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Firebase Backend'), findsOneWidget);
  });

  testWidgets('Returning user with stored onboarding status skips onboarding directly to Customer Dashboard',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Pre-populate persistent storage with existing user account and onboarded status
    SharedPreferences.setMockInitialValues({
      'onboarded_alex_fitness@gmail_com': true,
      'last_user_onboarded': true,
      'last_user_id': 'alex_fitness@gmail_com',
      'account_data_alex_fitness@gmail_com': '''{
        "accountId": "alex_fitness@gmail_com",
        "fullName": "Alex Morgan",
        "email": "alex.fitness@gmail.com",
        "phoneNumber": "+91 9876543210",
        "gender": "Male",
        "registrationDate": "2024-01-01T00:00:00.000",
        "acceptedTerms": true
      }''',
    });

    await tester.pumpWidget(const FitnessApp());
    await tester.pumpAndSettle();

    // 1. Initial screen
    expect(find.text('Get Started'), findsOneWidget);
    await tester.tap(find.text('Get Started'));
    await tester.pumpAndSettle();

    // 2. Tap Continue with Google
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    // 3. User is ALREADY onboarded, so it SKIPS onboarding ("Let's begin!" should not appear)
    expect(find.text("Let's begin!"), findsNothing);
    // Directly lands on Customer Dashboard
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Membership Name'), findsOneWidget);

    // Settle snackbar timer
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('App startup with stored session and onboarding immediately loads Customer Dashboard',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    SharedPreferences.setMockInitialValues({
      'is_logged_in': true,
      'is_onboarded': true,
      'last_user_onboarded': true,
      'last_user_id': 'MBR-1005',
      'last_user_email': 'alex.fitness@gmail.com',
      'active_account_data': '''{
        "uid": "USER-12345",
        "accountId": "MBR-1005",
        "fullName": "Alex Morgan",
        "email": "alex.fitness@gmail.com",
        "phoneNumber": "+91 9876543210",
        "gender": "Male",
        "registrationDate": "2024-01-01T00:00:00.000",
        "isOnboarded": true,
        "acceptedTerms": true
      }''',
      'onboarded_MBR-1005': true,
      'onboarded_alex_fitness@gmail_com': true,
    });

    final accountService = Get.put(AccountCreationService(), permanent: true);
    await accountService.initStorage();

    await tester.pumpWidget(const FitnessApp());
    await tester.pumpAndSettle();

    // Verify it immediately displays Customer Dashboard and NOT Welcome or Onboarding
    expect(find.text("Let's begin!"), findsNothing);
    expect(find.text('Manage Your'), findsNothing);
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Membership Name'), findsOneWidget);
  });
}
