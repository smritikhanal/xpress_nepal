import 'package:xpress_nepal/features/addresses/domain/entities/address_entity.dart';

/// Enum representing address operation status
enum AddressStatus { initial, loading, loaded, error }

/// Immutable state class for addresses
class AddressState {
  final AddressStatus status;
  final List<AddressEntity> addresses;
  final AddressEntity? selectedAddress;
  final String? errorMessage;
  final bool isLoading;

  const AddressState({
    this.status = AddressStatus.initial,
    this.addresses = const [],
    this.selectedAddress,
    this.errorMessage,
    this.isLoading = false,
  });

  /// Initial state
  factory AddressState.initial() =>
      const AddressState(status: AddressStatus.initial);

  /// Loading state
  factory AddressState.loading() =>
      const AddressState(status: AddressStatus.loading, isLoading: true);

  /// Loaded state with addresses
  factory AddressState.loaded(List<AddressEntity> addresses) =>
      AddressState(status: AddressStatus.loaded, addresses: addresses);

  /// Error state with message
  factory AddressState.error(String message) =>
      AddressState(status: AddressStatus.error, errorMessage: message);

  /// Get default address
  AddressEntity? get defaultAddress {
    try {
      return addresses.firstWhere((a) => a.isDefault);
    } catch (_) {
      return addresses.isNotEmpty ? addresses.first : null;
    }
  }

  /// Create a copy with updated values
  AddressState copyWith({
    AddressStatus? status,
    List<AddressEntity>? addresses,
    AddressEntity? selectedAddress,
    String? errorMessage,
    bool? isLoading,
  }) {
    return AddressState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      selectedAddress: selectedAddress ?? this.selectedAddress,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
