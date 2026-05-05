import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Offline-first caching layer for PetSphere data.
///
/// Provides local persistence for critical data (feed, products, health records).
/// Syncs with Supabase when connectivity is restored.
class OfflineCache {
  static final OfflineCache _instance = OfflineCache._internal();

  late SharedPreferences _prefs;
  bool _initialized = false;

  OfflineCache._internal();

  factory OfflineCache() => _instance;

  /// Initialize the cache with SharedPreferences instance
  Future<void> initialize() async {
    if (_initialized) return;
    _prefs = await SharedPreferences.getInstance();
    _initialized = true;
  }

  /// Cache keys
  static const String _feedPostsKey = 'offline_feed_posts';
  static const String _productsKey = 'offline_products';
  static const String _petHealthKey = 'offline_pet_health_';
  static const String _syncQueueKey = 'offline_sync_queue';
  static const String _lastSyncKey = 'offline_last_sync';

  // Default cache TTL: 24 hours
  static const Duration defaultCacheTTL = Duration(hours: 24);

  /// Save JSON data with timestamp
  Future<void> saveJson(String key, dynamic data) async {
    await _ensureInitialized();
    final jsonString = jsonEncode(data);
    await _prefs.setString(key, jsonString);
    await _prefs.setInt('${key}_ts', DateTime.now().millisecondsSinceEpoch);
  }

  /// Retrieve JSON data
  dynamic getJson(String key) {
    _ensureInitializedSync();
    final jsonString = _prefs.getString(key);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }

  /// Check if data is still valid (not expired)
  bool isDataValid(String key, Duration ttl) {
    _ensureInitializedSync();
    final timestamp = _prefs.getInt('${key}_ts');
    if (timestamp == null) return false;

    final cachedAt = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final expiredAt = cachedAt.add(ttl);
    return DateTime.now().isBefore(expiredAt);
  }

  /// Cache feed posts (e.g., from home feed, discover page)
  Future<void> cacheFeedPosts(List<dynamic> posts) async {
    await saveJson(_feedPostsKey, posts);
  }

  /// Retrieve cached feed posts
  List<dynamic>? getCachedFeedPosts() {
    final data = getJson(_feedPostsKey);
    return data is List ? data : null;
  }

  /// Check if feed posts cache is fresh
  bool isFeedPostsFresh([Duration? ttl]) {
    return isDataValid(_feedPostsKey, ttl ?? defaultCacheTTL);
  }

  /// Cache marketplace products
  Future<void> cacheProducts(List<dynamic> products) async {
    await saveJson(_productsKey, products);
  }

  /// Retrieve cached products
  List<dynamic>? getCachedProducts() {
    final data = getJson(_productsKey);
    return data is List ? data : null;
  }

  /// Check if products cache is fresh
  bool isProductsFresh([Duration? ttl]) {
    return isDataValid(_productsKey, ttl ?? defaultCacheTTL);
  }

  /// Cache pet health records (vitals, medications, appointments)
  Future<void> cachePetHealth(String petId, Map<String, dynamic> health) async {
    await saveJson('$_petHealthKey$petId', health);
  }

  /// Retrieve cached pet health records
  Map<String, dynamic>? getCachedPetHealth(String petId) {
    final data = getJson('$_petHealthKey$petId');
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  /// Check if pet health cache is fresh
  bool isPetHealthFresh(String petId, [Duration? ttl]) {
    return isDataValid('$_petHealthKey$petId', ttl ?? defaultCacheTTL);
  }

  /// Queue a write operation for syncing when online
  ///
  /// Format: {
  ///   'operation': 'create|update|delete',
  ///   'table': 'posts|messages|etc',
  ///   'data': {...},
  ///   'timestamp': milliseconds,
  /// }
  Future<void> queueSyncOperation({
    required String operation,
    required String table,
    required Map<String, dynamic> data,
  }) async {
    await _ensureInitialized();
    final queue = _prefs.getStringList(_syncQueueKey) ?? [];

    final syncOp = jsonEncode({
      'operation': operation,
      'table': table,
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    queue.add(syncOp);
    await _prefs.setStringList(_syncQueueKey, queue);
  }

  /// Retrieve all queued sync operations
  List<Map<String, dynamic>> getSyncQueue() {
    _ensureInitializedSync();
    final queue = _prefs.getStringList(_syncQueueKey) ?? [];
    return queue.map((item) {
      try {
        return jsonDecode(item) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }).whereType<Map<String, dynamic>>().toList();
  }

  /// Clear sync queue after successful sync
  Future<void> clearSyncQueue() async {
    await _ensureInitialized();
    await _prefs.remove(_syncQueueKey);
  }

  /// Remove specific operation from sync queue
  Future<void> removeSyncOperation(int index) async {
    await _ensureInitialized();
    final queue = _prefs.getStringList(_syncQueueKey) ?? [];
    if (index >= 0 && index < queue.length) {
      queue.removeAt(index);
      await _prefs.setStringList(_syncQueueKey, queue);
    }
  }

  /// Update last sync timestamp
  Future<void> updateLastSync() async {
    await _ensureInitialized();
    await _prefs.setInt(_lastSyncKey, DateTime.now().millisecondsSinceEpoch);
  }

  /// Get timestamp of last sync
  DateTime? getLastSyncTime() {
    _ensureInitializedSync();
    final timestamp = _prefs.getInt(_lastSyncKey);
    return timestamp != null ? DateTime.fromMillisecondsSinceEpoch(timestamp) : null;
  }

  /// Clear all cached data
  Future<void> clearAllCache() async {
    await _ensureInitialized();
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith('offline_')) {
        await _prefs.remove(key);
      }
    }
  }

  /// Clear specific cache by key
  Future<void> clearCache(String key) async {
    await _ensureInitialized();
    await _prefs.remove(key);
    await _prefs.remove('${key}_ts');
  }

  Future<void> _ensureInitialized() async {
    if (!_initialized) await initialize();
  }

  void _ensureInitializedSync() {
    if (!_initialized) {
      throw StateError('OfflineCache not initialized. Call initialize() first.');
    }
  }
}
