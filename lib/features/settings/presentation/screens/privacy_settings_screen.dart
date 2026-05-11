import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() =>
      _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  bool _locationEnabled = false;
  bool _searchVisible = true;
  String _visibilityLevel = 'public';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Settings')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Profile Visibility'),
          RadioGroup<String>(
            groupValue: _visibilityLevel,
            onChanged: (v) => setState(() => _visibilityLevel = v!),
            child: const Column(
              children: [
                RadioListTile<String>(
                  title: Text('Public'),
                  subtitle: Text('Anyone can see your profile'),
                  value: 'public',
                ),
                RadioListTile<String>(
                  title: Text('Friends Only'),
                  subtitle: Text('Only followers can see your profile'),
                  value: 'friends',
                ),
                RadioListTile<String>(
                  title: Text('Private'),
                  subtitle: Text('Only you can see your profile'),
                  value: 'private',
                ),
              ],
            ),
          ),
          const Divider(),
          const _SectionHeader(title: 'Location'),
          SwitchListTile(
            title: const Text('Enable Location'),
            subtitle: const Text('Allow location tagging in posts'),
            value: _locationEnabled,
            onChanged: (v) => setState(() => _locationEnabled = v),
          ),
          const Divider(),
          const _SectionHeader(title: 'Discovery'),
          SwitchListTile(
            title: const Text('Visible in Search'),
            subtitle: const Text(
              'Allow your profile to appear in search results',
            ),
            value: _searchVisible,
            onChanged: (v) => setState(() => _searchVisible = v),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Privacy settings saved')),
                );
                context.pop();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Save Settings'),
              ),
            ),
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
