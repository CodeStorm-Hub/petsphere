import 'dart:async';

/// Simple connectivity status for PetSphere.
enum ConnectivityStatus {
  online,
  offline,
  unknown,
}

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
  void _onOnlineRestored() {
    // TODO: Trigger sync of queued operations
  }

  /// Simulate going offline (for testing)
  void setOffline() => updateStatus(ConnectivityStatus.offline);

  /// Simulate going online (for testing)
  void setOnline() => updateStatus(ConnectivityStatus.online);

  void dispose() {
    _statusController.close();
  }
}
