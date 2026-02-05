class ProductEntity {
  final String id;
  final String title;
  final String slug;
  final String description;
  final double price;
  final double? discountPrice;
  final String categoryId;
  final String? categoryName;
  final String sellerId;
  final String? brand;
  final List<String> images;
  final int stock;
  final ProductAttributesEntity? attributes;
  final double ratingAvg;
  final int ratingCount;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;

  const ProductEntity({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.categoryId,
    this.categoryName,
    required this.sellerId,
    this.brand,
    this.images = const [],
    required this.stock,
    this.attributes,
    this.ratingAvg = 0,
    this.ratingCount = 0,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  /// ✅ Factory constructor MUST be inside the class
  factory ProductEntity.fromJson(Map<String, dynamic> json) {
    return ProductEntity(
      id: json['id'] ?? json['_id'] ?? '',
      title: json['title'] ?? '',
      slug: json['slug'] ?? '',
      description: json['description'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (json['discountPrice'] as num?)?.toDouble(),
      categoryId: json['categoryId'] ?? '',
      categoryName: json['categoryName'],
      sellerId: json['sellerId'] ?? '',
      brand: json['brand'],
      images:
          (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      stock: json['stock'] ?? 0,
      attributes: json['attributes'] != null
          ? ProductAttributesEntity.fromJson(json['attributes'])
          : null,
      ratingAvg: (json['ratingAvg'] as num?)?.toDouble() ?? 0.0,
      ratingCount: json['ratingCount'] ?? 0,
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ProductEntity &&
        other.id == id &&
        other.title == title &&
        other.slug == slug &&
        other.price == price &&
        other.isActive == isActive;
  }

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      slug.hashCode ^
      price.hashCode ^
      isActive.hashCode;
}

/// ✅ Attribute Option Entity
class AttributeOption {
  final String value;
  final double priceModifier;

  const AttributeOption({required this.value, this.priceModifier = 0.0});

  factory AttributeOption.fromJson(Map<String, dynamic> json) {
    return AttributeOption(
      value: json['value']?.toString() ?? '',
      priceModifier: (json['priceModifier'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// ✅ Attributes entity
class ProductAttributesEntity {
  final List<AttributeOption>? color;
  final List<AttributeOption>? size;
  final List<AttributeOption>? weight;

  const ProductAttributesEntity({this.color, this.size, this.weight});

  factory ProductAttributesEntity.fromJson(Map<String, dynamic> json) {
    List<AttributeOption> parseOptions(dynamic data) {
      if (data == null) return [];
      if (data is List) {
        return data.map((e) => AttributeOption.fromJson(e)).toList();
      }
      return [];
    }

    return ProductAttributesEntity(
      color: parseOptions(json['color']),
      size: parseOptions(json['size']),
      weight: parseOptions(json['weight']),
    );
  }
}
