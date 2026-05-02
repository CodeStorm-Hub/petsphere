// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_driver/driver_extension.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// import 'package:marionette_flutter/marionette_flutter.dart';
import 'controllers/bootstrap_controller.dart';
import 'utils/routes.dart';
import 'utils/supabase_config.dart';
import 'theme/app_theme_v2_material3.dart';

Future<void> main() async {
  enableFlutterDriverExtension();
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

    // Materialise the bootstrap side-effect provider so it can register its
    // auth listener and auto-hydrate all data sources whenever the user
    // becomes authenticated (cold start with a saved session, or fresh
    // login). Manual refresh on each screen still works as before.
    ref.watch(bootstrapProvider);

    return MaterialApp.router(
      title: 'PetSphere',
      theme: AppThemeV2.darkTheme,
      darkTheme: AppThemeV2.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: goRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
