import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../repositories/marketplace_repository.dart';
import 'auth_controller.dart';

const _kCartStorageKey = 'petsphere.cart.v1';

class CartState {
  final List<CartItemModel> items;
  final bool isCheckingOut;
  final bool orderSuccess;
  final String? error;

  CartState({
    this.items = const [],
    this.isCheckingOut = false,
    this.orderSuccess = false,
    this.error,
  });

  double get totalPrice {
    return items.fold(0, (sum, item) => sum + item.subtotal);
  }

  int get totalItemCount {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  CartState copyWith({
    List<CartItemModel>? items,
    bool? isCheckingOut,
    bool? orderSuccess,
    String? error,
    bool clearError = false,
  }) {
    return CartState(
      items: items ?? this.items,
      isCheckingOut: isCheckingOut ?? this.isCheckingOut,
      orderSuccess: orderSuccess ?? this.orderSuccess,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class CartController extends Notifier<CartState> {
  @override
  CartState build() {
    // Hydrate from disk in the background; subsequent mutations persist.
    unawaited(_hydrate());
    return CartState(items: []);
  }

  // -------------------------------------------------------------------------
  // Disk persistence (shared_preferences)
  // -------------------------------------------------------------------------
  Future<void> _hydrate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_kCartStorageKey);
      if (raw == null || raw.isEmpty) return;
      final list = (jsonDecode(raw) as List<dynamic>);
      final items = list
          .whereType<Map<String, dynamic>>()
          .map(_cartItemFromJson)
          .whereType<CartItemModel>()
          .toList();
      if (items.isNotEmpty) {
        state = state.copyWith(items: items);
      }
    } catch (e) {
      debugPrint('Cart hydrate failed: $e');
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final encoded =
          jsonEncode(state.items.map(_cartItemToJson).toList(growable: false));
      await prefs.setString(_kCartStorageKey, encoded);
    } catch (e) {
      debugPrint('Cart persist failed: $e');
    }
  }

  void addProduct(ProductModel product) {
    final existingIndex = state.items.indexWhere((i) => i.product.id == product.id);

    if (existingIndex >= 0) {
      final newItems = List<CartItemModel>.from(state.items);
      final item = newItems[existingIndex];
      newItems[existingIndex] = item.copyWith(quantity: item.quantity + 1);
      state = state.copyWith(items: newItems);
    } else {
      final newItem = CartItemModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        product: product,
      );
      state = state.copyWith(items: [...state.items, newItem]);
    }
    unawaited(_persist());
  }

  void removeCartItem(String itemId) {
    final newItems = state.items.where((i) => i.id != itemId).toList();
    state = state.copyWith(items: newItems);
    unawaited(_persist());
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
    unawaited(_persist());
  }

  void clearCart() {
    state = CartState();
    unawaited(_persist());
  }

  // -------------------------------------------------------------------------
  // Place order — submits to Supabase then clears cart
  // -------------------------------------------------------------------------
  Future<bool> placeOrder() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null || state.items.isEmpty) return false;

    state = state.copyWith(isCheckingOut: true, clearError: true, orderSuccess: false);
    try {
      await marketplaceRepository.placeOrder(
        userId: userId,
        items: state.items,
      );
      state = CartState(orderSuccess: true);
      unawaited(_persist());
      return true;
    } catch (e) {
      state = state.copyWith(
        isCheckingOut: false,
        error: 'Order failed: ${e.toString()}',
      );
      return false;
    }
  }
}

// ---------------------------------------------------------------------------
// Cart serialization helpers — local to this controller because ProductModel.toJson
// doesn't include `id` (it's used for inserts to Postgres).
// ---------------------------------------------------------------------------
Map<String, dynamic> _cartItemToJson(CartItemModel item) {
  final p = item.product;
  return {
    'id': item.id,
    'quantity': item.quantity,
    'product': {
      'id': p.id,
      'name': p.name,
      'price': p.price,
      'vendor_id': p.vendorId,
      'description': p.description,
      'images': p.images,
      'stock': p.stock,
      'category': p.category,
      'rating': p.rating,
      'review_count': p.reviewCount,
      'tags': p.tags,
      'is_bestseller': p.isBestseller,
    },
  };
}

CartItemModel? _cartItemFromJson(Map<String, dynamic> json) {
  try {
    final productJson = json['product'];
    if (productJson is! Map<String, dynamic>) return null;
    return CartItemModel(
      id: json['id'] as String,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      product: ProductModel.fromJson(productJson),
    );
  } catch (_) {
    return null;
  }
}

final cartProvider = NotifierProvider<CartController, CartState>(() {
  return CartController();
});
