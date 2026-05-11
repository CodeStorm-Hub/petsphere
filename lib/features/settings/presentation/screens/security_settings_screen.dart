import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:petfolio/features/auth/data/auth_repository.dart';

class SecuritySettingsScreen extends ConsumerStatefulWidget {
  const SecuritySettingsScreen({super.key});

  @override
  ConsumerState<SecuritySettingsScreen> createState() =>
      _SecuritySettingsScreenState();
}

class _SecuritySettingsScreenState
    extends ConsumerState<SecuritySettingsScreen> {
  bool _mfaEnabled = false;
  bool _isLoadingMfa = true;
  String? _mfaFactorId;

  @override
  void initState() {
    super.initState();
    _loadMfaState();
  }

  Future<void> _loadMfaState() async {
    try {
      final factors = await authRepository.listMfaFactors();
      if (!mounted) return;
      setState(() {
        _mfaEnabled = factors.totp.isNotEmpty;
        _mfaFactorId = factors.totp.isNotEmpty ? factors.totp.first.id : null;
        _isLoadingMfa = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoadingMfa = false);
    }
  }

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
              onChanged: _isLoadingMfa ? null : _setMfaEnabled,
            ),
          ),
          const Divider(),
          const _SectionHeader(title: 'Sessions'),
          ListTile(
            leading: const Icon(Icons.devices_outlined),
            title: const Text('Active Sessions & Devices'),
            subtitle: const Text('Sign out other logged-in devices'),
            trailing: const Icon(Icons.logout_outlined),
            onTap: _signOutOtherSessions,
          ),
          const Divider(),
          const _SectionHeader(title: 'Account'),
          ListTile(
            leading: Icon(Icons.delete_forever, color: theme.colorScheme.error),
            title: Text(
              'Delete Account',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            subtitle: const Text('Permanently remove your account and data'),
            onTap: () => _showDeleteAccountDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _setMfaEnabled(bool enabled) async {
    if (enabled) {
      await _startMfaEnrollment();
      return;
    }
    await _disableMfa();
  }

  Future<void> _startMfaEnrollment() async {
    setState(() => _isLoadingMfa = true);
    try {
      final enrollment = await authRepository.enrollTotpMfa();
      if (!mounted) return;
      setState(() => _isLoadingMfa = false);
      await _showMfaEnrollmentSheet(enrollment.id, enrollment.totp?.secret);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMfa = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not start MFA setup: $e')));
    }
  }

  Future<void> _showMfaEnrollmentSheet(String factorId, String? secret) async {
    final codeController = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;
        return Padding(
          padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Authenticator Setup',
                style: Theme.of(ctx).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              const Text('Add this setup key to your authenticator app.'),
              const SizedBox(height: 12),
              SelectableText(
                secret ?? 'Open your authenticator app to scan the setup code.',
              ),
              if (secret != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: secret));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Setup key copied')),
                    );
                  },
                  icon: const Icon(Icons.copy_outlined),
                  label: const Text('Copy setup key'),
                ),
              ],
              const SizedBox(height: 16),
              TextField(
                controller: codeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '6-digit code',
                  prefixIcon: Icon(Icons.pin_outlined),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await authRepository.verifyTotpMfa(
                      factorId,
                      codeController.text,
                    );
                    if (!ctx.mounted) return;
                    Navigator.pop(ctx);
                    await _loadMfaState();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Two-factor authentication enabled'),
                      ),
                    );
                  },
                  child: const Text('Verify and Enable'),
                ),
              ),
            ],
          ),
        );
      },
    );
    codeController.dispose();
    await _loadMfaState();
  }

  Future<void> _disableMfa() async {
    final factorId = _mfaFactorId;
    if (factorId == null) return;

    setState(() => _isLoadingMfa = true);
    try {
      await authRepository.unenrollMfa(factorId);
      await _loadMfaState();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Two-factor authentication disabled')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingMfa = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not disable MFA: $e')));
    }
  }

  Future<void> _signOutOtherSessions() async {
    try {
      await authRepository.signOutOtherSessions();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Other sessions signed out')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not sign out other sessions: $e')),
      );
    }
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
                const SnackBar(
                  content: Text(
                    'Account deletion requires email confirmation. Please contact support.',
                  ),
                ),
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
