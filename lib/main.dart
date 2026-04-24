import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'utils/routes.dart';
import 'utils/supabase_config.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
