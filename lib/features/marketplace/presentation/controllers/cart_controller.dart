import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:petfolio/core/constants/app_strings.dart';
import 'package:petfolio/core/utils/logger.dart';
import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/features/marketplace/data/marketplace_repository.dart';
import 'package:petfolio/features/marketplace/data/models/cart_item_model.dart';
import 'package:petfolio/features/marketplace/data/models/product_model.dart';

class CartState {

  CartState({
    this.items = const [],
    this.isCheckingOut = false,
    this.orderSuccess = false,
    this.error,
  });
  final List<CartItemModel> items;
  final bool isCheckingOut;
  final bool orderSuccess;
  final String? error;

  double get totalPrice {
    return items.fold<double>(0.0, (sum, item) => sum + item.subtotal);
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
  SharedPreferences? _prefs;
  Timer? _persistDebounce;
  String? _loadedForUserId;

  static const _cartKeyPrefix = 'cart_items_v1_';

  @override
  CartState build() {
    ref.listen<AuthState>(authProvider, (prev, next) {
      final prevUserId = prev?.user?.id;
      final nextUserId = next.user?.id;

      if (next.status == AuthStatus.authenticated && nextUserId != null) {
        if (_loadedForUserId != nextUserId) {
          _loadedForUserId = nextUserId;
          Future.microtask(_loadPersistedCartForActiveUser);
        }
        return;
      }

      // On logout / unauthenticated: clear memory + persisted cart for prior user.
      if (prevUserId != null) {
        Future.microtask(() => _clearPersistedCart(prevUserId));
      }
      _loadedForUserId = null;
      state = CartState(items: []);
    });

    Future.microtask(_loadPersistedCartForActiveUser);
    ref.onDispose(() {
      _persistDebounce?.cancel();
      _persistDebounce = null;
    });

    return CartState(items: []);
  }

  void addProduct(ProductModel product) {
    final existingIndex = state.items.indexWhere(
      (i) => i.product.id == product.id,
    );

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
    _schedulePersist();
  }

  void removeCartItem(String itemId) {
    final newItems = state.items.where((i) => i.id != itemId).toList();
    state = state.copyWith(items: newItems);
    _schedulePersist();
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
    _schedulePersist();
  }

  void clearCart() {
    state = CartState();
    _schedulePersist();
  }

  // -------------------------------------------------------------------------
  // Place order — submits to Supabase then clears cart
  // -------------------------------------------------------------------------
  Future<bool> placeOrder() async {
    final userId = ref.read(authProvider).user?.id;
    if (userId == null || state.items.isEmpty) return false;

    state = state.copyWith(
      isCheckingOut: true,
      clearError: true,
      orderSuccess: false,
    );
    try {
      // 1) Create Stripe PaymentIntent (server-side via Edge Function)
      final amountCents = (state.totalPrice * 100).round();
      final intent = await marketplaceRepository.createStripePaymentIntent(
        amountCents: amountCents,
        metadata: {
          'user_id': userId,
          'cart_items_count': state.items.length.toString(),
        },
      );

      // 2) Confirm payment on-device
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: intent.clientSecret,
          merchantDisplayName: 'PetFolio',
        ),
      );
      await Stripe.instance.presentPaymentSheet();

      // 3) Create order only after successful payment
      await marketplaceRepository.placeOrder(
        userId: userId,
        items: state.items,
        paymentProvider: 'stripe',
        paymentIntentId: intent.paymentIntentId,
      );
      // Clear cart after successful order
      state = CartState(orderSuccess: true);
      await _clearPersistedCart(userId);
      return true;
    } on StripeException catch (e) {
      AppLogger.error(
        AppStrings.cartCheckoutFailed,
        tag: 'CartController',
        error: e,
      );
      state = state.copyWith(
        isCheckingOut: false,
        error: e.error.localizedMessage ?? AppStrings.cartCheckoutFailed,
      );
      return false;
    } on MarketplaceOutOfStockException {
      AppLogger.warning(
        'Out of stock during checkout',
        tag: 'CartController',
      );
      state = state.copyWith(isCheckingOut: false, error: AppStrings.cartCheckoutFailed);
      return false;
    } catch (e) {
      AppLogger.error(
        AppStrings.cartCheckoutFailed,
        tag: 'CartController',
        error: e,
      );
      state = state.copyWith(
        isCheckingOut: false,
        error: AppStrings.cartCheckoutFailed,
      );
      return false;
    }
  }

  String _cartStorageKey(String userId) => '$_cartKeyPrefix$userId';

  Future<void> _ensurePrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<void> _loadPersistedCartForActiveUser() async {
    final auth = ref.read(authProvider);
    final userId = auth.user?.id;
    if (auth.status != AuthStatus.authenticated || userId == null) return;

    await _ensurePrefs();
    final key = _cartStorageKey(userId);
    final raw = _prefs?.getString(key);
    if (raw == null || raw.isEmpty) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return;
      final items = decoded
          .whereType<Map<String, dynamic>>()
          .map(
            (e) => CartItemModel.fromJson(e),
          )
          .toList();
      state = state.copyWith(items: items);
    } catch (_) {
      // Corrupt JSON => fail-safe to empty cart.
      await _prefs?.remove(key);
      state = state.copyWith(items: []);
    }
  }

  void _schedulePersist() {
    _persistDebounce?.cancel();
    _persistDebounce = Timer(const Duration(milliseconds: 250), () async {
      final auth = ref.read(authProvider);
      final userId = auth.user?.id;
      if (auth.status != AuthStatus.authenticated || userId == null) return;
      await _ensurePrefs();
      final key = _cartStorageKey(userId);
      try {
        final json = jsonEncode(state.items.map((e) => e.toJson()).toList());
        await _prefs?.setString(key, json);
      } catch (_) {
        // Ignore persistence failure; cart remains in-memory.
      }
    });
  }

  Future<void> _clearPersistedCart(String userId) async {
    await _ensurePrefs();
    await _prefs?.remove(_cartStorageKey(userId));
  }
}

final cartProvider = NotifierProvider<CartController, CartState>(() {
  return CartController();
});
