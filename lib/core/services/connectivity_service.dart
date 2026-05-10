import 'dart:async';
import 'dart:developer' as developer;

import 'package:petfolio/core/constants/supabase_config.dart';
import 'package:petfolio/core/services/offline_cache.dart';

/// Simple connectivity status for PetFolio.
enum ConnectivityStatus { online, offline, unknown }

/// Service to track app connectivity status.
///
/// Provides a simple way to check if the device is online/offline,
/// useful for offline-first features and sync strategies.
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() => _instance;

  ConnectivityService._internal();

  ConnectivityStatus _status = ConnectivityStatus.unknown;
  final _statusController = StreamController<ConnectivityStatus>.broadcast();
  final OfflineCache _cache = OfflineCache();

  /// Current connectivity status
  ConnectivityStatus get status => _status;

  /// Stream of connectivity status changes
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  /// Whether device is currently online
  bool get isOnline => _status == ConnectivityStatus.online;

  /// Whether device is currently offline
  bool get isOffline => _status == ConnectivityStatus.offline;

  /// Update connectivity status (called by app on connectivity change)
  void updateStatus(ConnectivityStatus newStatus) {
    if (_status != newStatus) {
      _status = newStatus;
      _statusController.add(_status);

      // If we just came online, notify listeners for sync
      if (newStatus == ConnectivityStatus.online) {
        _onOnlineRestored();
      }
    }
  }

  /// Called when connectivity is restored
  Future<void> _onOnlineRestored() async {
    final queue = _cache.getSyncQueue();
    if (queue.isEmpty) return;

    final syncedIndexes = <int>[];
    for (var i = 0; i < queue.length; i++) {
      final item = queue[i];
      final operation = (item['operation'] as String?)?.toLowerCase();
      final table = item['table'] as String?;
      final data = item['data'] as Map<String, dynamic>?;
      if (operation == null || table == null || data == null) {
        continue;
      }

      try {
        await _syncOperation(operation: operation, table: table, data: data);
        syncedIndexes.add(i);
      } catch (e, st) {
        developer.log(
          'Failed syncing queued operation for $table/$operation: $e',
          name: 'ConnectivityService',
          error: e,
          stackTrace: st,
        );
      }
    }

    for (final index in syncedIndexes.reversed) {
      await _cache.removeSyncOperation(index);
    }

    await _cache.updateLastSync();
  }

  Future<void> _syncOperation({
    required String operation,
    required String table,
    required Map<String, dynamic> data,
  }) async {
    switch (operation) {
      case 'create':
        await supabase.from(table).insert(data);
        return;
      case 'update':
        final id = data['id'];
        if (id != null) {
          await supabase.from(table).update(data).eq('id', id as Object);
        }
        return;
      case 'delete':
        final id = data['id'];
        if (id != null) {
          await supabase.from(table).delete().eq('id', id as Object);
        }
        return;
      default:
        return;
    }
  }

  /// Simulate going offline (for testing)
  void setOffline() => updateStatus(ConnectivityStatus.offline);

  /// Simulate going online (for testing)
  void setOnline() => updateStatus(ConnectivityStatus.online);

  void dispose() {
    _statusController.close();
  }
}
