import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'theme_bootstrap.dart';

const _kThemeModeKey = 'theme_mode';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final boot = pendingBootstrapThemeMode ?? ThemeMode.light;
    pendingBootstrapThemeMode = null;
    Future.microtask(_reconcileWithPrefs);
    return boot;
  }

  Future<void> _reconcileWithPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_kThemeModeKey);
    final mode = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
    if (state != mode) state = mode;
  }

  Future<void> toggle() async {
    final next = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setTheme(next);
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kThemeModeKey,
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}

final themeProvider = NotifierProvider<ThemeNotifier, ThemeMode>(
  ThemeNotifier.new,
);
