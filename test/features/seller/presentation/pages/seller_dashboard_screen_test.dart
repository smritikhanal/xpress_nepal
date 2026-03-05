import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xpress_nepal/features/auth/domain/entities/user_entity.dart';
import 'package:xpress_nepal/features/auth/presentation/providers/auth_provider.dart';
import 'package:xpress_nepal/features/auth/presentation/state/auth_state.dart';
import 'package:xpress_nepal/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:xpress_nepal/features/order/presentation/providers/order_provider.dart';
import 'package:xpress_nepal/features/order/presentation/state/order_state.dart';
import 'package:xpress_nepal/features/order/presentation/view_model/order_view_model.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/features/product/presentation/state/product_state.dart';
import 'package:xpress_nepal/features/product/presentation/view_model/product_view_model.dart';
import 'package:xpress_nepal/features/seller/presentation/pages/seller_dashboard_screen.dart';

class MockAuthViewModel extends Mock implements AuthViewModel {}

class MockAuthProvider extends Mock implements AuthProvider {}

class MockProductViewModel extends Mock implements ProductViewModel {}

class MockProductProvider extends Mock implements ProductProvider {}

class MockOrderViewModel extends Mock implements OrderViewModel {}

void main() {
  late MockAuthViewModel mockAuthViewModel;
  late MockAuthProvider mockAuthProvider;
  late MockProductViewModel mockProductViewModel;
  late MockProductProvider mockProductProvider;
  late MockOrderViewModel mockOrderViewModel;

  setUp(() {
    mockAuthViewModel = MockAuthViewModel();
    mockAuthProvider = MockAuthProvider();
    mockProductViewModel = MockProductViewModel();
    mockProductProvider = MockProductProvider();
    mockOrderViewModel = MockOrderViewModel();

    // Setup AuthProvider
    when(() => mockAuthProvider.authViewModel).thenReturn(mockAuthViewModel);
    AuthProvider.instance = mockAuthProvider;

    // Setup ProductProvider
    when(
      () => mockProductProvider.productViewModel,
    ).thenReturn(mockProductViewModel);
    ProductProvider.instance = mockProductProvider;

    // Setup OrderProvider
    OrderProvider.instance = mockOrderViewModel;

    // Default Stubs
    when(() => mockAuthViewModel.state).thenReturn(const AuthState());
    when(() => mockProductViewModel.state).thenReturn(ProductState());
    when(() => mockOrderViewModel.state).thenReturn(const OrderState());

    // Listeners (since ViewModels are ChangeNotifiers)
    when(() => mockProductViewModel.addListener(any())).thenReturn(null);
    when(() => mockProductViewModel.removeListener(any())).thenReturn(null);
    when(() => mockOrderViewModel.addListener(any())).thenReturn(null);
    when(() => mockOrderViewModel.removeListener(any())).thenReturn(null);

    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(600, 1200);
    binding.window.devicePixelRatioTestValue = 1.0;
  });

  tearDown(() {
    final TestWidgetsFlutterBinding binding =
        TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  Future<void> pumpSellerDashboard(WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SellerDashboardScreen()));
    await tester.pumpAndSettle();
  }

  testWidgets('renders common dashboard elements', (tester) async {
    // Arrange: Set up a user
    when(() => mockAuthViewModel.state).thenReturn(
      AuthState(
        user: UserEntity(
          id: '1',
          name: 'Test Seller',
          email: 'seller@test.com',
          role: 'seller',
        ),
      ),
    );

    // Act
    await pumpSellerDashboard(tester);

    // Assert
    expect(find.text('Test Seller'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Products'), findsWidgets); // One in stats, one in nav
    expect(find.text('Orders'), findsWidgets);
    expect(find.text('Revenue'), findsOneWidget);
    expect(find.text('Quick Actions'), findsOneWidget);
  });

  testWidgets('navigates to Products tab', (tester) async {
    await pumpSellerDashboard(tester);

    // There are 2 icons (Stats and BottomNav), tap the second one (BottomNav)
    await tester.tap(find.byIcon(Icons.inventory_2_rounded).at(1));
    await tester.pumpAndSettle();

    expect(find.text('Manage your product listings'), findsOneWidget);
  });
}
