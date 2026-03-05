import 'package:flutter/material.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/widgets/custom_button.dart';
import 'package:xpress_nepal/widgets/custom_text_field.dart';

class EditProductPage extends StatefulWidget {
  final ProductEntity product;

  const EditProductPage({Key? key, required this.product}) : super(key: key);

  @override
  State<EditProductPage> createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _discountPriceController;
  late TextEditingController _stockController;
  late TextEditingController _brandController;
  late TextEditingController _categoryController;
  final _attributeValueController = TextEditingController();
  final _attributePriceController = TextEditingController();

  late Map<String, List<AttributeOption>> _attributes;
  bool _isLoading = false;
  late bool _isActive;
  double? _priceAfterDiscount;

  final _productViewModel = ProductProvider.instance.productViewModel;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.product.title);
    _descriptionController = TextEditingController(
      text: widget.product.description,
    );
    _priceController = TextEditingController(
      text: widget.product.price.toString(),
    );
    // Pre-fill discount amount (price - discountPrice)
    final discountAmount =
        (widget.product.discountPrice != null &&
            widget.product.discountPrice! > 0 &&
            widget.product.discountPrice! < widget.product.price)
        ? (widget.product.price - widget.product.discountPrice!)
        : null;
    _discountPriceController = TextEditingController(
      text: discountAmount?.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    _brandController = TextEditingController(text: widget.product.brand ?? '');
    _categoryController = TextEditingController(
      text: widget.product.categoryId,
    );
    _isActive = widget.product.isActive;

    // Pre-fill attributes from existing product
    final existing = widget.product.attributes;
    _attributes = {
      'color': List<AttributeOption>.from(existing?.color ?? []),
      'size': List<AttributeOption>.from(existing?.size ?? []),
      'weight': List<AttributeOption>.from(existing?.weight ?? []),
    };

    _priceController.addListener(_updatePriceAfterDiscount);
    _discountPriceController.addListener(_updatePriceAfterDiscount);
    _updatePriceAfterDiscount();
  }

  void _updatePriceAfterDiscount() {
    final price = double.tryParse(_priceController.text);
    final discount = double.tryParse(_discountPriceController.text);
    setState(() {
      if (price != null &&
          discount != null &&
          discount > 0 &&
          discount <= price) {
        _priceAfterDiscount = price - discount;
      } else {
        _priceAfterDiscount = null;
      }
    });
  }

  @override
  void dispose() {
    _priceController.removeListener(_updatePriceAfterDiscount);
    _discountPriceController.removeListener(_updatePriceAfterDiscount);
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    _attributeValueController.dispose();
    _attributePriceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final double? price = double.tryParse(_priceController.text);
      final double? discountAmount = _discountPriceController.text.isNotEmpty
          ? double.tryParse(_discountPriceController.text)
          : null;
      final double? discountPrice =
          (discountAmount != null &&
              discountAmount > 0 &&
              discountAmount <= price!)
          ? price - discountAmount
          : null;
      final int? stock = int.tryParse(_stockController.text);

      if (price == null || stock == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please enter valid numbers'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              left: MediaQuery.of(context).size.width * 0.4,
              right: 8,
              bottom: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
        return;
      }

      // Filter out empty attribute lists
      final attributesToSend = <String, List<AttributeOption>>{};
      _attributes.forEach((key, value) {
        if (value.isNotEmpty) attributesToSend[key] = value;
      });

      final success = await _productViewModel.updateProduct(
        id: widget.product.id,
        title: _titleController.text,
        description: _descriptionController.text,
        price: price,
        discountPrice: discountPrice,
        categoryId: _categoryController.text.trim(),
        stock: stock,
        brand: _brandController.text.isNotEmpty ? _brandController.text : null,
        isActive: _isActive,
        attributes: attributesToSend.isNotEmpty ? attributesToSend : null,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Product updated successfully'),
              backgroundColor: AppColors.sellerPrimary,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.4,
                right: 8,
                bottom: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _productViewModel.state.errorMessage ?? 'Failed to update',
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                left: MediaQuery.of(context).size.width * 0.4,
                right: 8,
                bottom: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        backgroundColor: AppColors.sellerPrimaryDark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomTextField(
                controller: _titleController,
                labelText: 'Product Title',
                hintText: 'Enter title',
                focusColor: AppColors.sellerPrimary,
                validator: (v) =>
                    v?.isEmpty == true ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Enter description',
                maxLines: 4,
                focusColor: AppColors.sellerPrimary,
                validator: (v) =>
                    v?.isEmpty == true ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      labelText: 'Price',
                      hintText: '0.00',
                      keyboardType: TextInputType.number,
                      focusColor: AppColors.sellerPrimary,
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _discountPriceController,
                      labelText: 'Discount Amount',
                      hintText: 'Optional',
                      keyboardType: TextInputType.number,
                      focusColor: AppColors.sellerPrimary,
                    ),
                  ),
                ],
              ),
              if (_priceAfterDiscount != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.sellerPrimary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Price After Discount',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: AppColors.sellerPrimary,
                        ),
                      ),
                      Text(
                        'Rs. ${_priceAfterDiscount!.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppColors.sellerPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _stockController,
                      labelText: 'Stock',
                      hintText: '0',
                      keyboardType: TextInputType.number,
                      focusColor: AppColors.sellerPrimary,
                      validator: (v) => v?.isEmpty == true ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _brandController,
                      labelText: 'Brand',
                      hintText: 'Optional',
                      focusColor: AppColors.sellerPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _categoryController,
                labelText: 'Category ID',
                hintText: 'Enter Category ID',
                focusColor: AppColors.sellerPrimary,
                validator: (v) =>
                    v?.isEmpty == true ? 'Category ID is required' : null,
              ),
              const SizedBox(height: 16),

              // Attribute Fields (Color, Size, Weight)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Attributes',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: AppColors.sellerPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap + to add options. Tap × to remove.',
                      style: TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                    const SizedBox(height: 12),
                    _buildAttributeSection('Color', 'color'),
                    const Divider(),
                    _buildAttributeSection('Size', 'size'),
                    const Divider(),
                    _buildAttributeSection('Weight', 'weight'),
                  ],
                ),
              ),

              SwitchListTile(
                title: const Text('Active Status'),
                subtitle: const Text('Visible to customers'),
                value: _isActive,
                activeColor: AppColors.sellerPrimary,
                onChanged: (val) => setState(() => _isActive = val),
              ),

              const SizedBox(height: 24),
              CustomButton(
                text: 'Save Changes',
                onPressed: _handleSubmit,
                isLoading: _isLoading,
                color: AppColors.sellerPrimary,
                useGradient: false,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttributeSection(String label, String key) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
            IconButton(
              icon: const Icon(
                Icons.add_circle_outline,
                color: AppColors.sellerPrimary,
              ),
              onPressed: () => _showAddAttributeDialog(key, label),
            ),
          ],
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _attributes[key]!.map((option) {
            final priceInfo = option.priceModifier != 0
                ? ' (${option.priceModifier > 0 ? '+' : ''}${option.priceModifier.toStringAsFixed(0)})'
                : '';
            return Chip(
              label: Text('${option.value}$priceInfo'),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _attributes[key]!.remove(option);
                });
              },
              backgroundColor: AppColors.surfaceLight,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showAddAttributeDialog(String key, String label) {
    _attributeValueController.clear();
    _attributePriceController.text = '0';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add $label Option'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _attributeValueController,
              cursorColor: AppColors.sellerPrimary,
              decoration: const InputDecoration(
                labelText: 'Value',
                hintText: 'e.g. Red, XL, 1kg',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.sellerPrimary,
                    width: 2,
                  ),
                ),
                floatingLabelStyle: TextStyle(color: AppColors.sellerPrimary),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _attributePriceController,
              cursorColor: AppColors.sellerPrimary,
              decoration: const InputDecoration(
                labelText: 'Price Modifier',
                hintText: 'e.g. 50 (adds 50) or -50 (subtracts 50)',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.sellerPrimary,
                    width: 2,
                  ),
                ),
                floatingLabelStyle: TextStyle(color: AppColors.sellerPrimary),
                helperText: 'Enter 0 for no price change',
              ),
              keyboardType: const TextInputType.numberWithOptions(signed: true),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.sellerPrimary,
            ),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_attributeValueController.text.isNotEmpty) {
                final price =
                    double.tryParse(_attributePriceController.text) ?? 0.0;
                setState(() {
                  _attributes[key]!.add(
                    AttributeOption(
                      value: _attributeValueController.text.trim(),
                      priceModifier: price,
                    ),
                  );
                });
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sellerPrimary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
