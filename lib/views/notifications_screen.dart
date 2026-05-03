import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/pet_navigation.dart';
import 'package:go_router/go_router.dart';
import '../controllers/chat_controller.dart';
import '../controllers/match_controller.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_model.dart';
import 'components/pet_avatar.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Mark notifications as read automatically upon viewing the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(notificationProvider.notifier).markAllAsRead();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifState = ref.watch(notificationProvider);
    final matchState = ref.watch(matchProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: notifState.unreadCount > 0
                  ? 'Activity (${notifState.unreadCount})'
                  : 'Activity',
            ),
            Tab(
              text: matchState.myRequests.isNotEmpty
                  ? 'Requests (${matchState.myRequests.length})'
                  : 'Requests',
            ),
          ],
        ),
        actions: [],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ActivityTab(),
          _RequestsTab(),
        ],
      ),
    );
  }
}

class _ActivityTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationProvider);

    final items = state.items
        .where((n) => n.type != 'message' && n.type != 'match_request')
        .toList();

    if (state.isLoading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(notificationProvider.notifier).refresh(),
      child: items.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No activity yet.')),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final n = items[index];
                return _NotificationTile(notification: n);
              },
            ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  final NotificationModel notification;
  const _NotificationTile({required this.notification});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    IconData icon;
    Color bg;

    switch (notification.type) {
      case 'match_accepted':
        icon = Icons.favorite;
        bg = colors.primary;
        break;
      case 'message':
        icon = Icons.chat_bubble;
        bg = colors.secondary;
        break;
      case 'order':
      case 'order_status':
        icon = Icons.shopping_bag_rounded;
        bg = colors.tertiary;
        break;
      case 'post_like':
        icon = Icons.favorite;
        bg = colorScheme.error;
        break;
      case 'post_comment':
        icon = Icons.comment;
        bg = colors.secondary;
        break;
      case 'post_share':
        icon = Icons.share;
        bg = colorScheme.secondary;
        break;
      case 'profile_follow':
      case 'pet_follow':
        icon = Icons.person_add;
        bg = Colors.blue;
        break;
      default:
        icon = Icons.notifications;
        bg = colors.primary;
    }

    return ListTile(
      onTap: () async {
        if (!notification.isRead) {
          await ref
              .read(notificationProvider.notifier)
              .markAsRead(notification.id);
        }
        if (!context.mounted) return;
        switch (notification.entityType) {
          case 'message':
            context.push('/messages');
            break;
          case 'match_request':
            context.push('/notifications');
            break;
          case 'post':
            if (notification.entityId != null) {
              context.push('/post/${notification.entityId}');
            }
            break;
          case 'product':
          case 'order':
            context.push('/orders');
            break;
        }
      },
      leading: CircleAvatar(
        backgroundColor: bg.withAlpha(30),
        child: Icon(icon, color: bg),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.w700,
        ),
      ),
      subtitle: notification.body != null
          ? Text(
              notification.body!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(_timeAgo(notification.createdAt),
              style: TextStyle(color: colors.onSurfaceVariant, fontSize: 11)),
          if (!notification.isRead) ...[
            const SizedBox(height: 4),
            Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(color: colors.primary, shape: BoxShape.circle),
            ),
          ],
        ],
      ),
    );
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    return '${(diff.inDays / 7).floor()}w';
  }
}

class _RequestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final matchState = ref.watch(matchProvider);
    final myRequests = matchState.myRequests;

    return RefreshIndicator(
      onRefresh: () => ref.read(matchProvider.notifier).refresh(),
      child: myRequests.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(height: 120),
                Center(child: Text('No new requests.')),
              ],
            )
          : ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: myRequests.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final req = myRequests[index];
                final senderPet = req.senderPet;
                if (senderPet == null) return const SizedBox.shrink();

                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: PetAvatar(
                      imageUrl: senderPet.profileImageUrl, radius: 24),
                  title: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: senderPet.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => openPetProfile(
                                  context,
                                  ref,
                                  petId: senderPet.id,
                                  petUserId: senderPet.userId,
                                ),
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
                                onPressed: () async {
                                  await ref
                                      .read(matchProvider.notifier)
                                      .acceptRequest(req.id);
                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                          'You matched with ${senderPet.name}!'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  minimumSize: const Size(0, 36),
                                ),
                                child: const Text('Like Back'),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton(
                                onPressed: () {
                                  ref
                                      .read(matchProvider.notifier)
                                      .declineRequest(req.id);
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  minimumSize: const Size(0, 36),
                                ),
                                child: const Text('Decline'),
                              ),
                            ],
                          )
                        : req.status == 'matched'
                            ? Row(
                                children: [
                                  Icon(Icons.check_circle,
                                      color: colorScheme.secondary, size: 16),
                                  const SizedBox(width: 6),
                                  Text(
                                    'You matched!',
                                    style: TextStyle(
                                      color: colorScheme.secondary,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  OutlinedButton.icon(
                                    onPressed: () async {
                                      final threadId = await ref
                                          .read(chatProvider.notifier)
                                          .createOrGetThread(senderPet.id);
                                      if (!context.mounted) return;
                                      if (threadId != null) {
                                        context.push('/chat/$threadId');
                                      }
                                    },
                                    icon: const Icon(Icons.chat_bubble_outline,
                                        size: 16),
                                    label: const Text('Message'),
                                    style: OutlinedButton.styleFrom(
                                      minimumSize: const Size(0, 34),
                                    ),
                                  ),
                                ],
                              )
                            : Text(
                                'Declined',
                                style: TextStyle(
                                  color: colorScheme.error,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                  ),
                  trailing: const Icon(Icons.chevron_right),
                );
              },
            ),
    );
  }
}
