import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/chat_controller.dart';
import '../controllers/pet_controller.dart';
import 'components/chat_thread_tile.dart';

class MessagesListScreen extends ConsumerWidget {
  const MessagesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);
    final threads = chatState.threads;
    final myCurrentPetId = ref.watch(activePetProvider)?.id ?? '';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: threads.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline, size: 64, color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5)),
                  const SizedBox(height: 16),
                  Text('No messages yet. Match with pets to chat!', style: TextStyle(color: theme.colorScheme.onSurfaceVariant)),
                ]
              )
            )
          : ListView.separated(
              itemCount: threads.length,
              separatorBuilder: (context, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Divider(height: 1, color: theme.colorScheme.surfaceContainerHighest),
              ),
              itemBuilder: (context, index) {
                final thread = threads[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ChatThreadTile(
                    thread: thread,
                    myPetId: myCurrentPetId,
                    onTap: () {
                       ref.read(chatProvider.notifier).markThreadAsRead(thread.id);
                       context.push('/chat/${thread.id}');
                    },
                  ),
                );
              },
            ),
    );
  }
}
