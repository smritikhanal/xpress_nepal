import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/addresses/domain/entities/address_entity.dart';
import 'package:xpress_nepal/features/addresses/presentation/providers/address_provider.dart';
import 'package:xpress_nepal/features/addresses/presentation/pages/add_address_screen.dart';
import 'package:xpress_nepal/features/addresses/presentation/widgets/address_card.dart';

class AddressListScreen extends StatefulWidget {
  final bool selectionMode;

  const AddressListScreen({Key? key, this.selectionMode = false})
    : super(key: key);

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  late final _addressViewModel = AddressProvider.instance.addressViewModel;

  @override
  void initState() {
    super.initState();
    _addressViewModel.addListener(_onStateChange);
    _addressViewModel.fetchAddresses();
  }

  @override
  void dispose() {
    _addressViewModel.removeListener(_onStateChange);
    super.dispose();
  }

  void _onStateChange() {
    if (mounted) setState(() {});
  }

  Future<void> _navigateToAddAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddAddressScreen()),
    );

    if (result == true) {
      _addressViewModel.fetchAddresses();
    }
  }

  Future<void> _navigateToEditAddress(AddressEntity address) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddAddressScreen(address: address),
      ),
    );

    if (result == true) {
      _addressViewModel.fetchAddresses();
    }
  }

  Future<void> _deleteAddress(AddressEntity address) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await _addressViewModel.deleteAddress(address.id);
      if (mounted && success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Address deleted successfully')),
        );
      }
    }
  }

  void _selectAddress(AddressEntity address) {
    if (widget.selectionMode) {
      Navigator.pop(context, address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectionMode ? 'Select Address' : 'My Addresses'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddAddress,
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: AppColors.textLight),
      ),
    );
  }

  Widget _buildBody() {
    if (_addressViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_addressViewModel.addresses.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _addressViewModel.fetchAddresses(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _addressViewModel.addresses.length,
        itemBuilder: (context, index) {
          final address = _addressViewModel.addresses[index];
          return AddressCard(
            address: address,
            onTap: () => _selectAddress(address),
            onEdit: () => _navigateToEditAddress(address),
            onDelete: () => _deleteAddress(address),
            onSetDefault: () => _addressViewModel.setDefaultAddress(address.id),
            showActions: !widget.selectionMode,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off_rounded,
            size: 80,
            color: AppColors.textHint.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No addresses yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your first shipping address',
            style: TextStyle(fontSize: 14, color: AppColors.textHint),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddAddress,
            icon: const Icon(Icons.add),
            label: const Text('Add Address'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.textLight,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}
