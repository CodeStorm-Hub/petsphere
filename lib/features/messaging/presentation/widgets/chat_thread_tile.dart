import 'package:flutter/material.dart';
import 'package:petsphere/features/messaging/data/models/chat_thread_model.dart';
import 'package:petsphere/core/widgets/brand_logo.dart';
import 'package:petsphere/core/utils/pet_navigation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatThreadTile extends ConsumerWidget {
  final ChatThreadModel thread;
  final String myPetId;
  final VoidCallback onTap;

  const ChatThreadTile({
    super.key,
    required this.thread,
    required this.myPetId,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Find the other pet in the conversation
    final otherPet = thread.participantPets.firstWhere(
      (p) => p.id != myPetId,
      orElse: () => thread.participantPets.first,
    );

    final hasUnread = thread.unreadCount > 0;
    final theme = Theme.of(context);

    return Semantics(
      label:
          'Chat with ${otherPet.name}. ${thread.lastMessage != null ? 'Last message: ${thread.lastMessage!.text}.' : 'No messages yet.'} ${hasUnread ? '${thread.unreadCount} unread messages.' : ''}',
      button: true,
      onTap: onTap,
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: GestureDetector(
          onTap: () {
            openPetProfile(
              context,
              ref,
              petId: otherPet.id,
              petUserId: otherPet.userId,
            );
          },
          child: CircleAvatar(
            radius: 28,
            backgroundImage: otherPet.profileImageUrl.isNotEmpty
                ? NetworkImage(otherPet.profileImageUrl)
                : null,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            child: otherPet.profileImageUrl.isEmpty
                ? const BrandLogo(size: BrandLogoSize.small)
                : null,
          ),
        ),
        title: Text(
          otherPet.name,
          style: TextStyle(
            fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
            fontSize: 16,
            color: theme.colorScheme.onSurface,
          ),
        ),
        subtitle: thread.lastMessage == null
            ? null
            : Text(
                thread.lastMessage!.text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: hasUnread
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
        trailing: hasUnread
            ? Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${thread.unreadCount}',
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
