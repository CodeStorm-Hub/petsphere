import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petsphere/core/services/connectivity_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Single instance of ConnectivityService
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Stream of connectivity status changes (Broadcast stream for multiple listeners)
final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream.asBroadcastStream();
});

/// Convenience: whether device is currently online
final isOnlineProvider = Provider<bool>((ref) {
  final stream = ref.watch(connectivityStatusProvider);
  return stream
      .whenData((status) => status == ConnectivityStatus.online)
      .maybeWhen(data: (isOnline) => isOnline, orElse: () => false);
});

/// Convenience: whether device is currently offline
final isOfflineProvider = Provider<bool>((ref) {
  final stream = ref.watch(connectivityStatusProvider);
  return stream
      .whenData((status) => status == ConnectivityStatus.offline)
      .maybeWhen(data: (isOffline) => isOffline, orElse: () => false);
});
