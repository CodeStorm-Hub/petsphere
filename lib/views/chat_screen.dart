import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/chat_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/pet_controller.dart';
import '../utils/pet_navigation.dart';
import 'components/message_bubble.dart';

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
      ref.read(chatProvider.notifier).markThreadAsRead(widget.threadId);
      ref.read(notificationProvider.notifier).markMessagesAsRead();
      // If the thread list hasn't included this thread yet (e.g. navigated
      // directly via the Message button before the list refreshed), force a
      // refresh so the app bar can resolve the other pet's name and avatar.
      if (!ref.read(chatProvider).threads.any((t) => t.id == widget.threadId)) {
        ref.read(chatProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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

    // Find the thread from the list
    final threadList = chatState.threads.where((t) => t.id == widget.threadId);
    if (threadList.isEmpty) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    final thread = threadList.first;
    final otherPet = thread.participantPets.firstWhere(
      (p) => p.id != myPetId,
      orElse: () => thread.participantPets.first,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFFEF8F3),
      appBar: AppBar(
        backgroundColor: const Color(0xCCFEF8F3),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () => openPetProfile(
            context,
            ref,
            petId: otherPet.id,
            petUserId: otherPet.userId,
          ),
          child: Row(
            children: [
              // Avatar with online indicator
              Stack(
                children: [
                  CircleAvatar(
                    backgroundImage: otherPet.profileImageUrl.isNotEmpty
                        ? NetworkImage(otherPet.profileImageUrl)
                        : null,
                    radius: 20,
                    backgroundColor: const Color(0xFFE5FDE6),
                    child: otherPet.profileImageUrl.isEmpty
                        ? Text(otherPet.name[0], style: const TextStyle(color: Color(0xFF506453)))
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAD04B),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFEF8F3), width: 2),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    otherPet.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: Color(0xFF35322D),
                      letterSpacing: -0.3,
                    ),
                  ),
                  const Text(
                    'ONLINE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF506453),
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF35322D)),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.read(threadMessagesProvider.notifier).init(widget.threadId);
              },
              child: messages.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child: Column(
                            children: [
                              Container(
                                width: 72,
                                height: 72,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE5FDE6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.chat_bubble_outline, size: 32, color: Color(0xFF506453)),
                              ),
                              const SizedBox(height: 16),
                              const Text('Say hello! 👋',
                                  style: TextStyle(color: Color(0xFF625E59), fontSize: 16, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final msg = messages[index];
                        final isMe = msg.senderPetId == myPetId;
                        final showSeparator = index == 0 ||
                            !_isSameDay(messages[index - 1].createdAt, msg.createdAt);

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showSeparator) DateSeparator(date: msg.createdAt),
                            MessageBubble(message: msg, isMe: isMe),
                          ],
                        );
                      },
                    ),
            ),
          ),

          // ── Floating pill input ──────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              12,
              8,
              12,
              8 + MediaQuery.of(context).padding.bottom,
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(999),
                boxShadow: const [
                  BoxShadow(color: Color(0x1F000000), blurRadius: 16, offset: Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  // Attachment button with tertiary-container bg
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Attachment support coming soon')),
                    ),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: Color(0xFFE5FDE6),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, color: Color(0xFF506453), size: 22),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        filled: false,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      textInputAction: TextInputAction.send,
                    ),
                  ),
                  // Send button with gradient
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF99472C), Color(0xFFFFAD93)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
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
