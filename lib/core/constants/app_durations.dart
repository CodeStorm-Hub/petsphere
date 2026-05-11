/// Application-wide duration constants
/// Extracted from controllers to ensure consistency and ease of tuning
library;

class AppDurations {
  // Network timeouts
  static const Duration authTimeout = Duration(seconds: 15);
  static const Duration defaultNetworkTimeout = Duration(seconds: 12);
  static const Duration imageUploadTimeout = Duration(seconds: 60);
  static const Duration realtimeSubscriptionTimeout = Duration(seconds: 10);

  // Debounce delays
  static const Duration searchDebounce = Duration(milliseconds: 500);
  static const Duration formDebounce = Duration(milliseconds: 300);

  // UI animations
  static const Duration snackbarDuration = Duration(seconds: 4);
  static const Duration dialogAnimationDuration = Duration(milliseconds: 300);
  static const Duration transitionDuration = Duration(milliseconds: 500);

  // Cache durations
  static const Duration notificationCacheDuration = Duration(minutes: 5);
  static const Duration userProfileCacheDuration = Duration(minutes: 10);
  static const Duration petListCacheDuration = Duration(minutes: 5);

  // Retry delays
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration maxRetryDelay = Duration(seconds: 30);

  // Poll intervals
  static const Duration pollInterval = Duration(seconds: 30);
  static const Duration healthCheckInterval = Duration(minutes: 1);

  // Realtime subscription heartbeat
  static const Duration realtimeHeartbeat = Duration(seconds: 30);
}
