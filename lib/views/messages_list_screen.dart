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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: threads.isEmpty
          ? const Center(child: Text('No messages yet. Match with pets to chat!'))
          : ListView.separated(
              itemCount: threads.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final thread = threads[index];
                return ChatThreadTile(
                  thread: thread,
                  myPetId: myCurrentPetId,
                  onTap: () {
                     ref.read(chatProvider.notifier).markThreadAsRead(thread.id);
                     context.push('/chat/${thread.id}');
                  },
                );
              },
            ),
    );
  }
}
