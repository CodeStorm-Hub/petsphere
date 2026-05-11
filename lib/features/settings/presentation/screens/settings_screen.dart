import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:petfolio/core/theme/theme_controller.dart';
import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/core/constants/app_routes.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final themeMode = ref.watch(themeProvider);
    final user = auth.user;
    final isDark = themeMode == ThemeMode.dark;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.symmetric(vertical: 16),
            children: [
              if (user != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: cs.primaryContainer,
                        child: Text(
                          user.initials,
                          style: tt.headlineSmall?.copyWith(color: cs.onPrimaryContainer),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(user.name ?? 'Pet Parent', style: tt.titleLarge),
                            Text(user.email, style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
              
              const _SectionHeader(title: 'Account'),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Edit Owner Profile'),
                subtitle: const Text('Name, email, phone, bio'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.link),
                title: const Text('Linked Providers'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),

              const _SectionHeader(title: 'Security'),
              ListTile(
                leading: const Icon(Icons.password_outlined),
                title: const Text('Password'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.security_outlined),
                title: const Text('Two-Factor Authentication (MFA)'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.devices_outlined),
                title: const Text('Active Sessions & Devices'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),

              const _SectionHeader(title: 'Pets'),
              ListTile(
                leading: const Icon(Icons.pets_outlined),
                title: const Text('Manage Pets'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () => context.push(AppRoutes.managePets),
              ),
              ListTile(
                leading: const Icon(Icons.visibility_outlined),
                title: const Text('Pet Visibility'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.health_and_safety_outlined),
                title: const Text('Health Sharing Permissions'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),

              const _SectionHeader(title: 'Notifications'),
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: const Text('Push Notifications'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined),
                title: const Text('Email Notifications'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.alarm_outlined),
                title: const Text('Reminders & Digests'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),

              const _SectionHeader(title: 'Privacy'),
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Profile Visibility'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.location_on_outlined),
                title: const Text('Location Sharing'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.block_outlined),
                title: const Text('Blocked Users'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),

              const _SectionHeader(title: 'Safety'),
              ListTile(
                leading: const Icon(Icons.report_outlined),
                title: const Text('Report History'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.filter_alt_outlined),
                title: const Text('Content Filters'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),

              const _SectionHeader(title: 'Commerce'),
              ListTile(
                leading: const Icon(Icons.local_shipping_outlined),
                title: const Text('Shipping Addresses'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.payment_outlined),
                title: const Text('Payment Methods'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.history_outlined),
                title: const Text('Order Preferences & History'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),

              const _SectionHeader(title: 'Care Data'),
              ListTile(
                leading: const Icon(Icons.download_outlined),
                title: const Text('Export Records'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.share_outlined),
                title: const Text('Share with Vet'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.delete_sweep_outlined),
                title: const Text('Delete Care Data'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),

              const _SectionHeader(title: 'App'),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                value: isDark,
                onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
              ),
              ListTile(
                leading: const Icon(Icons.language_outlined),
                title: const Text('Language'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.accessibility_new_outlined),
                title: const Text('Accessibility Preferences'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.square_foot_outlined),
                title: const Text('Units'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),

              const _SectionHeader(title: 'Legal'),
              ListTile(
                leading: const Icon(Icons.article_outlined),
                title: const Text('Terms of Service'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined),
                title: const Text('Privacy Policy'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.receipt_long_outlined),
                title: const Text('Open Source Licenses'),
                trailing: const Icon(Icons.chevron_right, size: 20),
                onTap: () {},
              ),

              const SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.delete_forever, color: cs.error),
                title: Text('Delete Account', style: TextStyle(color: cs.error)),
                onTap: () {},
              ),
              ListTile(
                leading: Icon(Icons.logout, color: cs.error),
                title: Text('Sign Out', style: TextStyle(color: cs.error, fontWeight: FontWeight.bold)),
                onTap: () => ref.read(authProvider.notifier).logout(),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }
}
