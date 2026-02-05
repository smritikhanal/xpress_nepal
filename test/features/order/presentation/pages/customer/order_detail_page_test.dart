
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xpress_nepal/features/order/domain/models/order_entity.dart';
import 'package:xpress_nepal/features/order/presentation/pages/customer/order_detail_page.dart';

void main() {
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

  testWidgets('renders all order details correctly', (tester) async {
    await tester.pumpWidget(MaterialApp(home: OrderDetailPage(order: tOrder)));
    await tester.pumpAndSettle();

    expect(find.textContaining('Order #12345678'), findsOneWidget);
    expect(find.text('PLACED'), findsOneWidget);
    expect(find.text('Product 1'), findsOneWidget);
    expect(find.text('2 x Rs. 100.0'), findsOneWidget);
    expect(find.text('Color: Red'), findsOneWidget);
    expect(find.text('Rs. 200'), findsWidgets); // One in item trailing, one in total
    expect(find.text('Test User'), findsOneWidget);
    expect(find.text('Street 1, Kathmandu'), findsOneWidget);
    expect(find.text('Method: COD'), findsOneWidget);
  });
}