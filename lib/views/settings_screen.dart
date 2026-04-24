import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/auth_controller.dart';
import '../controllers/notification_controller.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final unread =
        ref.watch(notificationProvider.select((s) => s.unreadCount));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader(label: 'Account'),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primary.withAlpha(30),
              backgroundImage: user?.profileImageUrl != null &&
                      user!.profileImageUrl!.isNotEmpty
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user?.profileImageUrl == null ||
                      user!.profileImageUrl!.isEmpty
                  ? Text(user?.initials ?? '?',
                      style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold))
                  : null,
            ),
            title: Text(user?.name ?? 'Guest'),
            subtitle: Text(user?.email ?? ''),
          ),
          const Divider(),
          _SectionHeader(label: 'Preferences'),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Notifications'),
            subtitle: Text(unread > 0 ? '$unread unread' : 'All caught up'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Liked pets'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/liked_pets'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('Order history'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/orders'),
          ),
          const Divider(),
          _SectionHeader(label: 'About'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () =>
                launchUrl(Uri.parse('https://petsphere.app/privacy')),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => launchUrl(Uri.parse('https://petsphere.app/terms')),
          ),
          ListTile(
            leading: const Icon(Icons.support_outlined),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () =>
                launchUrl(Uri.parse('mailto:support@petsphere.app')),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App version'),
            subtitle: const Text('1.0.0'),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: FilledButton.icon(
              onPressed: () => _confirmLogout(context, ref),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: colorScheme.errorContainer,
                foregroundColor: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.redAccent),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
