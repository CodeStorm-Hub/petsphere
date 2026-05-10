import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:petfolio/features/notifications/presentation/controllers/notification_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final dtFmt = DateFormat('MMM d · h:mm a');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.read(notificationProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            tooltip: 'Mark all read',
            onPressed: () =>
                ref.read(notificationProvider.notifier).markAllAsRead(),
            icon: const Icon(Icons.done_all),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.items.isEmpty
              ? Center(
                  child: Text(
                    'No notifications yet',
                    style: TextStyle(color: cs.onSurfaceVariant),
                  ),
                )
              : ListView.separated(
                  itemCount: state.items.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final n = state.items[index];
                    final title = n.title.isEmpty ? 'Notification' : n.title;
                    final subtitle = n.body ?? '';

                    return ListTile(
                      leading: Icon(
                        n.isRead
                            ? Icons.notifications_none
                            : Icons.notifications_active,
                        color: n.isRead ? cs.onSurfaceVariant : cs.primary,
                      ),
                      title: Text(title),
                      subtitle: Text(
                        subtitle.isEmpty ? n.type : subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        dtFmt.format(n.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      onTap: () async {
                        await ref
                            .read(notificationProvider.notifier)
                            .markAsRead(n.id);
                      },
                    );
                  },
                ),
    );
  }
}

