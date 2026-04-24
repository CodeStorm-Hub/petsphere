import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/routes.dart';
import 'utils/supabase_config.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
    throw StateError(
      'Missing Supabase configuration. Provide SUPABASE_URL and SUPABASE_ANON_KEY via --dart-define or --dart-define-from-file.',
    );
  }

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  runApp(const ProviderScope(child: PetSphereApp()));
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
