import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testingplatform/app.dart';
import 'package:testingplatform/presentation/screens/login_screen.dart';

void main() {
  testWidgets('LoginScreen displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const App());

    // Verify that the LoginScreen is displayed (initial route is '/').
    expect(find.byType(LoginScreen), findsOneWidget);

    // Verify that the "Login" text is present on the AppBar.
    expect(find.text('Login'), findsOneWidget);

    // Verify that the email and password fields are present.
    expect(find.widgetWithText(CustomTextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(CustomTextField, 'Password'), findsOneWidget);

    // Verify that the "Login" button is present.
    expect(find.widgetWithText(CustomButton, 'Login'), findsOneWidget);

    // Verify that the "Don't have an account? Register" link is present.
    expect(find.text('Don\'t have an account? Register'), findsOneWidget);
  });
}