import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';

class CartState {
  final List<CartItemModel> items;

  CartState({this.items = const []});

  double get totalPrice {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }
  
  int get totalItemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  CartState copyWith({List<CartItemModel>? items}) {
    return CartState(items: items ?? this.items);
  }
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() {
    return CartState(items: []);
  }

  void addProduct(ProductModel product) {
    final existingIndex = state.items.indexWhere((i) => i.product.id == product.id);
    
    if (existingIndex >= 0) {
      // Product exists, increment quantity
      final newItems = List<CartItemModel>.from(state.items);
      final item = newItems[existingIndex];
      newItems[existingIndex] = item.copyWith(quantity: item.quantity + 1);
      state = state.copyWith(items: newItems);
    } else {
      // New product
      final newItem = CartItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
  }

  void removeCartItem(String itemId) {
    final newItems = state.items.where((i) => i.id != itemId).toList();
    state = state.copyWith(items: newItems);
  }

  void updateQuantity(String itemId, int newQuantity) {
    if (newQuantity <= 0) {
      removeCartItem(itemId);
      return;
    }
    
    final newItems = state.items.map((item) {
      if (item.id == itemId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();
    
    state = state.copyWith(items: newItems);
  }

  void clearCart() {
    state = CartState(items: []);
  }
}

final cartProvider = NotifierProvider<CartController, CartState>(() {
  return CartController();
});
