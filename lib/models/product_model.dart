class ProductModel {
  final String id;
  final String name;
  final double price;
  final String vendorId;
  final String description;
  final List<String> images;
  final int stock;
  final String category;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.vendorId,
    required this.description,
    required this.images,
    required this.stock,
    required this.category,
  });

  ProductModel copyWith({
    String? id,
    String? name,
    double? price,
    String? vendorId,
    String? description,
    List<String>? images,
    int? stock,
    String? category,
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
    );
  }
}
