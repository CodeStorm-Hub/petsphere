import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petsphere/core/constants/app_strings.dart';
import 'package:petsphere/core/utils/logger.dart';
import 'package:petsphere/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petsphere/features/marketplace/data/marketplace_repository.dart';
import 'package:petsphere/features/marketplace/data/models/product_model.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------
class MarketplaceState {
  final List<ProductModel> products;
  final String? filterCategory;
  final bool isLoading;
  final String? error;

  MarketplaceState({
    this.products = const [],
    this.filterCategory,
    this.isLoading = false,
    this.error,
  });

  MarketplaceState copyWith({
    List<ProductModel>? products,
    String? filterCategory,
    bool? isLoading,
    String? error,
    bool clearCategory = false,
    bool clearError = false,
  }) {
    return MarketplaceState(
      products: products ?? this.products,
      filterCategory: clearCategory
          ? null
          : (filterCategory ?? this.filterCategory),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ---------------------------------------------------------------------------
// Notifier
// ---------------------------------------------------------------------------
class MarketplaceController extends Notifier<MarketplaceState> {
  String? _lastFetchedForUserId;

  @override
  MarketplaceState build() {
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated &&
          next.user != null &&
          _lastFetchedForUserId != next.user!.id) {
        _lastFetchedForUserId = next.user!.id;
        _fetchProducts(category: state.filterCategory);
      } else if (next.status == AuthStatus.unauthenticated) {
        _lastFetchedForUserId = null;
      }
    });

    Future.microtask(() => _fetchProducts());
    final authedUser = ref.read(authProvider).user;
    if (authedUser != null) _lastFetchedForUserId = authedUser.id;
    return MarketplaceState(isLoading: true);
  }

  Future<void> _fetchProducts({String? category}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final products = await marketplaceRepository.fetchProducts(
        category: category,
      );
      state = state.copyWith(products: products, isLoading: false);
    } catch (e) {
      AppLogger.error(
        AppStrings.marketplaceLoadFailed,
        tag: 'MarketplaceController',
        error: e,
      );
      state = state.copyWith(isLoading: false, error: AppStrings.marketplaceLoadFailed);
    }
  }

  Future<void> refresh() => _fetchProducts(category: state.filterCategory);

  void setFilter(String? category) {
    if (category == null || category.isEmpty) {
      state = state.copyWith(clearCategory: true);
      _fetchProducts();
    } else {
      state = state.copyWith(filterCategory: category);
      _fetchProducts(category: category);
    }
  }
}

// ---------------------------------------------------------------------------
// Provider
// ---------------------------------------------------------------------------
final marketplaceProvider =
    NotifierProvider<MarketplaceController, MarketplaceState>(() {
      return MarketplaceController();
    });

// ---------------------------------------------------------------------------
// Single-product provider used for deep-linking into /product/:id.
//
// Prefers the cached entry in [marketplaceProvider] when available,
// otherwise fetches directly from Supabase.
// ---------------------------------------------------------------------------
final productByIdProvider = FutureProvider.family<ProductModel?, String>((
  ref,
  id,
) async {
  final cached = ref.watch(
    marketplaceProvider.select(
      (s) => s.products.where((p) => p.id == id).toList(),
    ),
  );
  if (cached.isNotEmpty) return cached.first;
  return marketplaceRepository.fetchProductById(id);
});
