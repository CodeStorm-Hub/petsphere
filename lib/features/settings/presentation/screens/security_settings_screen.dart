import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() => _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState extends ConsumerState<SecuritySettingsScreen> {
  bool _mfaEnabled = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Security')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Authentication'),
          ListTile(
            leading: const Icon(Icons.password_outlined),
            title: const Text('Change Password'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/change_password'),
          ),
          ListTile(
            leading: const Icon(Icons.security_outlined),
            title: const Text('Two-Factor Authentication'),
            subtitle: Text(_mfaEnabled ? 'Enabled' : 'Not enabled'),
            trailing: Switch(
              value: _mfaEnabled,
              onChanged: (v) {
                if (v) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('MFA setup coming soon')),
                  );
                } else {
                  setState(() => _mfaEnabled = v);
                }
              },
            ),
          ),
          const Divider(),
          const _SectionHeader(title: 'Sessions'),
          ListTile(
            leading: const Icon(Icons.devices_outlined),
            title: const Text('Active Sessions & Devices'),
            subtitle: const Text('Manage logged-in devices'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Session management coming soon')),
              );
            },
          ),
          const Divider(),
          const _SectionHeader(title: 'Account'),
          ListTile(
            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
            title: Text('Delete Account', style: TextStyle(color: theme.colorScheme.error)),
            subtitle: const Text('Permanently remove your account and data'),
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion requires email confirmation. Please contact support.')),
              );
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: Theme.of(context).colorScheme.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}