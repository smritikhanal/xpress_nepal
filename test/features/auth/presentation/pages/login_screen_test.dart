import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:xpress_nepal/features/auth/domain/entities/user_entity.dart';
import 'package:xpress_nepal/features/auth/presentation/pages/login_screen.dart';
import 'package:xpress_nepal/features/auth/presentation/pages/register_screen.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';
import 'package:xpress_nepal/features/auth/presentation/state/auth_state.dart';
import 'package:xpress_nepal/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:xpress_nepal/features/home/presentation/pages/home_screen.dart';
import 'package:xpress_nepal/features/seller/presentation/pages/seller_dashboard_screen.dart';
import 'package:xpress_nepal/features/order/presentation/providers/order_provider.dart';
import 'package:xpress_nepal/features/order/presentation/state/order_state.dart';
import 'package:xpress_nepal/features/order/presentation/view_model/order_view_model.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/features/product/presentation/state/product_state.dart';
import 'package:xpress_nepal/features/product/presentation/view_model/product_view_model.dart';
import 'package:xpress_nepal/features/cart/presentation/provider/cart_provider.dart';
import 'package:xpress_nepal/features/cart/presentation/state/cart_state.dart';
import 'package:xpress_nepal/features/cart/presentation/view_model/cart_view_model.dart';
import 'package:xpress_nepal/features/category/presentation/providers/category_provider.dart';
import 'package:xpress_nepal/features/category/presentation/view_model/category_view_model.dart';


class MockAuthViewModel extends Mock implements AuthViewModel {}
class MockAuthProvider extends Mock implements AuthProvider {}
class MockProductViewModel extends Mock implements ProductViewModel {}
class MockProductProvider extends Mock implements ProductProvider {}
class MockOrderViewModel extends Mock implements OrderViewModel {}
class MockCartViewModel extends Mock implements CartViewModel {}
class MockCategoryViewModel extends Mock implements CategoryViewModel {}
class MockCategoryProvider extends Mock implements CategoryProvider {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

void main() {
  late MockAuthViewModel mockAuthViewModel;
  late MockAuthProvider mockAuthProvider;
  late MockProductViewModel mockProductViewModel;
  late MockProductProvider mockProductProvider;
  late MockOrderViewModel mockOrderViewModel;
  late MockCartViewModel mockCartViewModel;
  late MockCategoryViewModel mockCategoryViewModel;
  late MockCategoryProvider mockCategoryProvider;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
    mockAuthProvider = MockAuthProvider();
    mockProductViewModel = MockProductViewModel();
    mockProductProvider = MockProductProvider();
    mockOrderViewModel = MockOrderViewModel();
    mockCartViewModel = MockCartViewModel();
    mockCategoryViewModel = MockCategoryViewModel();
    mockCategoryProvider = MockCategoryProvider();

    // Setup AuthProvider
    when(() => mockAuthProvider.authViewModel).thenReturn(mockAuthViewModel);
    AuthProvider.instance = mockAuthProvider;

    // Setup ProductProvider
    when(() => mockProductProvider.productViewModel).thenReturn(mockProductViewModel);
    ProductProvider.instance = mockProductProvider;
    when(() => mockProductViewModel.state).thenReturn(ProductState());
    when(() => mockProductViewModel.addListener(any())).thenReturn(null);
    when(() => mockProductViewModel.removeListener(any())).thenReturn(null);

    // Setup OrderProvider
    OrderProvider.instance = mockOrderViewModel; 
    when(() => mockOrderViewModel.state).thenReturn(const OrderState());
    when(() => mockOrderViewModel.addListener(any())).thenReturn(null);
    when(() => mockOrderViewModel.removeListener(any())).thenReturn(null);

    // Setup CartProvider
    CartProvider.instance = mockCartViewModel; // Assign ViewModel directly
    when(() => mockCartViewModel.state).thenReturn(const CartState());
    when(() => mockCartViewModel.addListener(any())).thenReturn(null);
    when(() => mockCartViewModel.removeListener(any())).thenReturn(null);

    // Setup CategoryProvider
    when(() => mockCategoryProvider.categoryViewModel).thenReturn(mockCategoryViewModel);
    CategoryProvider.setInstance = mockCategoryProvider; // Use setter
    when(() => mockCategoryViewModel.categories).thenReturn([]);
    when(() => mockCategoryViewModel.isLoading).thenReturn(false);
    when(() => mockCategoryViewModel.error).thenReturn(null);
    when(() => mockCategoryViewModel.addListener(any())).thenReturn(null);
    when(() => mockCategoryViewModel.removeListener(any())).thenReturn(null);

    // Set a larger screen size for testing to avoid overflow
    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
    // Use a large screen to avoid overflows and logic constraints
    binding.window.physicalSizeTestValue = const Size(1200, 2400);
    binding.window.devicePixelRatioTestValue = 1.0;
  });
  
  tearDown(() {
    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
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

  testWidgets('shows validation errors for empty fields', (tester) async {
    await pumpLoginScreen(tester);
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Please enter your email'), findsOneWidget);
    expect(find.text('Please enter your password'), findsOneWidget);
  });

  testWidgets('shows validation error for invalid email', (tester) async {
    await pumpLoginScreen(tester);
    await tester.ensureVisible(find.byType(TextFormField).at(0));
    await tester.enterText(find.byType(TextFormField).at(0), 'invalid');
    await tester.ensureVisible(find.byType(TextFormField).at(1));
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Please enter a valid email'), findsOneWidget);
  });

  testWidgets('shows validation error for short password', (tester) async {
    await pumpLoginScreen(tester);
    await tester.ensureVisible(find.byType(TextFormField).at(0));
    await tester.enterText(find.byType(TextFormField).at(0), 'test@email.com');
    await tester.ensureVisible(find.byType(TextFormField).at(1));
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Password must be at least 6 characters'), findsOneWidget);
  });





  testWidgets('shows error SnackBar on failed login', (tester) async {
    when(
      () => mockAuthViewModel.login(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => false);
    when(() => mockAuthViewModel.errorMessage).thenReturn('Login failed');

    await pumpLoginScreen(tester);
    await tester.ensureVisible(find.byType(TextFormField).at(0));
    await tester.enterText(find.byType(TextFormField).at(0), 'fail@email.com');
    await tester.ensureVisible(find.byType(TextFormField).at(1));
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pump();
    expect(find.text('Login failed'), findsOneWidget);
  });

  testWidgets('navigates to RegisterScreen on Sign Up tap', (tester) async {
    await pumpLoginScreen(tester);
    await tester.ensureVisible(find.text('Sign Up'));
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle(const Duration(milliseconds: 500));
    expect(find.byType(RegisterScreen), findsOneWidget);
  });
}
