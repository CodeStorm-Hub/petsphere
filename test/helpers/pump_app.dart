// ignore_for_file: always_specify_types

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Pumps a widget wrapped in the minimal app scaffolding required for
/// PetFolio widget tests: [MaterialApp] + [ProviderScope].
///
/// Usage:
/// ```dart
/// await tester.pumpApp(const MyWidget());
/// ```
extension PumpApp on WidgetTester {
  Future<void> pumpApp(
    Widget widget, {
    // ignore: avoid_annotating_with_dynamic
    List<dynamic> overrides = const [],
    ThemeData? theme,
  }) {
    return pumpWidget(
      ProviderScope(
        overrides: overrides.cast(),
        child: MaterialApp(
          theme: theme ?? ThemeData.light(useMaterial3: true),
          home: Scaffold(body: widget),
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
