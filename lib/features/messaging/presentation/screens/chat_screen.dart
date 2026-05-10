import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petfolio/features/messaging/presentation/controllers/chat_controller.dart';
import 'package:petfolio/features/notifications/presentation/controllers/notification_controller.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:petfolio/core/utils/pet_navigation.dart';
import 'package:petfolio/features/messaging/presentation/widgets/message_bubble.dart';
import 'package:petfolio/core/widgets/skeleton_loader.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      unawaited(ref.read(threadMessagesProvider.notifier).init(widget.threadId));
      unawaited(ref.read(chatProvider.notifier).markThreadAsRead(widget.threadId));
      unawaited(ref.read(notificationProvider.notifier).markMessagesAsRead());

      var chats = ref.read(chatProvider);
      if (!chats.threads.any((t) => t.id == widget.threadId)) {
        await ref.read(chatProvider.notifier).refresh();
      }
      chats = ref.read(chatProvider);
      if (!chats.threads.any((t) => t.id == widget.threadId)) {
        await ref
            .read(chatProvider.notifier)
            .ensureThreadLoaded(widget.threadId);
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
    showModalBottomSheet<void>(
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
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                          content: const Text(
                            'Gallery sharing coming soon 🖼️',
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                          content: const Text(
                            'Document sharing coming soon 📄',
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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

    // Find the thread from the list (or merge via ensureThreadLoaded in initState).
    final threadList = chatState.threads.where((t) => t.id == widget.threadId);
    if (threadList.isEmpty) {
      if (chatState.isLoading) {
        return const Scaffold(body: ChatSkeletonLoader());
      }
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: const Text('Chat'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 48,
                  color: colorScheme.outline,
                ),
                const SizedBox(height: 16),
                Text(
                  chatState.error ??
                      'Could not load this conversation. Check your connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () async {
                    await ref.read(chatProvider.notifier).refresh();
                    await ref
                        .read(chatProvider.notifier)
                        .ensureThreadLoaded(widget.threadId);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
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
        title: Semantics(
          label: 'Conversation with ${otherPet.name}. Tap to view profile.',
          button: true,
          child: GestureDetector(
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
                          ? Text(
                              otherPet.name[0],
                              style: TextStyle(color: colorScheme.onTertiary),
                            )
                          : null,
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
                    if (otherPet.breed.isNotEmpty)
                      Text(
                        otherPet.breed,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          Semantics(
            label: 'Conversation options',
            button: true,
            child: IconButton(
              tooltip: 'More options',
              icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(threadMessagesProvider.notifier).init(widget.threadId);
              },
              child: messages.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 120),
                        Center(
                          child:
                              Column(
                                    children: [
                                      Container(
                                        width: 72,
                                        height: 72,
                                        decoration: BoxDecoration(
                                          color: colorScheme.tertiaryContainer,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.chat_bubble_outline,
                                          size: 32,
                                          color: colorScheme.onTertiary,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Say hello! 👋',
                                        style: TextStyle(
                                          color: colorScheme.onSurfaceVariant,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  )
                                  .animate()
                                  .fadeIn(duration: 600.ms)
                                  .scale(
                                    begin: const Offset(0.8, 0.8),
                                    curve: Curves.easeOutBack,
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
                        final showSeparator =
                            index == 0 ||
                            !_isSameDay(
                              messages[index - 1].createdAt,
                              msg.createdAt,
                            );

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showSeparator)
                              DateSeparator(date: msg.createdAt),
                            MessageBubble(message: msg, isMe: isMe)
                                .animate()
                                .fadeIn(duration: 400.ms)
                                .slideX(
                                  begin: isMe ? 0.1 : -0.1,
                                  curve: Curves.easeOutQuad,
                                ),
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
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerLowest.withAlpha(180),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: colorScheme.outline.withAlpha(80),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(20),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Attachment button — shows bottom sheet
                      Semantics(
                        label: 'Attach file',
                        button: true,
                        child: IconButton(
                          onPressed: () =>
                              _showAttachmentSheet(context, colorScheme),
                          tooltip: 'Attach file',
                          style: IconButton.styleFrom(
                            backgroundColor: colorScheme.tertiaryContainer,
                            foregroundColor: colorScheme.onTertiary,
                            padding: const EdgeInsets.all(10),
                          ),
                          icon: const Icon(Icons.add, size: 24),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _textController,
                          decoration: const InputDecoration(
                            hintText: 'Message...',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
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
                            ? Semantics(
                                label: 'Send message',
                                button: true,
                                child: IconButton(
                                  key: const ValueKey('send'),
                                  onPressed: _sendMessage,
                                  tooltip: 'Send message',
                                  style: IconButton.styleFrom(
                                    backgroundColor: colorScheme.primary,
                                    foregroundColor: colorScheme.onPrimary,
                                    padding: const EdgeInsets.all(10),
                                  ),
                                  icon: const Icon(Icons.send_rounded, size: 20),
                                ),
                              )
                            : Semantics(
                                label: 'Voice message',
                                button: true,
                                child: IconButton(
                                  key: const ValueKey('mic'),
                                  onPressed: () => ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Voice messages coming soon 🎤',
                                      ),
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                  tooltip: 'Voice message',
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        colorScheme.surfaceContainerHighest,
                                    foregroundColor: colorScheme.onSurfaceVariant,
                                    padding: const EdgeInsets.all(10),
                                  ),
                                  icon: const Icon(Icons.mic_none_rounded,
                                      size: 22),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
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
    return Semantics(
      label: label,
      button: true,
      child: GestureDetector(
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
      ),
    );
  }
}

