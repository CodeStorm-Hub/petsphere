import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/connectivity_service.dart';

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
  return service.statusStream;
});

/// Convenience: whether device is currently online
/// Optimized using .select to only rebuild when the status changes to/from online
final isOnlineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityStatusProvider).asData?.value ?? ConnectivityStatus.unknown;
  return status == ConnectivityStatus.online;
});

/// Convenience: whether device is currently offline
final isOfflineProvider = Provider<bool>((ref) {
  final status = ref.watch(connectivityStatusProvider).asData?.value ?? ConnectivityStatus.unknown;
  return status == ConnectivityStatus.offline;
});
