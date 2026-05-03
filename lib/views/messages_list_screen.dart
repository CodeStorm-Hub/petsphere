import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../controllers/chat_controller.dart';
import '../controllers/pet_controller.dart';
import '../controllers/notification_controller.dart';
import '../models/chat_thread_model.dart';
import '../utils/pet_navigation.dart';

class MessagesListScreen extends ConsumerStatefulWidget {
  const MessagesListScreen({super.key});

  @override
  ConsumerState<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends ConsumerState<MessagesListScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(notificationProvider.notifier).markMessagesAsRead();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final myCurrentPetId = ref.watch(activePetProvider)?.id ?? '';
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    final allThreads = chatState.threads;
    final threads = _searchQuery.isEmpty
        ? allThreads
        : allThreads.where((t) {
            final other = t.participantPets.firstWhere(
              (p) => p.id != myCurrentPetId,
              orElse: () => t.participantPets.first,
            );
            return other.name.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleSpacing: 16,
        title: Text(
          'Messages',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
            onPressed: () => ref.read(chatProvider.notifier).refresh(),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _searchQuery = v),
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Search messages...',
                hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                prefixIcon: Icon(Icons.search, color: colorScheme.onSurfaceVariant, size: 20),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, size: 18, color: colorScheme.onSurfaceVariant),
                        onPressed: () => setState(() {
                          _searchController.clear();
                          _searchQuery = '';
                        }),
                      )
                    : null,
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest.withAlpha(160),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(chatProvider.notifier).refresh(),
        child: chatState.isLoading && allThreads.isEmpty
            ? _buildShimmer(colorScheme)
            : threads.isEmpty
                ? _buildEmpty(context, colorScheme, allThreads.isEmpty)
                : ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: threads.length,
                    itemBuilder: (context, index) {
                      final thread = threads[index];
                      return _ThreadTile(
                        thread: thread,
                        myPetId: myCurrentPetId,
                        onTap: () {
                          ref.read(chatProvider.notifier).markThreadAsRead(thread.id);
                          context.push('/chat/${thread.id}');
                        },
                        onAvatarTap: () {
                          final other = thread.participantPets.firstWhere(
                            (p) => p.id != myCurrentPetId,
                            orElse: () => thread.participantPets.first,
                          );
                          openPetProfile(context, ref,
                              petId: other.id, petUserId: other.userId);
                        },
                      );
                    },
                  ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, ColorScheme colorScheme, bool trulyEmpty) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer.withAlpha(80),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  trulyEmpty ? Icons.chat_bubble_outline_rounded : Icons.search_off_rounded,
                  size: 36,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                trulyEmpty ? 'No messages yet' : 'No results found',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                trulyEmpty
                    ? 'Match with pets to start chatting!'
                    : 'Try a different name',
                style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildShimmer(ColorScheme colorScheme) {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context0, index0) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 14,
                    width: 120,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 12,
                    width: 200,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withAlpha(150),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThreadTile extends ConsumerWidget {
  final ChatThreadModel thread;
  final String myPetId;
  final VoidCallback onTap;
  final VoidCallback onAvatarTap;

  const _ThreadTile({
    required this.thread,
    required this.myPetId,
    required this.onTap,
    required this.onAvatarTap,
  });

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inSeconds < 60) return 'Now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return DateFormat('h:mm a').format(dt);
    if (diff.inDays < 7) return DateFormat('EEE').format(dt);
    return DateFormat('MMM d').format(dt);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otherPet = thread.participantPets.firstWhere(
      (p) => p.id != myPetId,
      orElse: () => thread.participantPets.first,
    );

    final hasUnread = thread.unreadCount > 0;
    final colorScheme = Theme.of(context).colorScheme;
    final lastMsg = thread.lastMessage;
    final timeStr = lastMsg != null ? _formatTime(lastMsg.createdAt) : '';
    final isMyMessage = lastMsg?.senderPetId == myPetId;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            // Avatar
            GestureDetector(
              onTap: onAvatarTap,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: otherPet.profileImageUrl.isNotEmpty
                        ? NetworkImage(otherPet.profileImageUrl)
                        : null,
                    backgroundColor: colorScheme.primaryContainer,
                    child: otherPet.profileImageUrl.isEmpty
                        ? Text(
                            otherPet.name.isNotEmpty ? otherPet.name[0].toUpperCase() : '?',
                            style: TextStyle(
                              color: colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          )
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherPet.name,
                          style: TextStyle(
                            fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 15,
                            color: colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (timeStr.isNotEmpty)
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 12,
                            color: hasUnread
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (isMyMessage)
                        Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: Icon(
                            Icons.done_all,
                            size: 14,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          lastMsg?.text ?? 'Start a conversation...',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: hasUnread
                                ? colorScheme.onSurface
                                : colorScheme.onSurfaceVariant,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            '${thread.unreadCount}',
                            style: TextStyle(
                              color: colorScheme.onPrimary,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
