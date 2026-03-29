import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/chat_controller.dart';
import '../controllers/feed_controller.dart'; // Source of my id
import 'components/message_bubble.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String threadId;

  const ChatScreen({super.key, required this.threadId});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textController = TextEditingController();

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      final myPetId = mockPets[0].id;
      ref.read(chatProvider.notifier).sendMessage(widget.threadId, myPetId, _textController.text);
      _textController.clear();
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);
    final messages = chatState.messages[widget.threadId] ?? [];
    
    // Find thread securely
    final threadList = chatState.threads.where((t) => t.id == widget.threadId);
    if (threadList.isEmpty) return const Scaffold(body: Center(child: Text('Thread not found')));
    final thread = threadList.first;

    final myPetId = mockPets[0].id;
    final otherPet = thread.participantPets.firstWhere((p) => p.id != myPetId);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(otherPet.profileImageUrl),
              radius: 16,
            ),
            const SizedBox(width: 8),
            Text(otherPet.name),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: false, // In a real app we'd reverse it or handle scrolling natively
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final isMe = msg.senderPetId == myPetId;
                return MessageBubble(message: msg, isMe: isMe);
              },
            ),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(color: Colors.grey.shade200, blurRadius: 4, offset: const Offset(0, -2))
                ]
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
                    onPressed: _sendMessage,
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
