# Offline Support Guide

This document describes PetSphere's offline-first architecture and how to use the caching and sync infrastructure.

## Overview

PetSphere implements a **offline-first, sync-when-online** strategy for critical features:

- **Feed browsing**: Cache posts, serve from cache when offline
- **Marketplace**: Cache products, allow browsing and cart management offline
- **Health tracking**: Cache health data, queue medication logs for sync
- **Operations**: Queue writes (orders, posts, messages) for sync when online

## Architecture

### Core Components

#### 1. OfflineCache (`lib/utils/offline_cache.dart`)

Abstraction layer over `SharedPreferences` for local data persistence.

```dart
// Initialize on app startup
await OfflineCache().initialize();

// Cache data
await cache.cacheFeedPosts(posts);
await cache.cacheProducts(products);
await cache.cachePetHealth(petId, healthData);

// Retrieve with TTL checking
if (cache.isFeedPostsFresh(Duration(hours: 1))) {
  final posts = cache.getCachedFeedPosts();
}

// Queue operations for sync
await cache.queueSyncOperation(
  operation: 'create',
  table: 'posts',
  data: postData,
);

// Retrieve sync queue
final queue = cache.getSyncQueue();

// Clear after sync
await cache.clearSyncQueue();
```

**Key Features:**
- Timestamp-based TTL (default: 24 hours)
- JSON serialization via `jsonEncode()`
- Sync operation queueing with timestamps
- Per-table caching with smart cache keys

#### 2. ConnectivityService (`lib/utils/connectivity_service.dart`)

Tracks device connectivity status (online/offline/unknown).

```dart
final connectivity = ConnectivityService();

// Check current status
if (connectivity.isOnline) {
  // Sync operations
}

// Listen to connectivity changes
connectivity.statusStream.listen((status) {
  if (status == ConnectivityStatus.online) {
    // Trigger sync
  }
});

// For testing
connectivity.setOffline();
connectivity.setOnline();
```

**Integration Points:**
- Hook into native connectivity plugins (e.g., `connectivity_plus`)
- Trigger syncing when status changes to online

#### 3. Offline Repository Wrappers

Wrap existing repositories with offline support:

- **OfflineFeedRepository**: Posts, stories
- **OfflineMarketplaceRepository**: Products, orders  
- **OfflineHealthRepository**: Medications, health records

**Pattern:**
```dart
class OfflineXyzRepository {
  final XyzRepository _repository;
  final OfflineCache _cache;
  final ConnectivityService _connectivity;

  // Reads: cache → network → fallback
  Future<List<Model>> fetch() async {
    if (_connectivity.isOffline) {
      final cached = _cache.getCached...();
      if (cached != null) return cached;
      throw Exception('...');
    }
    
    if (_cache.isFresh(...)) {
      return _cache.getCached...();
    }
    
    try {
      final data = await _repository.fetch();
      await _cache.cache(data);
      return data;
    } catch (e) {
      // Fallback to cache
      final cached = _cache.getCached...();
      if (cached != null) return cached;
      rethrow;
    }
  }

  // Writes: queue if offline
  Future<bool> create(data) async {
    if (_connectivity.isOffline) {
      await _cache.queueSyncOperation(...);
      return true; // Queued
    }
    
    return await _repository.create(data);
  }
}
```

## Usage in Controllers

### 1. Initialize Infrastructure (main.dart)

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize offline support
  await OfflineCache().initialize();
  
  // Hook up connectivity detection
  // TODO: Integrate with connectivity_plus
  // connectivity.onConnectivityChanged.listen((result) {
  //   ConnectivityService().updateStatus(result.isOnline 
  //     ? ConnectivityStatus.online 
  //     : ConnectivityStatus.offline
  //   );
  // });
  
  runApp(const ProviderScope(child: PetSphereApp()));
}
```

### 2. Use in Riverpod Controllers

```dart
final feedProvider = NotifierProvider<FeedNotifier, FeedState>(...);

class FeedNotifier extends Notifier<FeedState> {
  late final OfflineFeedRepository _repo;

  @override
  FeedState build() {
    _repo = OfflineFeedRepository(
      feedRepository: feedRepository,
      cache: OfflineCache(),
      connectivity: ConnectivityService(),
    );
    
    // Auto-sync when coming online
    ref.listen(connectivityProvider, (prev, next) {
      if (next == ConnectivityStatus.online) {
        _syncQueuedOperations();
      }
    });
    
    return FeedState();
  }

  Future<void> loadFeed() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final posts = await _repo.fetchPosts();
      state = state.copyWith(posts: posts, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> createPost(String caption) async {
    if (ConnectivityService().isOffline) {
      // Queued - show user message
      state = state.copyWith(
        message: 'Post queued. Will upload when online.',
      );
      await _repo.createPost(...);
      return;
    }
    
    final post = await _repo.createPost(...);
    state = state.copyWith(posts: [post, ...state.posts]);
  }

  Future<void> _syncQueuedOperations() async {
    final queue = OfflineCache().getSyncQueue();
    
    for (int i = 0; i < queue.length; i++) {
      final op = queue[i];
      try {
        switch (op['operation']) {
          case 'create':
            await _syncCreate(op);
            break;
          case 'update':
            await _syncUpdate(op);
            break;
          case 'delete':
            await _syncDelete(op);
            break;
        }
        await OfflineCache().removeSyncOperation(i);
      } catch (e) {
        print('Sync failed for operation $i: $e');
        // Keep in queue for retry
      }
    }
    
    await OfflineCache().updateLastSync();
  }
}
```

### 3. UI Feedback for Offline State

```dart
class FeedScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectivity = ref.watch(connectivityProvider);
    final feedState = ref.watch(feedProvider);

    return Scaffold(
      body: Column(
        children: [
          // Show offline banner
          if (connectivity == ConnectivityStatus.offline)
            Container(
              color: Colors.orange,
              padding: EdgeInsets.all(8),
              child: Row(
                children: [
                  Icon(Icons.cloud_off, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    'You are offline. Showing cached content.',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),

          // Feed content
          if (feedState.isLoading)
            LoadingWidget()
          else if (feedState.error != null)
            ErrorWidget(feedState.error!)
          else
            FeedListView(posts: feedState.posts),
        ],
      ),
    );
  }
}
```

## Cache TTL Strategy

| Data Type | TTL | Rationale |
|-----------|-----|-----------|
| Feed posts | 1 hour | Content changes frequently |
| Stories | N/A | Ephemeral (24h expiry) |
| Products | 4 hours | Stable, infrequently updated |
| Health data | 6 hours | Personal data, less critical timing |
| Sync queue | Indefinite | Must persist until synced |

## Sync Queue Format

Operations queued for sync are stored as JSON:

```dart
{
  'operation': 'create|update|delete',
  'table': 'posts|orders|messages|etc',
  'data': { /* operation data */ },
  'timestamp': 1620000000000, // Milliseconds since epoch
}
```

**Example: Create a post offline**
```dart
{
  'operation': 'create',
  'table': 'posts',
  'data': {
    'pet_id': 'pet-123',
    'media_url': 'https://...',
    'caption': 'My pet is adorable!',
    'location': 'San Francisco, CA',
    'tagged_pet_ids': [],
  },
  'timestamp': 1704067200000,
}
```

## Best Practices

### ✅ DO

- **Initialize OfflineCache early** (in main() or app initialization)
- **Always check ConnectivityService** before write operations
- **Queue operations** if offline to preserve intent
- **Fallback to cache** gracefully when network fails
- **Show users** when content is cached (stale indicator)
- **Clear cache** after successful sync
- **Use appropriate TTLs** based on data change frequency
- **Test offline mode** during development (toggle in ConnectivityService)

### ❌ DON'T

- **Assume network is always available** — always check connectivity
- **Lose user data** — queue operations instead of discarding
- **Cache sensitive data** — implement security measures if needed
- **Sync all at once** — process queue incrementally to handle failures
- **Ignore sync errors** — keep failed operations in queue for retry
- **Clear cache before sync** — wait until operations complete
- **Cache everything** — be selective based on offline UX value

## Future Enhancements

Phase 2 improvements:

1. **Hive integration**: Replace SharedPreferences for better performance
2. **Realtime sync**: Use Supabase Realtime for bi-directional sync
3. **Conflict resolution**: Handle cases where data changed on server during offline period
4. **Bandwidth optimization**: Download full image data only for key products
5. **Background sync**: iOS/Android background sync when network available
6. **Sync status UI**: Show sync progress and retry UI
7. **Storage cleanup**: Implement cache size limits and cleanup policy

## Testing Offline Functionality

```dart
// In tests or during development
final connectivity = ConnectivityService();

// Simulate offline
connectivity.setOffline();
await controller.loadFeed(); // Should return cached data

// Simulate back online
connectivity.setOnline();
await Future.delayed(Duration(seconds: 1));
// Should trigger sync of queued operations
```

## Troubleshooting

**Q: Cache not returning data when offline**
- Ensure data was cached before going offline
- Check cache TTL hasn't expired
- Verify OfflineCache was initialized

**Q: Sync queue not clearing**
- Ensure operations complete successfully
- Check for errors in sync loop
- Manually clear queue if needed: `await OfflineCache().clearSyncQueue()`

**Q: Too much data in cache**
- Reduce TTL to prune stale data faster
- Implement cache size limits
- Clear cache when storage is full

---

**Last Updated:** May 2026
**Status:** Phase 1 - Foundation (MVP)
