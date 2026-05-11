class AppDurations {
  const AppDurations._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration medium = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration xSlow = Duration(milliseconds: 800);

  static const Duration shimmer = Duration(seconds: 2);
  static const Duration toast = Duration(seconds: 3);
  static const Duration snackbar = Duration(seconds: 4);
}
