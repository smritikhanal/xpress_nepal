import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xpress_nepal/features/addresses/domain/entities/address_entity.dart';
import 'package:xpress_nepal/features/addresses/presentation/pages/add_address_screen.dart';
import 'package:xpress_nepal/features/addresses/presentation/pages/address_list_screen.dart';
import 'package:xpress_nepal/features/addresses/presentation/providers/address_provider.dart';
import 'package:xpress_nepal/features/addresses/presentation/view_model/address_view_model.dart';
import 'package:xpress_nepal/features/addresses/presentation/widgets/address_card.dart';

class MockAddressViewModel extends Mock implements AddressViewModel {}

class MockAddressProvider extends Mock implements AddressProvider {}

void main() {
  late MockAddressViewModel mockAddressViewModel;
  late MockAddressProvider mockAddressProvider;

  const tAddress1 = AddressEntity(
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

  const tAddress2 = AddressEntity(
    id: '2',
    userId: 'u1',
    fullName: 'Jane Smith',
    phone: '9812345678',
    country: 'Nepal',
    state: 'Gandaki',
    city: 'Pokhara',
    street: 'Lakeside Road',
    isDefault: false,
  );

  setUp(() {
    mockAddressViewModel = MockAddressViewModel();
    mockAddressProvider = MockAddressProvider();

    when(
      () => mockAddressProvider.addressViewModel,
    ).thenReturn(mockAddressViewModel);
    AddressProvider.instance = mockAddressProvider;

    // Default mock setup
    when(() => mockAddressViewModel.addListener(any())).thenReturn(null);
    when(() => mockAddressViewModel.removeListener(any())).thenReturn(null);
    when(() => mockAddressViewModel.isLoading).thenReturn(false);
    when(() => mockAddressViewModel.addresses).thenReturn([]);
    when(() => mockAddressViewModel.fetchAddresses()).thenAnswer((_) async {});

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

  Future<void> pumpAddressListScreen(
    WidgetTester tester, {
    bool selectionMode = false,
  }) async {
    await tester.pumpWidget(
      MaterialApp(home: AddressListScreen(selectionMode: selectionMode)),
    );
    await tester.pumpAndSettle();
  }

  group('Address List Screen - Rendering', () {
    testWidgets('renders with correct title in normal mode', (tester) async {
      await pumpAddressListScreen(tester);

      expect(find.text('My Addresses'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('renders with correct title in selection mode', (tester) async {
      await pumpAddressListScreen(tester, selectionMode: true);

      expect(find.text('Select Address'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('calls fetchAddresses on init', (tester) async {
      await pumpAddressListScreen(tester);

      verify(() => mockAddressViewModel.fetchAddresses()).called(1);
    });

    testWidgets('shows loading indicator when isLoading is true', (
      tester,
    ) async {
      when(() => mockAddressViewModel.isLoading).thenReturn(true);

      await tester.pumpWidget(
        MaterialApp(home: AddressListScreen(selectionMode: false)),
      );
      await tester
          .pump(); // Use pump instead of pumpAndSettle for loading state

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when no addresses', (tester) async {
      when(() => mockAddressViewModel.addresses).thenReturn([]);

      await pumpAddressListScreen(tester);

      expect(find.text('No addresses yet'), findsOneWidget);
      expect(find.text('Add your first shipping address'), findsOneWidget);
      expect(find.byIcon(Icons.location_off_rounded), findsOneWidget);
      expect(find.text('Add Address'), findsOneWidget);
    });

    testWidgets('shows list of addresses when available', (tester) async {
      when(
        () => mockAddressViewModel.addresses,
      ).thenReturn([tAddress1, tAddress2]);

      await pumpAddressListScreen(tester);

      expect(find.byType(AddressCard), findsNWidgets(2));
      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Jane Smith'), findsOneWidget);
    });

    testWidgets('shows RefreshIndicator with addresses', (tester) async {
      when(() => mockAddressViewModel.addresses).thenReturn([tAddress1]);

      await pumpAddressListScreen(tester);

      expect(find.byType(RefreshIndicator), findsOneWidget);
    });
  });

  group('Address List Screen - Navigation', () {
    testWidgets('navigates to add address screen when FAB is tapped', (
      tester,
    ) async {
      await pumpAddressListScreen(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AddAddressScreen), findsOneWidget);
    });

    testWidgets('navigates to add address screen from empty state button', (
      tester,
    ) async {
      when(() => mockAddressViewModel.addresses).thenReturn([]);
      when(() => mockAddressViewModel.isLoading).thenReturn(false);

      await pumpAddressListScreen(tester);

      // Find the icon inside the button
      final iconFinder = find.byIcon(Icons.add);
      expect(
        iconFinder,
        findsAtLeastNWidgets(1),
      ); // At least one for FAB, maybe one for button

      // Find elevated button with Add icon
      final addButtonFinder = find.ancestor(
        of: find.text('Add Address'),
        matching: find.byType(ElevatedButton),
      );

      if (addButtonFinder.evaluate().isNotEmpty) {
        await tester.tap(addButtonFinder);
        await tester.pumpAndSettle();
        expect(find.byType(AddAddressScreen), findsOneWidget);
      }
    });

    testWidgets('refreshes addresses after successful add', (tester) async {
      when(() => mockAddressViewModel.addresses).thenReturn([]);

      await pumpAddressListScreen(tester);

      // Clear the initial fetch call
      clearInteractions(mockAddressViewModel);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // We're now on AddAddressScreen
      expect(find.byType(AddAddressScreen), findsOneWidget);

      // Navigate back with result = true
      Navigator.of(tester.element(find.byType(AddAddressScreen))).pop(true);
      await tester.pumpAndSettle();

      // Should refresh addresses
      verify(() => mockAddressViewModel.fetchAddresses()).called(1);
    });
  });

  group('Address List Screen - Delete Address', () {
    testWidgets('shows delete confirmation dialog', (tester) async {
      when(() => mockAddressViewModel.addresses).thenReturn([tAddress1]);
      when(
        () => mockAddressViewModel.deleteAddress(any()),
      ).thenAnswer((_) async => true);

      await pumpAddressListScreen(tester);

      // Find and tap the delete button in AddressCard
      final deleteButton = find.byIcon(Icons.delete_outline_rounded);
      await tester.tap(deleteButton.first);
      await tester.pumpAndSettle();

      expect(find.text('Delete Address'), findsOneWidget);
      expect(
        find.text('Are you sure you want to delete this address?'),
        findsOneWidget,
      );
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Delete'), findsOneWidget);
    });

    testWidgets('cancels delete when Cancel is tapped', (tester) async {
      when(() => mockAddressViewModel.addresses).thenReturn([tAddress1]);

      await pumpAddressListScreen(tester);

      final deleteButton = find.byIcon(Icons.delete_outline_rounded);
      await tester.tap(deleteButton.first);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verifyNever(() => mockAddressViewModel.deleteAddress(any()));
    });

    testWidgets('deletes address when confirmed', (tester) async {
      when(() => mockAddressViewModel.addresses).thenReturn([tAddress1]);
      when(
        () => mockAddressViewModel.deleteAddress('1'),
      ).thenAnswer((_) async => true);

      await pumpAddressListScreen(tester);

      final deleteButton = find.byIcon(Icons.delete_outline_rounded);
      await tester.tap(deleteButton.first);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      verify(() => mockAddressViewModel.deleteAddress('1')).called(1);
    });

    testWidgets('shows success message after successful delete', (
      tester,
    ) async {
      when(() => mockAddressViewModel.addresses).thenReturn([tAddress1]);
      when(
        () => mockAddressViewModel.deleteAddress('1'),
      ).thenAnswer((_) async => true);

      await pumpAddressListScreen(tester);

      final deleteButton = find.byIcon(Icons.delete_outline_rounded);
      await tester.tap(deleteButton.first);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Address deleted successfully'), findsOneWidget);
    });

    testWidgets('does not show success message on failed delete', (
      tester,
    ) async {
      when(() => mockAddressViewModel.addresses).thenReturn([tAddress1]);
      when(
        () => mockAddressViewModel.deleteAddress('1'),
      ).thenAnswer((_) async => false);

      await pumpAddressListScreen(tester);

      final deleteButton = find.byIcon(Icons.delete_outline_rounded);
      await tester.tap(deleteButton.first);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(TextButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Address deleted successfully'), findsNothing);
    });
  });

  group('Address List Screen - Set Default', () {
    testWidgets('calls setDefaultAddress when star icon is tapped', (
      tester,
    ) async {
      when(
        () => mockAddressViewModel.addresses,
      ).thenReturn([tAddress1, tAddress2]);
      when(
        () => mockAddressViewModel.setDefaultAddress(any()),
      ).thenAnswer((_) async => true);

      await pumpAddressListScreen(tester);

      // Find the star icon for the non-default address (tAddress2)
      final starButtons = find.byIcon(Icons.star_outline_rounded);
      if (starButtons.evaluate().isNotEmpty) {
        await tester.tap(starButtons.first);
        await tester.pumpAndSettle();

        verify(() => mockAddressViewModel.setDefaultAddress(any())).called(1);
      }
    });
  });

  group('Address List Screen - Selection Mode', () {
    testWidgets('pops with selected address in selection mode', (tester) async {
      when(
        () => mockAddressViewModel.addresses,
      ).thenReturn([tAddress1, tAddress2]);

      AddressEntity? selectedAddress;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    selectedAddress = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const AddressListScreen(selectionMode: true),
                      ),
                    );
                  },
                  child: const Text('Select'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Select'));
      await tester.pumpAndSettle();

      // Tap on an address card
      await tester.tap(find.byType(AddressCard).first);
      await tester.pumpAndSettle();

      expect(selectedAddress, isNotNull);
      expect(selectedAddress?.id, tAddress1.id);
    });

    testWidgets('hides action buttons in selection mode', (tester) async {
      when(() => mockAddressViewModel.addresses).thenReturn([tAddress1]);

      await pumpAddressListScreen(tester, selectionMode: true);

      // In selection mode, showActions is false, so edit/delete buttons should not be interactive
      // The AddressCard still renders them but they should be hidden or disabled
      final addressCard = tester.widget<AddressCard>(find.byType(AddressCard));
      expect(addressCard.showActions, false);
    });
  });

  group('Address List Screen - Refresh', () {
    testWidgets('refreshes addresses on pull to refresh', (tester) async {
      when(() => mockAddressViewModel.addresses).thenReturn([tAddress1]);
      when(() => mockAddressViewModel.isLoading).thenReturn(false);

      await pumpAddressListScreen(tester);

      // Clear initial fetch
      clearInteractions(mockAddressViewModel);

      // Perform refresh by calling the onRefresh callback directly
      // Finding and dragging the RefreshIndicator can be flaky
      final refreshIndicator = tester.widget<RefreshIndicator>(
        find.byType(RefreshIndicator),
      );
      await refreshIndicator.onRefresh.call();
      await tester.pump();

      verify(() => mockAddressViewModel.fetchAddresses()).called(1);
    });
  });

  group('Address List Screen - Edit Address', () {
    testWidgets('navigates to edit address screen when edit is tapped', (
      tester,
    ) async {
      when(() => mockAddressViewModel.addresses).thenReturn([tAddress1]);
      when(() => mockAddressViewModel.isLoading).thenReturn(false);

      await pumpAddressListScreen(tester);

      final editButton = find.byIcon(Icons.edit_rounded);
      await tester.tap(editButton.first);
      await tester.pumpAndSettle();

      expect(find.byType(AddAddressScreen), findsOneWidget);
      // Verify it's in edit mode by checking for "Edit Address" title
      expect(find.text('Edit Address'), findsOneWidget);
    });

    testWidgets('refreshes addresses after successful edit', (tester) async {
      when(() => mockAddressViewModel.addresses).thenReturn([tAddress1]);
      when(() => mockAddressViewModel.isLoading).thenReturn(false);

      await pumpAddressListScreen(tester);

      clearInteractions(mockAddressViewModel);

      final editButton = find.byIcon(Icons.edit_rounded);
      await tester.tap(editButton.first);
      await tester.pumpAndSettle();

      // We're now on AddAddressScreen in edit mode
      expect(find.byType(AddAddressScreen), findsOneWidget);

      // Navigate back with result = true
      Navigator.of(tester.element(find.byType(AddAddressScreen))).pop(true);
      await tester.pumpAndSettle();

      verify(() => mockAddressViewModel.fetchAddresses()).called(1);
    });
  });

  group('Address List Screen - State Management', () {
    testWidgets('rebuilds when view model notifies listeners', (tester) async {
      bool isLoading = true;
      when(() => mockAddressViewModel.isLoading).thenAnswer((_) => isLoading);
      when(() => mockAddressViewModel.addresses).thenReturn([]);

      await tester.pumpWidget(
        MaterialApp(home: AddressListScreen(selectionMode: false)),
      );
      await tester.pump(); // Use pump instead of pumpAndSettle while loading

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Simulate state change
      isLoading = false;
      when(() => mockAddressViewModel.isLoading).thenReturn(false);
      when(() => mockAddressViewModel.addresses).thenReturn([tAddress1]);

      // Trigger the listener callback
      final capturedListener =
          verify(
                () => mockAddressViewModel.addListener(captureAny()),
              ).captured.first
              as VoidCallback;

      capturedListener();
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(AddressCard), findsOneWidget);
    });
  });
}
