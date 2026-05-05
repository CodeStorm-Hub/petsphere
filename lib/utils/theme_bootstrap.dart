import 'package:flutter/material.dart';

/// Set from [main] after SharedPreferences load so [ThemeNotifier] uses the
/// correct mode on the first frame (avoids light-then-dark flash).
ThemeMode? pendingBootstrapThemeMode;
