import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xpress_nepal/features/auth/presentation/pages/register_screen.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';
import 'package:xpress_nepal/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:xpress_nepal/widgets/custom_button.dart';
import 'package:xpress_nepal/widgets/custom_text_field.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockAuthProvider extends Mock implements AuthProvider {}

void main() {
  late MockAuthViewModel mockAuthViewModel;
  late MockAuthProvider mockAuthProvider;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
    mockAuthProvider = MockAuthProvider();
    when(() => mockAuthProvider.authViewModel).thenReturn(mockAuthViewModel);
    AuthProvider.instance = mockAuthProvider;

    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1200, 2400);
    binding.window.devicePixelRatioTestValue = 1.0;
  });

  tearDown(() {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  Future<void> pumpRegisterScreen(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: RegisterScreen()));
    await tester.pumpAndSettle();
  }

  testWidgets('shows validation error for password mismatch', (tester) async {
    await pumpRegisterScreen(tester);

    await tester.enterText(
      find.widgetWithText(CustomTextField, 'Password'),
      '123456',
    );
    await tester.enterText(
      find.widgetWithText(CustomTextField, 'Confirm Password'),
      'password',
    );

    await tester.ensureVisible(
      find.widgetWithText(CustomButton, 'Create Account'),
    );
    await tester.tap(
      find.widgetWithText(CustomButton, 'Create Account'),
      warnIfMissed: false,
    );
    await tester.pump();

    expect(find.text('Passwords do not match'), findsOneWidget);
  });
}
