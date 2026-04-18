import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/routes.dart';
import 'utils/supabase_config.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _configureDebugImageCache();

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const ProviderScope(child: PetSphereApp()));
}

void _configureDebugImageCache() {
  // Emulator-friendly defaults: keep debug memory usage predictable for image-heavy screens.
  if (!kDebugMode || defaultTargetPlatform != TargetPlatform.android) return;

  final imageCache = PaintingBinding.instance.imageCache;
  imageCache.maximumSize = 100;
  imageCache.maximumSizeBytes = 32 << 20; // 32 MB
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
