import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petfolio/core/theme/theme_controller.dart';
import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final user = auth.user;
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark mode'),
                value: isDark,
                onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
              ),
              if (user != null)
                ListTile(
                  title: const Text('Signed in as'),
                  subtitle: Text(user.email),
                ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Sign out'),
                onTap: () => ref.read(authProvider.notifier).logout(),
              ),
            ],
          ),
        ),
      ),
    );

  }
}
