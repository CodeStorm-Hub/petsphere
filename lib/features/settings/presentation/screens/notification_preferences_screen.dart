import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class NotificationPreferencesScreen extends ConsumerStatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  ConsumerState<NotificationPreferencesScreen> createState() => _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState extends ConsumerState<NotificationPreferencesScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _likesEnabled = true;
  bool _commentsEnabled = true;
  bool _followersEnabled = true;
  bool _matchesEnabled = true;
  bool _messagesEnabled = true;
  bool _careRemindersEnabled = true;
  bool _marketingEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Preferences')),
      body: ListView(
        children: [
          const _SectionHeader(title: 'Channel'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive notifications on your device'),
            value: _pushEnabled,
            onChanged: (v) => setState(() => _pushEnabled = v),
          ),
          SwitchListTile(
            title: const Text('Email Notifications'),
            subtitle: const Text('Receive notifications via email'),
            value: _emailEnabled,
            onChanged: (v) => setState(() => _emailEnabled = v),
          ),
          const Divider(),
          const _SectionHeader(title: 'Social'),
          SwitchListTile(
            title: const Text('Likes'),
            subtitle: const Text('When someone likes your post'),
            value: _likesEnabled,
            onChanged: (v) => setState(() => _likesEnabled = v),
          ),
          SwitchListTile(
            title: const Text('Comments'),
            subtitle: const Text('When someone comments on your post'),
            value: _commentsEnabled,
            onChanged: (v) => setState(() => _commentsEnabled = v),
          ),
          SwitchListTile(
            title: const Text('Followers'),
            subtitle: const Text('When someone follows you or your pet'),
            value: _followersEnabled,
            onChanged: (v) => setState(() => _followersEnabled = v),
          ),
          const Divider(),
          const _SectionHeader(title: 'Connections'),
          SwitchListTile(
            title: const Text('New Matches'),
            subtitle: const Text('When you get a new match'),
            value: _matchesEnabled,
            onChanged: (v) => setState(() => _matchesEnabled = v),
          ),
          SwitchListTile(
            title: const Text('Messages'),
            subtitle: const Text('When you receive a new message'),
            value: _messagesEnabled,
            onChanged: (v) => setState(() => _messagesEnabled = v),
          ),
          const Divider(),
          const _SectionHeader(title: 'Care'),
          SwitchListTile(
            title: const Text('Care Reminders'),
            subtitle: const Text('Daily care tasks and medication reminders'),
            value: _careRemindersEnabled,
            onChanged: (v) => setState(() => _careRemindersEnabled = v),
          ),
          const Divider(),
          const _SectionHeader(title: 'Marketing'),
          SwitchListTile(
            title: const Text('Promotional Emails'),
            subtitle: const Text('Updates, offers, and news from PetFolio'),
            value: _marketingEnabled,
            onChanged: (v) => setState(() => _marketingEnabled = v),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preferences saved')),
                );
                context.pop();
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('Save Preferences'),
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