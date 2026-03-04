import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xpress_nepal/features/auth/presentation/pages/login_screen.dart';
import 'package:xpress_nepal/features/auth/presentation/pages/register_screen.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';
import 'package:xpress_nepal/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:xpress_nepal/features/auth/services/biometric_auth_manager.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockAuthProvider extends Mock implements AuthProvider {}

class MockBiometricAuthManager extends Mock implements BiometricAuthManager {}

void main() {
  late MockAuthViewModel mockAuthViewModel;
  late MockAuthProvider mockAuthProvider;
  late MockBiometricAuthManager mockBiometricAuthManager;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
    mockAuthProvider = MockAuthProvider();
    mockBiometricAuthManager = MockBiometricAuthManager();

    // Setup AuthProvider
    when(() => mockAuthProvider.authViewModel).thenReturn(mockAuthViewModel);
    when(
      () => mockAuthProvider.biometricAuthManager,
    ).thenReturn(mockBiometricAuthManager);
    when(
      () => mockBiometricAuthManager.biometricLoginEnabled,
    ).thenReturn(false);
    AuthProvider.instance = mockAuthProvider;

    // Set a larger screen size for testing to avoid overflow
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    // Use a large screen to avoid overflows and logic constraints
    binding.window.physicalSizeTestValue = const Size(1200, 2400);
    binding.window.devicePixelRatioTestValue = 1.0;
  });

  tearDown(() {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  Future<void> pumpLoginScreen(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: const LoginScreen()));
    await tester.pumpAndSettle();
  }

  testWidgets('renders all main widgets', (tester) async {
    await pumpLoginScreen(tester);
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(
      find.text('Login to continue your shopping journey'),
      findsOneWidget,
    );
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  testWidgets('navigates to RegisterScreen on Sign Up tap', (tester) async {
    await pumpLoginScreen(tester);
    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}
