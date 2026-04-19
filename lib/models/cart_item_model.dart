import 'package:pet_dating_app/models/product_model.dart';

class CartItemModel {
  final String id;
  final ProductModel product;
  final int quantity;

  CartItemModel({
    required this.id,
    required this.product,
    this.quantity = 1,
  });

  double get subtotal => product.price * quantity;

  CartItemModel copyWith({
    String? id,
    ProductModel? product,
    int? quantity,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
