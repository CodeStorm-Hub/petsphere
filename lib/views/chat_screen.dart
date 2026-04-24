import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/chat_controller.dart';
import '../controllers/pet_controller.dart';


class ChatScreen extends ConsumerStatefulWidget {
  final String threadId;

  const ChatScreen({super.key, required this.threadId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Initialize the per-thread messages notifier with real Supabase data + Realtime
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(threadMessagesProvider.notifier).init(widget.threadId);
      // Mark thread as read on open
      ref.read(chatProvider.notifier).markThreadAsRead(widget.threadId);
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    final myPetId = ref.read(activePetProvider)?.id ?? '';
    ref.read(threadMessagesProvider.notifier).sendMessage(myPetId, text);
    _textController.clear();

    // Scroll to bottom after send
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final messages = ref.watch(threadMessagesProvider);
    final myPetId = ref.watch(activePetProvider)?.id ?? '';
    final theme = Theme.of(context);

    // Find the thread from the list
    final threadList = chatState.threads.where((t) => t.id == widget.threadId);
    if (threadList.isEmpty) {
      return Scaffold(
          body: Center(child: CircularProgressIndicator(color: theme.colorScheme.primary)));
    }
    final thread = threadList.first;
    final otherPet = thread.participantPets.firstWhere(
      (p) => p.id != myPetId,
      orElse: () => thread.participantPets.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: otherPet.profileImageUrl.isNotEmpty
                  ? NetworkImage(otherPet.profileImageUrl)
                  : null,
              radius: 18,
              child: otherPet.profileImageUrl.isEmpty
                  ? Text(otherPet.name[0])
                  : null,
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(otherPet.name, style: const TextStyle(fontSize: 16)),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green, // Online indicator
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text('Online', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
<<<<<<< HEAD
            child: messages.isEmpty
                ? Center(
                    child: Text('Say hello to ${otherPet.name}! 👋',
                        style: TextStyle(color: theme.colorScheme.onSurfaceVariant)))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderPetId == myPetId;
                      return _AmberMessageBubble(text: msg.text, isMe: isMe);
                    },
                  ),
=======
            child: RefreshIndicator(
              onRefresh: () async {
                ref.read(threadMessagesProvider.notifier).init(widget.threadId);
              },
              child: messages.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 120),
                        Center(
                          child: Text('Say hello! 👋',
                              style: TextStyle(color: Colors.grey)),
                        ),
                      ],
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderPetId == myPetId;
                        return MessageBubble(message: msg, isMe: isMe);
                      },
                    ),
            ),
>>>>>>> origin/main
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  )
                ],
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {},
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send),
                      color: theme.colorScheme.onPrimary,
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmberMessageBubble extends StatelessWidget {
  final String text;
  final bool isMe;

  const _AmberMessageBubble({required this.text, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12, top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? theme.colorScheme.primary : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: isMe ? const Radius.circular(20) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(20),
          ),
        ),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isMe ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}
