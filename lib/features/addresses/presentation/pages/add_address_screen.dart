import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/addresses/domain/entities/address_entity.dart';
import 'package:xpress_nepal/features/addresses/presentation/providers/address_provider.dart';
import 'package:xpress_nepal/widgets/custom_text_field.dart';
import 'package:xpress_nepal/widgets/custom_button.dart';

class AddAddressScreen extends StatefulWidget {
  final AddressEntity? address;

  const AddAddressScreen({Key? key, this.address}) : super(key: key);

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _streetController = TextEditingController();
  final _postalCodeController = TextEditingController();

  late final _addressViewModel = AddressProvider.instance.addressViewModel;
  bool _isDefault = false;
  bool _isLoading = false;

  bool get isEditing => widget.address != null;

  @override
  void initState() {
    super.initState();
    _countryController.text = 'Nepal';

    if (widget.address != null) {
      _fullNameController.text = widget.address!.fullName;
      _phoneController.text = widget.address!.phone;
      _countryController.text = widget.address!.country;
      _stateController.text = widget.address!.state;
      _cityController.text = widget.address!.city;
      _streetController.text = widget.address!.street;
      _postalCodeController.text = widget.address!.postalCode ?? '';
      _isDefault = widget.address!.isDefault;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _streetController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter $fieldName';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Please enter a valid 10-digit phone number';
    }
    return null;
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    bool success;

    if (isEditing) {
      success = await _addressViewModel.updateAddress(
        addressId: widget.address!.id,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        country: _countryController.text.trim(),
        state: _stateController.text.trim(),
        city: _cityController.text.trim(),
        street: _streetController.text.trim(),
        postalCode: _postalCodeController.text.trim().isNotEmpty
            ? _postalCodeController.text.trim()
            : null,
        isDefault: _isDefault,
      );
    } else {
      success = await _addressViewModel.addAddress(
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        country: _countryController.text.trim(),
        state: _stateController.text.trim(),
        city: _cityController.text.trim(),
        street: _streetController.text.trim(),
        postalCode: _postalCodeController.text.trim().isNotEmpty
            ? _postalCodeController.text.trim()
            : null,
        isDefault: _isDefault,
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEditing
                  ? 'Address updated successfully'
                  : 'Address added successfully',
            ),
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _addressViewModel.errorMessage ?? 'Failed to save address',
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Address' : 'Add Address'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Full Name
              CustomTextField(
                controller: _fullNameController,
                hintText: 'Enter full name',
                labelText: 'Full Name *',
                validator: (v) => _validateRequired(v, 'full name'),
                prefixIcon: const Icon(
                  Icons.person_rounded,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 16),

              // Phone
              CustomTextField(
                controller: _phoneController,
                hintText: 'Enter phone number',
                labelText: 'Phone *',
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
                prefixIcon: const Icon(
                  Icons.phone_rounded,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 16),

              // Country
              CustomTextField(
                controller: _countryController,
                hintText: 'Enter country',
                labelText: 'Country *',
                validator: (v) => _validateRequired(v, 'country'),
                prefixIcon: const Icon(
                  Icons.public_rounded,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 16),

              // State/Province
              CustomTextField(
                controller: _stateController,
                hintText: 'Enter state/province',
                labelText: 'State/Province *',
                validator: (v) => _validateRequired(v, 'state/province'),
                prefixIcon: const Icon(
                  Icons.map_rounded,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 16),

              // City
              CustomTextField(
                controller: _cityController,
                hintText: 'Enter city',
                labelText: 'City *',
                validator: (v) => _validateRequired(v, 'city'),
                prefixIcon: const Icon(
                  Icons.location_city_rounded,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 16),

              // Street
              CustomTextField(
                controller: _streetController,
                hintText: 'Enter street address',
                labelText: 'Street Address *',
                validator: (v) => _validateRequired(v, 'street address'),
                prefixIcon: const Icon(
                  Icons.home_rounded,
                  color: AppColors.textHint,
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Postal Code
              CustomTextField(
                controller: _postalCodeController,
                hintText: 'Enter postal code (optional)',
                labelText: 'Postal Code',
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(
                  Icons.markunread_mailbox_rounded,
                  color: AppColors.textHint,
                ),
              ),
              const SizedBox(height: 16),

              // Default Address Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: _isDefault ? Colors.amber : AppColors.textHint,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Set as default address',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'This address will be selected by default',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: _isDefault,
                      onChanged: (value) => setState(() => _isDefault = value),
                      activeColor: AppColors.secondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              CustomButton(
                text: isEditing ? 'Update Address' : 'Save Address',
                onPressed: _handleSave,
                isLoading: _isLoading,
                color: AppColors.secondary,
                icon: Icons.save_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
