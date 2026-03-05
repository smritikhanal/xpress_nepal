import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:xpress_nepal/app/theme/app_colors.dart';
import 'package:xpress_nepal/features/category/domain/entities/category_entity.dart';
import 'package:xpress_nepal/features/category/presentation/providers/category_provider.dart';
import 'package:xpress_nepal/features/product/presentation/providers/product_provider.dart';
import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';
import 'package:xpress_nepal/widgets/custom_button.dart';
import 'package:xpress_nepal/widgets/custom_text_field.dart';

class CreateProductPage extends StatefulWidget {
  const CreateProductPage({Key? key}) : super(key: key);

  @override
  State<CreateProductPage> createState() => _CreateProductPageState();
}

class _CreateProductPageState extends State<CreateProductPage> {
  final Map<String, List<AttributeOption>> _attributes = {
    'color': [],
    'size': [],
    'weight': [],
  };
  final _attributeValueController = TextEditingController();
  final _attributePriceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _discountPriceController = TextEditingController();
  final _stockController = TextEditingController();
  final _brandController = TextEditingController();

  String? _selectedCategoryId;
  File? _selectedImage;
  bool _isLoading = false;
  double? _priceAfterDiscount;

  final _productViewModel = ProductProvider.instance.productViewModel;
  final _categoryViewModel = CategoryProvider.instance.categoryViewModel;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_updatePriceAfterDiscount);
    _discountPriceController.addListener(_updatePriceAfterDiscount);
    // Load categories when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _categoryViewModel.loadCategories();
    });
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
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.removeListener(_updatePriceAfterDiscount);
    _discountPriceController.removeListener(_updatePriceAfterDiscount);
    _priceController.dispose();
    _discountPriceController.dispose();
    _stockController.dispose();
    _brandController.dispose();
    _attributeValueController.dispose();
    _attributePriceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please select a category'),
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

      setState(() => _isLoading = true);

      // Basic validation for numbers
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
        setState(() => _isLoading = false);
        return;
      }

      // Upload Image if selected
      List<String> images = [];
      if (_selectedImage != null) {
        final imageUrl = await _productViewModel.uploadImage(_selectedImage!);
        if (imageUrl != null) {
          images.add(imageUrl);
        } else {
          // Upload failed
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  _productViewModel.state.errorMessage ?? 'Image upload failed',
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
            setState(() => _isLoading = false);
          }
          return;
        }
      }

      // Filter out empty lists
      final attributesToSend = <String, List<AttributeOption>>{};
      _attributes.forEach((key, value) {
        if (value.isNotEmpty) {
          attributesToSend[key] = value;
        }
      });

      final success = await _productViewModel.createProduct(
        title: _titleController.text,
        description: _descriptionController.text,
        price: price,
        discountPrice: discountPrice,
        categoryId: _selectedCategoryId!,
        stock: stock,
        brand: _brandController.text.isNotEmpty ? _brandController.text : null,
        images: images,
        attributes: attributesToSend.isNotEmpty ? attributesToSend : null,
      );

      if (mounted) {
        setState(() => _isLoading = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Product created successfully'),
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
                _productViewModel.state.errorMessage ??
                    'Failed to create product',
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
        title: const Text('Add New Product'),
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
              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                    image: _selectedImage != null
                        ? DecorationImage(
                            image: FileImage(_selectedImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _selectedImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 48,
                              color: AppColors.sellerPrimary,
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap to upload image',
                              style: TextStyle(color: AppColors.textHint),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              const SizedBox(height: 16),

              const SizedBox(height: 16),

              // Price Fields
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _priceController,
                      labelText: 'Price',
                      hintText: '0.00',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      focusColor: AppColors.sellerPrimary,
                      validator: (v) =>
                          v?.isEmpty == true ? 'Price is required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: CustomTextField(
                      controller: _discountPriceController,
                      labelText: 'Discount Amount',
                      hintText: 'Optional',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
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
                    const SizedBox(height: 16),
                    _buildAttributeSection('Color', 'color'),
                    const Divider(),
                    _buildAttributeSection('Size', 'size'),
                    const Divider(),
                    _buildAttributeSection('Weight', 'weight'),
                  ],
                ),
              ),

              CustomTextField(
                controller: _titleController,
                labelText: 'Product Title',
                hintText: 'Enter product name',
                focusColor: AppColors.sellerPrimary,
                validator: (v) =>
                    v?.isEmpty == true ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _descriptionController,
                labelText: 'Description',
                hintText: 'Product details...',
                maxLines: 4,
                focusColor: AppColors.sellerPrimary,
                validator: (v) =>
                    v?.isEmpty == true ? 'Description is required' : null,
              ),
              const SizedBox(height: 16),

              // Stock & Brand
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: _stockController,
                      labelText: 'Stock',
                      hintText: 'QTY',
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

              // Category Dropdown
              AnimatedBuilder(
                animation: _categoryViewModel,
                builder: (context, child) {
                  if (_categoryViewModel.isLoading) {
                    return const Center(
                      child: LinearProgressIndicator(
                        color: AppColors.sellerPrimary,
                      ),
                    );
                  }

                  // Deduplicate categories by ID or content to avoid DropdownButton errors
                  final uniqueCategories = <String, CategoryEntity>{};
                  for (var cat in _categoryViewModel.categories) {
                    uniqueCategories[cat.id] = cat;
                  }
                  final items = uniqueCategories.values.toList();

                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      floatingLabelStyle: const TextStyle(
                        color: AppColors.sellerPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.sellerPrimary,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.surfaceLight,
                    ),
                    items: items.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                    validator: (v) =>
                        v == null ? 'Please select a category' : null,
                    hint: const Text('Select Category'),
                  );
                },
              ),

              const SizedBox(height: 24),
              CustomButton(
                text: 'Create Product',
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
                ? ' (${option.priceModifier > 0 ? '+' : ''}${option.priceModifier})'
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
