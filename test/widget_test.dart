import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app_clean/constants/app_constants.dart';
import 'package:fitness_app_clean/main.dart';
import 'package:fitness_app_clean/widgets/common_app_bar.dart';
import 'package:fitness_app_clean/widgets/common_button.dart';
import 'package:fitness_app_clean/widgets/common_container.dart';
import 'package:fitness_app_clean/widgets/common_section_header.dart';
import 'package:fitness_app_clean/widgets/common_text_field.dart';

void main() {
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
    await tester.tap(find.text('Skip to Widget Screen'));
    await tester.pumpAndSettle();

    // Verify WidgetScreen is loaded with all common components.
    expect(find.text('Reusable Components Showcase'), findsOneWidget);
  });
}
