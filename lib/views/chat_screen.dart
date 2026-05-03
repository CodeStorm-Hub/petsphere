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

  void _showAttachmentSheet(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: colorScheme.outline.withAlpha(80),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              Text(
                'Share',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _AttachOption(
                    icon: Icons.camera_alt_outlined,
                    label: 'Camera',
                    color: colorScheme.primary,
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Camera sharing coming soon 📷'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                  _AttachOption(
                    icon: Icons.photo_library_outlined,
                    label: 'Gallery',
                    color: colorScheme.secondary,
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Gallery sharing coming soon 🖼️'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                  _AttachOption(
                    icon: Icons.insert_drive_file_outlined,
                    label: 'Document',
                    color: colorScheme.tertiary,
                    onTap: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Text('Document sharing coming soon 📄'),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
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
    final colorScheme = Theme.of(context).colorScheme;

    // Find the thread from the list
    final threadList = chatState.threads.where((t) => t.id == widget.threadId);
    if (threadList.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final thread = threadList.first;
    final otherPet = thread.participantPets.firstWhere(
      (p) => p.id != myPetId,
      orElse: () => thread.participantPets.first,
    );

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colorScheme.surfaceContainerLowest.withAlpha(204),
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
                    backgroundColor: colorScheme.tertiaryContainer,
                    child: otherPet.profileImageUrl.isEmpty
                        ? Text(otherPet.name[0],
                            style: TextStyle(color: colorScheme.onTertiary))
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: colorScheme.surfaceContainerLowest, width: 2),
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
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 17,
                      color: colorScheme.onSurface,
                      letterSpacing: -0.3,
                    ),
                  ),
                  Text(
                    'ONLINE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onTertiary,
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
            icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
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
                                decoration: BoxDecoration(
                                  color: colorScheme.tertiaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.chat_bubble_outline,
                                    size: 32, color: colorScheme.onTertiary),
                              ),
                              const SizedBox(height: 16),
                              Text('Say hello! 👋',
                                  style: TextStyle(
                                      color: colorScheme.onSurfaceVariant,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500)),
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
                            !_isSameDay(
                                messages[index - 1].createdAt, msg.createdAt);

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showSeparator)
                              DateSeparator(date: msg.createdAt),
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
                color: colorScheme.surfaceContainerLowest.withAlpha(230),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withAlpha(31),
                      blurRadius: 16,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  // Attachment button — shows bottom sheet
                  GestureDetector(
                    onTap: () => _showAttachmentSheet(context, colorScheme),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.tertiaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.add,
                          color: colorScheme.onTertiary, size: 22),
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        border: InputBorder.none,
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        filled: false,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                      textInputAction: TextInputAction.send,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  // Send or mic button
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: _textController.text.trim().isNotEmpty
                        ? GestureDetector(
                            key: const ValueKey('send'),
                            onTap: _sendMessage,
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary,
                                    colorScheme.secondary
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.send_rounded,
                                  color: colorScheme.onPrimary, size: 20),
                            ),
                          )
                        : GestureDetector(
                            key: const ValueKey('mic'),
                            onTap: () =>
                                ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                    'Voice messages coming soon 🎤'),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                            ),
                            child: Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: colorScheme.surfaceContainerHighest,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.mic_none_rounded,
                                  color: colorScheme.onSurfaceVariant, size: 22),
                            ),
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

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
