import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:fitness_app_clean/constants/app_constants.dart';
import 'package:fitness_app_clean/main.dart';
import 'package:fitness_app_clean/widgets/common_app_bar.dart';
import 'package:fitness_app_clean/widgets/common_button.dart';
import 'package:fitness_app_clean/widgets/common_container.dart';
import 'package:fitness_app_clean/widgets/common_section_header.dart';
import 'package:fitness_app_clean/widgets/common_stat_card.dart';
import 'package:fitness_app_clean/widgets/common_status_chip.dart';
import 'package:fitness_app_clean/widgets/common_text_field.dart';

void main() {
  setUp(() {
    Get.reset();
  });

  testWidgets('Initial Login with mock validation smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FitnessApp());
    await tester.pumpAndSettle();

    // Verify application title and app bar on login screen.
    expect(find.text(AppConstants.appName), findsOneWidget);
    expect(find.byType(CommonAppBar), findsOneWidget);

    // Verify common components on the login screen.
    expect(find.byType(CommonSectionHeader), findsWidgets);
    expect(find.byType(CommonContainer), findsWidgets);
    expect(find.byType(CommonTextField), findsWidgets);
    expect(find.byType(CommonButton), findsWidgets);

    // Verify mock validation button and skip button are present.
    expect(find.text('Sign In (Mock Validation)'), findsOneWidget);
    expect(find.text('Skip to Widget Screen'), findsOneWidget);

    // Tap Skip to navigate to WidgetScreen
    await tester.ensureVisible(find.text('Skip to Widget Screen'));
    await tester.tap(find.text('Skip to Widget Screen'));
    await tester.pumpAndSettle();

    // Verify WidgetScreen is loaded with all common components.
    expect(find.text('Reusable Components Showcase'), findsOneWidget);
    expect(find.byType(CommonStatCard), findsWidgets);
    expect(find.byType(CommonStatusChip), findsWidgets);
  });

  testWidgets('Day 5 Home & Dashboard Navigation smoke test',
      (WidgetTester tester) async {
    await tester.pumpWidget(const FitnessApp());
    await tester.pumpAndSettle();

    // Scroll to and tap Direct to Home & Dashboard
    final directBtn = find.text('Direct to Home & Dashboard →');
    await tester.ensureVisible(directBtn);
    await tester.tap(directBtn);
    await tester.pumpAndSettle();

    // Verify Dashboard Screen
    expect(find.text('Gym Management Overview'), findsOneWidget);
    expect(find.byType(CommonStatCard), findsWidgets);
    expect(find.text('Quick Operations'), findsOneWidget);
    expect(find.text('⚡ Check-In Pass'), findsOneWidget);

    // Navigate to Members tab (bottom bar index 1)
    await tester.tap(find.text('Members'));
    await tester.pumpAndSettle();

    expect(find.text('Gym Members Directory'), findsOneWidget);
    expect(find.text('Alex Turner'), findsOneWidget);

    // Navigate to Register tab (bottom bar index 2)
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    expect(find.text('Register New Member / Business'), findsOneWidget);
    expect(find.text('Personal & Contact Details'), findsOneWidget);

    // Navigate to Profile tab (bottom bar index 3)
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Arjun Nair'), findsOneWidget);
    expect(find.text('Head Fitness Director'), findsOneWidget);

    // Navigate to Settings tab (bottom bar index 4)
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    expect(find.text('Firebase Backend'), findsOneWidget);
    expect(find.text('Project ID: rablo-rablo'), findsOneWidget);
  });
}
