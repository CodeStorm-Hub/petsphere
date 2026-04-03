import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'utils/routes.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    // Wrap the entire app in a ProviderScope
    const ProviderScope(
      child: PetSphereApp(),
    ),
  );
}

class PetSphereApp extends ConsumerWidget {
  const PetSphereApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the routerProvider to get the navigation configuration
    final goRouter = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'PetSphere',
      theme: AppTheme.lightTheme,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
