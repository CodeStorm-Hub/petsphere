import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:petfolio/features/messaging/data/models/chat_thread_model.dart';
import 'package:petfolio/features/messaging/presentation/controllers/chat_controller.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/core/widgets/petfolio_empty_state.dart';

class MessagesListScreen extends ConsumerStatefulWidget {
  const MessagesListScreen({super.key});

  @override
  ConsumerState<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends ConsumerState<MessagesListScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final activePetId = ref.watch(activePetProvider)?.id;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final timeFmt = DateFormat('h:mm a');

    final threads = _query.trim().isEmpty
        ? chatState.threads
        : chatState.threads.where((t) {
            final other = _otherPet(t, activePetId);
            final name = other?.name ?? 'Chat';
            final last = t.lastMessage?.text ?? '';
            final q = _query.toLowerCase();
            return name.toLowerCase().contains(q) || last.toLowerCase().contains(q);
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () => ref.read(chatProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _query = v),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search conversations',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: chatState.isLoading
                ? const Center(child: CircularProgressIndicator())
                : threads.isEmpty
                    ? const PetfolioEmptyState(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: 'No Messages',
                        message: 'No conversations yet',
                      )
                    : ListView.separated(
                        itemCount: threads.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final thread = threads[index];
                          final other = _otherPet(thread, activePetId);
                          final title = other?.name ?? 'Conversation';
                          final subtitle =
                              thread.lastMessage?.text ?? 'Start a conversation...';
                          final ts = thread.lastMessage?.createdAt;
                          final trailing = ts == null ? null : timeFmt.format(ts);

                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: cs.surfaceContainerHighest,
                              backgroundImage: (other?.profileImageUrl ?? '').isNotEmpty
                                  ? NetworkImage(other!.profileImageUrl)
                                  : null,
                              child: (other?.profileImageUrl ?? '').isEmpty
                                  ? const Icon(Icons.pets)
                                  : null,
                            ),
                            title: Text(
                              title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                if (trailing != null)
                                  Text(
                                    trailing,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                if (thread.unreadCount > 0) ...[
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: cs.primary,
                                      borderRadius: BorderRadius.circular(99),
                                    ),
                                    child: Text(
                                      '${thread.unreadCount}',
                                      style: TextStyle(
                                        color: cs.onPrimary,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            onTap: () async {
                              await ref
                                  .read(chatProvider.notifier)
                                  .markThreadAsRead(thread.id);
                              if (!context.mounted) return;
                              await context.push('/chat/${thread.id}');
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  PetModel? _otherPet(ChatThreadModel t, String? myPetId) {
    if (myPetId == null) return t.participantPets.firstOrNull;
    for (final p in t.participantPets) {
      if (p.id != myPetId) return p;
    }
    return t.participantPets.firstOrNull;
  }
}

extension _FirstOrNull<E> on List<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

