import 'package:petsphere/features/marketplace/data/models/product_model.dart';
import 'package:petsphere/features/marketplace/data/models/cart_item_model.dart';
import 'package:petsphere/features/marketplace/data/models/order_model.dart';
import 'package:petsphere/features/marketplace/data/marketplace_repository.dart';
import 'package:petsphere/core/services/connectivity_service.dart';
import 'package:petsphere/core/services/offline_cache.dart';

/// Offline-first wrapper around MarketplaceRepository.
///
/// Strategy:
/// - Product browsing: Cache and serve from cache when offline
/// - Orders: Queue if offline, sync when online
/// - Cache TTL: 4 hours for product catalog (stable data)
class OfflineMarketplaceRepository {
  final MarketplaceRepository _repository;
  final OfflineCache _cache;
  final ConnectivityService _connectivity;

  static const Duration _productsCacheTTL = Duration(hours: 4);

  OfflineMarketplaceRepository({
    required MarketplaceRepository repository,
    required OfflineCache cache,
    required ConnectivityService connectivity,
  }) : _repository = repository,
       _cache = cache,
       _connectivity = connectivity;

  /// Fetch products with offline support
  ///
  /// Returns cached products if offline or cache is fresh.
  /// Fetches from network if online and cache is stale.
  Future<List<ProductModel>> fetchProducts({String? category}) async {
    // If offline, return cached products
    if (_connectivity.isOffline) {
      final cached = _cache.getCachedProducts();
      if (cached != null && cached.isNotEmpty) {
        return cached
            .map(
              (json) => ProductModel.fromJson(
                (json as Map).cast<String, dynamic>(),
              ),
            )
            .toList();
      }
      throw Exception('No cached products available and device is offline');
    }

    // If online, check cache freshness
    if (_cache.isProductsFresh(_productsCacheTTL)) {
      final cached = _cache.getCachedProducts();
      if (cached != null) {
        return cached
            .map(
              (json) => ProductModel.fromJson(
                (json as Map).cast<String, dynamic>(),
              ),
            )
            .toList();
      }
    }

    // Cache is stale, fetch from network
    try {
      final products = await _repository.fetchProducts(category: category);

      // Cache products (as JSON for storage)
      await _cache.cacheProducts(products.map((p) => p.toJson()).toList());

      return products;
    } catch (e) {
      // Network error - try cache as fallback
      final cached = _cache.getCachedProducts();
      if (cached != null && cached.isNotEmpty) {
        return cached
            .map(
              (json) => ProductModel.fromJson(
                (json as Map).cast<String, dynamic>(),
              ),
            )
            .toList();
      }
      rethrow;
    }
  }

  /// Fetch single product by ID
  ///
  /// Always fetches fresh from network (single item lookup).
  /// Falls back to cache if offline.
  Future<ProductModel?> fetchProductById(String id) async {
    if (_connectivity.isOffline) {
      // Try to find in cached products
      final cached = _cache.getCachedProducts();
      if (cached != null) {
        for (final json in cached) {
          if (json['id'] == id) {
            return ProductModel.fromJson((json as Map).cast<String, dynamic>());
          }
        }
      }
      throw Exception('Product not in cache and device is offline');
    }

    try {
      return await _repository.fetchProductById(id);
    } catch (e) {
      // Try cache as fallback
      final cached = _cache.getCachedProducts();
      if (cached != null) {
        for (final json in cached) {
          if (json['id'] == id) {
            return ProductModel.fromJson((json as Map).cast<String, dynamic>());
          }
        }
      }
      rethrow;
    }
  }

  /// Place an order - queued if offline
  ///
  /// If offline, order is queued for sync when online.
  /// If online, order is placed immediately.
  Future<bool> placeOrder({
    required String userId,
    required List<CartItemModel> items,
  }) async {
    if (_connectivity.isOffline) {
      // Queue the order for sync
      final total = items.fold<double>(0, (sum, i) => sum + i.subtotal);
      final orderItems = items
          .map(
            (i) => {
              'product_id': i.product.id,
              'name': i.product.name,
              'quantity': i.quantity,
              'price': i.product.price,
              'subtotal': i.subtotal,
            },
          )
          .toList();

      await _cache.queueSyncOperation(
        operation: 'create',
        table: 'orders',
        data: {
          'user_id': userId,
          'items': orderItems,
          'total': total,
          'status': 'pending',
        },
      );
      return true; // Queued successfully
    }

    // Online - place order immediately
    try {
      await _repository.placeOrder(userId: userId, items: items);
      return true;
    } catch (e) {
      // On network error, queue for later
      final total = items.fold<double>(0, (sum, i) => sum + i.subtotal);
      final orderItems = items
          .map(
            (i) => {
              'product_id': i.product.id,
              'name': i.product.name,
              'quantity': i.quantity,
              'price': i.product.price,
              'subtotal': i.subtotal,
            },
          )
          .toList();

      await _cache.queueSyncOperation(
        operation: 'create',
        table: 'orders',
        data: {
          'user_id': userId,
          'items': orderItems,
          'total': total,
          'status': 'pending',
        },
      );
      return true;
    }
  }

  /// Fetch user's orders
  ///
  /// Requires online access (orders are transaction history, not meant for offline).
  Future<List<OrderModel>> fetchOrders(String userId) async {
    if (_connectivity.isOffline) {
      throw Exception('Cannot fetch order history while offline');
    }
    return await _repository.fetchOrders(userId);
  }

  /// Clear product cache (force refresh)
  Future<void> clearCache() async {
    await _cache.clearCache('offline_products');
  }
}
