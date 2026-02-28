import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xpress_nepal/features/addresses/domain/entities/address_entity.dart';
import 'package:xpress_nepal/features/addresses/presentation/pages/add_address_screen.dart';
import 'package:xpress_nepal/features/addresses/presentation/providers/address_provider.dart';
import 'package:xpress_nepal/features/addresses/presentation/view_model/address_view_model.dart';
import 'package:xpress_nepal/widgets/custom_button.dart';
import 'package:xpress_nepal/widgets/custom_text_field.dart';

class MockAddressViewModel extends Mock implements AddressViewModel {}

class MockAddressProvider extends Mock implements AddressProvider {}

void main() {
  late MockAddressViewModel mockAddressViewModel;
  late MockAddressProvider mockAddressProvider;

  setUp(() {
    mockAddressViewModel = MockAddressViewModel();
    mockAddressProvider = MockAddressProvider();

    when(
      () => mockAddressProvider.addressViewModel,
    ).thenReturn(mockAddressViewModel);
    AddressProvider.instance = mockAddressProvider;

    // Set a larger screen size for testing to avoid overflow
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

  Future<void> pumpAddAddressScreen(
    WidgetTester tester, {
    AddressEntity? address,
  }) async {
    await tester.pumpWidget(
      MaterialApp(home: AddAddressScreen(address: address)),
    );
    await tester.pumpAndSettle();
  }

  const tAddress = AddressEntity(
    id: '1',
    userId: 'u1',
    fullName: 'John Doe',
    phone: '9876543210',
    country: 'Nepal',
    state: 'Bagmati',
    city: 'Kathmandu',
    street: 'Thamel Street',
    postalCode: '44600',
    isDefault: true,
  );

  group('Add Address Screen - Rendering', () {
    testWidgets('renders all main widgets in add mode', (tester) async {
      await pumpAddAddressScreen(tester);

      expect(find.text('Add Address'), findsOneWidget);
      expect(find.text('Full Name *'), findsOneWidget);
      expect(find.text('Phone *'), findsOneWidget);
      expect(find.text('Country *'), findsOneWidget);
      expect(find.text('State/Province *'), findsOneWidget);
      expect(find.text('City *'), findsOneWidget);
      expect(find.text('Street Address *'), findsOneWidget);
      expect(find.text('Postal Code'), findsOneWidget);
      expect(find.text('Set as default address'), findsOneWidget);
      expect(find.widgetWithText(CustomButton, 'Save Address'), findsOneWidget);
    });

    testWidgets('renders all main widgets in edit mode', (tester) async {
      await pumpAddAddressScreen(tester, address: tAddress);

      expect(find.text('Edit Address'), findsOneWidget);
      expect(
        find.widgetWithText(CustomButton, 'Update Address'),
        findsOneWidget,
      );
    });

    testWidgets('pre-fills fields when editing address', (tester) async {
      await pumpAddAddressScreen(tester, address: tAddress);

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('9876543210'), findsOneWidget);
      expect(find.text('Nepal'), findsAtLeastNWidgets(1)); // Country field
      expect(find.text('Bagmati'), findsOneWidget);
      expect(find.text('Kathmandu'), findsOneWidget);
      expect(find.text('Thamel Street'), findsOneWidget);
      expect(find.text('44600'), findsOneWidget);

      // Check if default switch is on
      final switchWidget = tester.widget<Switch>(find.byType(Switch));
      expect(switchWidget.value, true);
    });

    testWidgets('default country is Nepal in add mode', (tester) async {
      await pumpAddAddressScreen(tester);

      final countryField = tester.widget<TextField>(
        find.ancestor(
          of: find.text('Enter country'),
          matching: find.byType(TextField),
        ),
      );
      expect(countryField.controller?.text, 'Nepal');
    });
  });

  group('Add Address Screen - Validation', () {
    testWidgets('shows validation errors for empty required fields', (
      tester,
    ) async {
      await pumpAddAddressScreen(tester);

      await tester.ensureVisible(
        find.widgetWithText(CustomButton, 'Save Address'),
      );
      await tester.tap(
        find.widgetWithText(CustomButton, 'Save Address'),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(find.text('Please enter full name'), findsOneWidget);
      expect(find.text('Please enter phone number'), findsOneWidget);
      // Country has default value of 'Nepal', so no validation error expected
      expect(find.text('Please enter state/province'), findsOneWidget);
      expect(find.text('Please enter city'), findsOneWidget);
      expect(find.text('Please enter street address'), findsOneWidget);
    });

    testWidgets('shows validation error for invalid phone number', (
      tester,
    ) async {
      await pumpAddAddressScreen(tester);

      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Phone *'),
        '123',
      );
      await tester.ensureVisible(
        find.widgetWithText(CustomButton, 'Save Address'),
      );
      await tester.tap(
        find.widgetWithText(CustomButton, 'Save Address'),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(
        find.text('Please enter a valid 10-digit phone number'),
        findsOneWidget,
      );
    });

    testWidgets('shows validation error for non-numeric phone', (tester) async {
      await pumpAddAddressScreen(tester);

      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Phone *'),
        'abc1234567',
      );
      await tester.ensureVisible(
        find.widgetWithText(CustomButton, 'Save Address'),
      );
      await tester.tap(
        find.widgetWithText(CustomButton, 'Save Address'),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(
        find.text('Please enter a valid 10-digit phone number'),
        findsOneWidget,
      );
    });

    testWidgets('accepts valid 10-digit phone number', (tester) async {
      when(
        () => mockAddressViewModel.addAddress(
          fullName: any(named: 'fullName'),
          phone: any(named: 'phone'),
          country: any(named: 'country'),
          state: any(named: 'state'),
          city: any(named: 'city'),
          street: any(named: 'street'),
          postalCode: any(named: 'postalCode'),
          isDefault: any(named: 'isDefault'),
        ),
      ).thenAnswer((_) async => true);

      await pumpAddAddressScreen(tester);

      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Full Name *'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Phone *'),
        '9876543210',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'State/Province *'),
        'Test State',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'City *'),
        'Test City',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Street Address *'),
        'Test Street',
      );

      await tester.ensureVisible(
        find.widgetWithText(CustomButton, 'Save Address'),
      );
      await tester.tap(
        find.widgetWithText(CustomButton, 'Save Address'),
        warnIfMissed: false,
      );
      await tester.pump();

      expect(
        find.text('Please enter a valid 10-digit phone number'),
        findsNothing,
      );
    });
  });

  group('Add Address Screen - Toggle Default', () {
    testWidgets('toggles default address switch', (tester) async {
      await pumpAddAddressScreen(tester);

      final switchFinder = find.byType(Switch);
      Switch switchWidget = tester.widget(switchFinder);
      expect(switchWidget.value, false);

      await tester.tap(switchFinder);
      await tester.pump();

      switchWidget = tester.widget(switchFinder);
      expect(switchWidget.value, true);
    });

    testWidgets('default switch reflects edit mode value', (tester) async {
      await pumpAddAddressScreen(tester, address: tAddress);

      final switchFinder = find.byType(Switch);
      final switchWidget = tester.widget<Switch>(switchFinder);
      expect(switchWidget.value, true);
    });
  });

  group('Add Address Screen - Add Operation', () {
    testWidgets('calls addAddress with correct parameters', (tester) async {
      when(
        () => mockAddressViewModel.addAddress(
          fullName: any(named: 'fullName'),
          phone: any(named: 'phone'),
          country: any(named: 'country'),
          state: any(named: 'state'),
          city: any(named: 'city'),
          street: any(named: 'street'),
          postalCode: any(named: 'postalCode'),
          isDefault: any(named: 'isDefault'),
        ),
      ).thenAnswer((_) async => true);

      await pumpAddAddressScreen(tester);

      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Full Name *'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Phone *'),
        '9876543210',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Country *'),
        'Nepal',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'State/Province *'),
        'Bagmati',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'City *'),
        'Kathmandu',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Street Address *'),
        'Test Street',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Postal Code'),
        '44600',
      );

      await tester.ensureVisible(
        find.widgetWithText(CustomButton, 'Save Address'),
      );
      await tester.tap(
        find.widgetWithText(CustomButton, 'Save Address'),
        warnIfMissed: false,
      );
      await tester.pump();

      verify(
        () => mockAddressViewModel.addAddress(
          fullName: 'Test User',
          phone: '9876543210',
          country: 'Nepal',
          state: 'Bagmati',
          city: 'Kathmandu',
          street: 'Test Street',
          postalCode: '44600',
          isDefault: false,
        ),
      ).called(1);
    });

    testWidgets('shows success message on successful add', (tester) async {
      when(
        () => mockAddressViewModel.addAddress(
          fullName: any(named: 'fullName'),
          phone: any(named: 'phone'),
          country: any(named: 'country'),
          state: any(named: 'state'),
          city: any(named: 'city'),
          street: any(named: 'street'),
          postalCode: any(named: 'postalCode'),
          isDefault: any(named: 'isDefault'),
        ),
      ).thenAnswer((_) async => true);

      await pumpAddAddressScreen(tester);

      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Full Name *'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Phone *'),
        '9876543210',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'State/Province *'),
        'Test State',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'City *'),
        'Test City',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Street Address *'),
        'Test Street',
      );

      await tester.ensureVisible(
        find.widgetWithText(CustomButton, 'Save Address'),
      );
      await tester.tap(
        find.widgetWithText(CustomButton, 'Save Address'),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Address added successfully'), findsOneWidget);
    });

    testWidgets('shows error message on failed add', (tester) async {
      when(
        () => mockAddressViewModel.addAddress(
          fullName: any(named: 'fullName'),
          phone: any(named: 'phone'),
          country: any(named: 'country'),
          state: any(named: 'state'),
          city: any(named: 'city'),
          street: any(named: 'street'),
          postalCode: any(named: 'postalCode'),
          isDefault: any(named: 'isDefault'),
        ),
      ).thenAnswer((_) async => false);
      when(
        () => mockAddressViewModel.errorMessage,
      ).thenReturn('Failed to add address');

      await pumpAddAddressScreen(tester);

      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Full Name *'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Phone *'),
        '9876543210',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'State/Province *'),
        'Test State',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'City *'),
        'Test City',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Street Address *'),
        'Test Street',
      );

      await tester.ensureVisible(
        find.widgetWithText(CustomButton, 'Save Address'),
      );
      await tester.tap(
        find.widgetWithText(CustomButton, 'Save Address'),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Failed to add address'), findsOneWidget);
    });

    testWidgets('handles null postal code correctly', (tester) async {
      when(
        () => mockAddressViewModel.addAddress(
          fullName: any(named: 'fullName'),
          phone: any(named: 'phone'),
          country: any(named: 'country'),
          state: any(named: 'state'),
          city: any(named: 'city'),
          street: any(named: 'street'),
          postalCode: any(named: 'postalCode'),
          isDefault: any(named: 'isDefault'),
        ),
      ).thenAnswer((_) async => true);

      await pumpAddAddressScreen(tester);

      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Full Name *'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Phone *'),
        '9876543210',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'State/Province *'),
        'Test State',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'City *'),
        'Test City',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Street Address *'),
        'Test Street',
      );

      await tester.ensureVisible(
        find.widgetWithText(CustomButton, 'Save Address'),
      );
      await tester.tap(
        find.widgetWithText(CustomButton, 'Save Address'),
        warnIfMissed: false,
      );
      await tester.pump();

      verify(
        () => mockAddressViewModel.addAddress(
          fullName: 'Test User',
          phone: '9876543210',
          country: 'Nepal',
          state: 'Test State',
          city: 'Test City',
          street: 'Test Street',
          postalCode: null,
          isDefault: false,
        ),
      ).called(1);
    });

    testWidgets('passes isDefault value correctly', (tester) async {
      when(
        () => mockAddressViewModel.addAddress(
          fullName: any(named: 'fullName'),
          phone: any(named: 'phone'),
          country: any(named: 'country'),
          state: any(named: 'state'),
          city: any(named: 'city'),
          street: any(named: 'street'),
          postalCode: any(named: 'postalCode'),
          isDefault: any(named: 'isDefault'),
        ),
      ).thenAnswer((_) async => true);

      await pumpAddAddressScreen(tester);

      // Toggle default switch on
      await tester.tap(find.byType(Switch));
      await tester.pump();

      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Full Name *'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Phone *'),
        '9876543210',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'State/Province *'),
        'Test State',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'City *'),
        'Test City',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Street Address *'),
        'Test Street',
      );

      await tester.ensureVisible(
        find.widgetWithText(CustomButton, 'Save Address'),
      );
      await tester.tap(
        find.widgetWithText(CustomButton, 'Save Address'),
        warnIfMissed: false,
      );
      await tester.pump();

      verify(
        () => mockAddressViewModel.addAddress(
          fullName: 'Test User',
          phone: '9876543210',
          country: 'Nepal',
          state: 'Test State',
          city: 'Test City',
          street: 'Test Street',
          postalCode: null,
          isDefault: true,
        ),
      ).called(1);
    });
  });

  group('Add Address Screen - Update Operation', () {
    testWidgets('calls updateAddress with correct parameters', (tester) async {
      when(
        () => mockAddressViewModel.updateAddress(
          addressId: any(named: 'addressId'),
          fullName: any(named: 'fullName'),
          phone: any(named: 'phone'),
          country: any(named: 'country'),
          state: any(named: 'state'),
          city: any(named: 'city'),
          street: any(named: 'street'),
          postalCode: any(named: 'postalCode'),
          isDefault: any(named: 'isDefault'),
        ),
      ).thenAnswer((_) async => true);

      await pumpAddAddressScreen(tester, address: tAddress);

      // Modify some fields
      final fullNameField = find.widgetWithText(CustomTextField, 'Full Name *');
      await tester.enterText(fullNameField, 'Updated Name');

      final phoneField = find.widgetWithText(CustomTextField, 'Phone *');
      await tester.enterText(phoneField, '1234567890');

      await tester.ensureVisible(
        find.widgetWithText(CustomButton, 'Update Address'),
      );
      await tester.tap(
        find.widgetWithText(CustomButton, 'Update Address'),
        warnIfMissed: false,
      );
      await tester.pump();

      verify(
        () => mockAddressViewModel.updateAddress(
          addressId: '1',
          fullName: 'Updated Name',
          phone: '1234567890',
          country: 'Nepal',
          state: 'Bagmati',
          city: 'Kathmandu',
          street: 'Thamel Street',
          postalCode: '44600',
          isDefault: true,
        ),
      ).called(1);
    });

    testWidgets('shows success message on successful update', (tester) async {
      when(
        () => mockAddressViewModel.updateAddress(
          addressId: any(named: 'addressId'),
          fullName: any(named: 'fullName'),
          phone: any(named: 'phone'),
          country: any(named: 'country'),
          state: any(named: 'state'),
          city: any(named: 'city'),
          street: any(named: 'street'),
          postalCode: any(named: 'postalCode'),
          isDefault: any(named: 'isDefault'),
        ),
      ).thenAnswer((_) async => true);

      await pumpAddAddressScreen(tester, address: tAddress);

      await tester.ensureVisible(
        find.widgetWithText(CustomButton, 'Update Address'),
      );
      await tester.tap(
        find.widgetWithText(CustomButton, 'Update Address'),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Address updated successfully'), findsOneWidget);
    });

    testWidgets('shows error message on failed update', (tester) async {
      when(
        () => mockAddressViewModel.updateAddress(
          addressId: any(named: 'addressId'),
          fullName: any(named: 'fullName'),
          phone: any(named: 'phone'),
          country: any(named: 'country'),
          state: any(named: 'state'),
          city: any(named: 'city'),
          street: any(named: 'street'),
          postalCode: any(named: 'postalCode'),
          isDefault: any(named: 'isDefault'),
        ),
      ).thenAnswer((_) async => false);
      when(
        () => mockAddressViewModel.errorMessage,
      ).thenReturn('Failed to update address');

      await pumpAddAddressScreen(tester, address: tAddress);

      await tester.ensureVisible(
        find.widgetWithText(CustomButton, 'Update Address'),
      );
      await tester.tap(
        find.widgetWithText(CustomButton, 'Update Address'),
        warnIfMissed: false,
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Failed to update address'), findsOneWidget);
    });
  });

  group('Add Address Screen - Navigation', () {
    testWidgets('pops with true result on successful add', (tester) async {
      when(
        () => mockAddressViewModel.addAddress(
          fullName: any(named: 'fullName'),
          phone: any(named: 'phone'),
          country: any(named: 'country'),
          state: any(named: 'state'),
          city: any(named: 'city'),
          street: any(named: 'street'),
          postalCode: any(named: 'postalCode'),
          isDefault: any(named: 'isDefault'),
        ),
      ).thenAnswer((_) async => true);

      bool? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AddAddressScreen(),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Full Name *'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Phone *'),
        '9876543210',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'State/Province *'),
        'Test State',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'City *'),
        'Test City',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Street Address *'),
        'Test Street',
      );

      await tester.ensureVisible(
        find.widgetWithText(CustomButton, 'Save Address'),
      );
      await tester.tap(
        find.widgetWithText(CustomButton, 'Save Address'),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      expect(result, true);
      expect(find.text('Open'), findsOneWidget); // Back to original screen
    });

    testWidgets('does not pop on failed add', (tester) async {
      when(
        () => mockAddressViewModel.addAddress(
          fullName: any(named: 'fullName'),
          phone: any(named: 'phone'),
          country: any(named: 'country'),
          state: any(named: 'state'),
          city: any(named: 'city'),
          street: any(named: 'street'),
          postalCode: any(named: 'postalCode'),
          isDefault: any(named: 'isDefault'),
        ),
      ).thenAnswer((_) async => false);
      when(() => mockAddressViewModel.errorMessage).thenReturn('Failed');

      await pumpAddAddressScreen(tester);

      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Full Name *'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Phone *'),
        '9876543210',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'State/Province *'),
        'Test State',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'City *'),
        'Test City',
      );
      await tester.enterText(
        find.widgetWithText(CustomTextField, 'Street Address *'),
        'Test Street',
      );

      await tester.ensureVisible(
        find.widgetWithText(CustomButton, 'Save Address'),
      );
      await tester.tap(
        find.widgetWithText(CustomButton, 'Save Address'),
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();

      // Should still be on the same screen
      expect(find.text('Add Address'), findsOneWidget);
    });
  });
}
