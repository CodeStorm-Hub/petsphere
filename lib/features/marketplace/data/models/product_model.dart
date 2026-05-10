class ProductModel {

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.vendorId,
    required this.description,
    required this.images,
    required this.stock,
    required this.category,
    this.rating = 0,
    this.reviewCount = 0,
    this.tags = const [],
    this.isBestseller = false,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      vendorId: json['vendor_id'] as String,
      description: json['description'] as String? ?? '',
      images:
          (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      category: json['category'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      tags:
          (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      isBestseller: json['is_bestseller'] as bool? ?? false,
    );
  }
  final String id;
  final String name;
  final double price;
  final String vendorId;
  final String description;
  final List<String> images;
  final int stock;
  final String category;
  final double rating;
  final int reviewCount;
  final List<String> tags;
  final bool isBestseller;

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? vendorId,
    String? description,
    List<String>? images,
    int? stock,
    String? category,
    double? rating,
    int? reviewCount,
    List<String>? tags,
    bool? isBestseller,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      vendorId: vendorId ?? this.vendorId,
      description: description ?? this.description,
      images: images ?? this.images,
      stock: stock ?? this.stock,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      tags: tags ?? this.tags,
      isBestseller: isBestseller ?? this.isBestseller,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'price': price,
    'vendor_id': vendorId,
    'description': description,
    'images': images,
    'stock': stock,
    'category': category,
    'rating': rating,
    'review_count': reviewCount,
    'tags': tags,
    'is_bestseller': isBestseller,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          price == other.price &&
          vendorId == other.vendorId &&
          description == other.description &&
          images == other.images &&
          stock == other.stock &&
          category == other.category &&
          rating == other.rating &&
          reviewCount == other.reviewCount &&
          tags == other.tags &&
          isBestseller == other.isBestseller;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      price.hashCode ^
      vendorId.hashCode ^
      description.hashCode ^
      images.hashCode ^
      stock.hashCode ^
      category.hashCode ^
      rating.hashCode ^
      reviewCount.hashCode ^
      tags.hashCode ^
      isBestseller.hashCode;
}
