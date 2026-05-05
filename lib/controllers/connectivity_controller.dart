import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/connectivity_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Single instance of ConnectivityService
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

/// Stream of connectivity status changes
final connectivityStreamProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream;
});

/// Current connectivity status (watch this to rebuild on connectivity changes)
final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream.asBroadcastStream();
});

/// Convenience: whether device is currently online
final isOnlineProvider = Provider<bool>((ref) {
  final stream = ref.watch(connectivityStreamProvider);
  return stream.whenData((status) => status == ConnectivityStatus.online)
      .maybeWhen(
        data: (isOnline) => isOnline,
        orElse: () => false,
      );
});

/// Convenience: whether device is currently offline
final isOfflineProvider = Provider<bool>((ref) {
  final stream = ref.watch(connectivityStreamProvider);
  return stream.whenData((status) => status == ConnectivityStatus.offline)
      .maybeWhen(
        data: (isOffline) => isOffline,
        orElse: () => false,
      );
});
