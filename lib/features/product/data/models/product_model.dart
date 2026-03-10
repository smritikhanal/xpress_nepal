import 'package:xpress_nepal/features/product/domain/entities/product_entity.dart';

/// Product Model for API communication
/// Handles JSON serialization/deserialization
class ProductModel extends ProductEntity {
  const ProductModel({
    required String id,
    required String title,
    required String slug,
    required String description,
    required double price,
    double? discountPrice,
    required String categoryId,
    String? categoryName,
    required String sellerId,
    String? brand,
    List<String> images = const [],
    required int stock,
    ProductAttributesModel? attributes,
    double ratingAvg = 0,
    int ratingCount = 0,
    bool isActive = true,
    String? createdAt,
    String? updatedAt,
  }) : super(
         id: id,
         title: title,
         slug: slug,
         description: description,
         price: price,
         discountPrice: discountPrice,
         categoryId: categoryId,
         categoryName: categoryName,
         sellerId: sellerId,
         brand: brand,
         images: images,
         stock: stock,
         attributes: attributes,
         ratingAvg: ratingAvg,
         ratingCount: ratingCount,
         isActive: isActive,
         createdAt: createdAt,
         updatedAt: updatedAt,
       );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Handle nested category object or ID string
    final categoryData = json['categoryId'];
    String catId = '';
    String? catName;

    if (categoryData is Map) {
      catId =
          categoryData['_id']?.toString() ??
          categoryData['id']?.toString() ??
          '';
      catName = categoryData['name']?.toString();
    } else if (categoryData != null) {
      catId = categoryData.toString();
    }

    // Handle nested seller object or ID string
    final sellerData = json['sellerId'];
    String selId = '';

    if (sellerData is Map) {
      selId =
          sellerData['_id']?.toString() ?? sellerData['id']?.toString() ?? '';
    } else if (sellerData != null) {
      selId = sellerData.toString();
    }

    return ProductModel(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      categoryId: catId,
      categoryName: catName,
      sellerId: selId,
      brand: json['brand']?.toString(),
      images:
          (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      attributes: json['attributes'] != null
          ? ProductAttributesModel.fromJson(json['attributes'])
          : null,
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0.0,
      ratingCount: (json['ratingCount'] as num?)?.toInt() ?? 0,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      if (discountPrice != null) 'discountPrice': discountPrice,
      'categoryId': categoryId,
      'brand': brand,
      'images': images,
      'stock': stock,
      if (attributes != null)
        'attributes': (attributes as ProductAttributesModel).toJson(),
    };
  }
}

class ProductAttributesModel extends ProductAttributesEntity {
  const ProductAttributesModel({
    List<AttributeOption>? color,
    List<AttributeOption>? size,
    List<AttributeOption>? weight,
  }) : super(color: color, size: size, weight: weight);

  factory ProductAttributesModel.fromJson(Map<String, dynamic> json) {
    List<AttributeOption> parseOptions(dynamic data) {
      if (data == null) return [];
      if (data is List) {
        return data.map((e) => AttributeOption.fromJson(e)).toList();
      }
      return [];
    }

    return ProductAttributesModel(
      color: parseOptions(json['color']),
      size: parseOptions(json['size']),
      weight: parseOptions(json['weight']),
    );
  }

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>>? optionsToJson(List<AttributeOption>? options) {
      if (options == null || options.isEmpty) return null;
      return options.map((e) => {
        'value': e.value,
        'priceModifier': e.priceModifier,
      }).toList();
    }

    final data = <String, dynamic>{};
    if (color != null && color!.isNotEmpty) data['color'] = optionsToJson(color);
    if (size != null && size!.isNotEmpty) data['size'] = optionsToJson(size);
    if (weight != null && weight!.isNotEmpty) data['weight'] = optionsToJson(weight);
    return data;
  }
}
