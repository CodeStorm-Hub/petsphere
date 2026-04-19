import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pet_dating_app/controllers/chat_controller.dart';
import 'package:pet_dating_app/controllers/pet_controller.dart';
import 'package:pet_dating_app/views/components/chat_thread_tile.dart';

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
      body: RefreshIndicator(
        onRefresh: () => ref.read(chatProvider.notifier).refresh(),
        child: threads.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No messages yet. Match with pets to chat!')),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
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
      ),
    );
  }
}
