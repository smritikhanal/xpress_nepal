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

  bool _isLoading = false;
  late bool _isActive;

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
    _discountPriceController = TextEditingController(
      text: widget.product.discountPrice?.toString() ?? '',
    );
    _stockController = TextEditingController(
      text: widget.product.stock.toString(),
    );
    _brandController = TextEditingController(text: widget.product.brand ?? '');
    _categoryController = TextEditingController(
      text: widget.product.categoryId,
    );
    _isActive = widget.product.isActive;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final double? price = double.tryParse(_priceController.text);
      final double? discountPrice = _discountPriceController.text.isNotEmpty
          ? double.tryParse(_discountPriceController.text)
          : null;
      final int? stock = int.tryParse(_stockController.text);

      if (price == null || stock == null) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid numbers')),
        );
        return;
      }

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
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully')),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _productViewModel.state.errorMessage ?? 'Failed to update',
              ),
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
                      labelText: 'Discount Price',
                      hintText: 'Optional',
                      keyboardType: TextInputType.number,
                      focusColor: AppColors.sellerPrimary,
                    ),
                  ),
                ],
              ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
