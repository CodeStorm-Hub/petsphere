import 'product_model.dart';

class CartItemModel {

  CartItemModel({required this.id, required this.product, this.quantity = 1});

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
    );
  }
  final String id;
  final ProductModel product;
  final int quantity;

  double get subtotal => product.price * quantity;

  Map<String, dynamic> toJson() => {
    'id': id,
    'product': product.toJson(),
    'quantity': quantity,
  };

  CartItemModel copyWith({String? id, ProductModel? product, int? quantity}) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartItemModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          product == other.product &&
          quantity == other.quantity;

  @override
  int get hashCode => id.hashCode ^ product.hashCode ^ quantity.hashCode;
}
