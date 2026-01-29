
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:xpress_nepal/features/order/domain/models/order_entity.dart';
import 'package:xpress_nepal/features/order/presentation/pages/seller/seller_order_detail_page.dart';
import 'package:xpress_nepal/features/order/presentation/view_model/order_view_model.dart';

class MockOrderViewModel extends Mock implements OrderViewModel {}

void main() {
  late MockOrderViewModel mockOrderViewModel;

  setUp(() {
    mockOrderViewModel = MockOrderViewModel();
    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1200, 2400);
    binding.window.devicePixelRatioTestValue = 1.0;
  });

  tearDown(() {
    final TestWidgetsFlutterBinding binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.clearPhysicalSizeTestValue();
    binding.window.clearDevicePixelRatioTestValue();
  });

  final tAddress = ShippingAddressEntity(
    fullName: 'Test User',
    phone: '1234567890',
    country: 'Nepal',
    state: 'Bagmati',
    city: 'Kathmandu',
    street: 'Street 1',
  );

  final tOrder = OrderEntity(
    id: 'order12345678',
    userId: 'u1',
    items: [
      OrderItemEntity(
        title: 'Product 1',
        price: 100.0,
        quantity: 2,
        productId: 'p1',
        attributes: {'Color': 'Red'},
      ),
    ],
    shippingAddress: tAddress,
    paymentMethod: 'COD',
    paymentStatus: 'pending',
    orderStatus: 'placed',
    totalAmount: 200.0,
    createdAt: DateTime.now(),
  );

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider<OrderViewModel>.value(
          value: mockOrderViewModel,
          child: SellerOrderDetailPage(order: tOrder),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('renders all seller order details correctly', (tester) async {
    await pumpPage(tester);

    expect(find.textContaining('Order #12345678'), findsOneWidget);
    expect(find.text('PLACED'), findsOneWidget);
    expect(find.text('Product 1'), findsOneWidget);
    expect(find.text('2 x Rs. 100.0'), findsOneWidget);
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('Update Order Status'), findsOneWidget);
  });

  testWidgets('shows status update dialog on button press', (tester) async {
    await pumpPage(tester);

    await tester.ensureVisible(find.text('Update Order Status'));
    await tester.tap(find.text('Update Order Status'));
    await tester.pumpAndSettle();

    expect(find.text('Update Order Status'), findsWidgets); // Title in dialog
    expect(find.text('CONFIRMED'), findsOneWidget);
    expect(find.text('SHIPPED'), findsOneWidget);
  });
}