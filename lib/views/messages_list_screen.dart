import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/chat_controller.dart';
import '../controllers/pet_controller.dart';
import '../controllers/notification_controller.dart';
import 'components/chat_thread_tile.dart';

class MessagesListScreen extends ConsumerStatefulWidget {
  const MessagesListScreen({super.key});

  @override
  ConsumerState<MessagesListScreen> createState() => _MessagesListScreenState();
}

class _MessagesListScreenState extends ConsumerState<MessagesListScreen> {
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
  Widget build(BuildContext context) {
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
