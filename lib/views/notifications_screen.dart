import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/match_controller.dart';
import '../controllers/notification_controller.dart';
import '../models/match_request_model.dart';
import '../models/notification_model.dart';
import 'components/pet_avatar.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchState = ref.watch(matchProvider);
    final notificationState = ref.watch(notificationProvider);
    final myRequests = matchState.myRequests;
    final notifications = notificationState.notifications;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notificationState.unreadCount > 0)
            TextButton(
              onPressed: () {
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
              child: const Text('Mark all read'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(matchProvider.notifier).refresh();
          await ref.read(notificationProvider.notifier).refresh();
        },
        child: _buildBody(context, ref, myRequests, notifications, notificationState.isLoading),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    List<MatchRequestModel> myRequests,
    List<AppNotificationModel> notifications,
    bool isLoading,
  ) {
    if (isLoading && myRequests.isEmpty && notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (myRequests.isEmpty && notifications.isEmpty) {
      return const Center(child: Text('No notifications yet.'));
    }

    return ListView(
      children: [
        if (myRequests.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Match Requests',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          ...myRequests.map<Widget>((req) {
            final senderPet = req.senderPet;
            if (senderPet == null) return const SizedBox.shrink();

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: PetAvatar(imageUrl: senderPet.profileImageUrl, radius: 24),
              title: Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: senderPet.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const TextSpan(text: ' liked your pet for breeding.'),
                  ],
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: req.status == 'pending'
                    ? Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              ref.read(matchProvider.notifier).acceptRequest(req.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('You matched with ${senderPet.name}!'),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              minimumSize: const Size(0, 36),
                            ),
                            child: const Text('Like Back'),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton(
                            onPressed: () {
                              ref.read(matchProvider.notifier).declineRequest(req.id);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              minimumSize: const Size(0, 36),
                            ),
                            child: const Text('Decline'),
                          ),
                        ],
                      )
                    : Text(
                        req.status == 'matched' ? 'You matched!' : 'Declined',
                        style: TextStyle(
                          color: req.status == 'matched' ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            );
          }),
        ],
        if (notifications.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Activity',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          ...notifications.map(
            (item) => ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Icon(_iconForType(item.type)),
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w700,
                ),
              ),
              subtitle: Text(
                item.body ?? '',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: item.isRead
                  ? null
                  : const Icon(Icons.brightness_1, size: 10, color: Colors.blue),
              onTap: () {
                ref.read(notificationProvider.notifier).markAsRead(item.id);
              },
            ),
          ),
        ],
      ],
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'message':
        return Icons.chat_bubble_outline;
      case 'match_accepted':
      case 'match_request':
        return Icons.favorite_border;
      case 'order_status':
        return Icons.shopping_bag_outlined;
      default:
        return Icons.notifications_none;
    }
  }
}
