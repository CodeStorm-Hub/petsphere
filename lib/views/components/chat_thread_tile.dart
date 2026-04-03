import 'package:flutter/material.dart';
import '../../models/chat_thread_model.dart';
import 'pet_avatar.dart';

class ChatThreadTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Find the other pet in the conversation
    final otherPet = thread.participantPets.firstWhere(
      (p) => p.id != myPetId,
      orElse: () => thread.participantPets.first,
    );

    final hasUnread = thread.unreadCount > 0;

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: PetAvatar(imageUrl: otherPet.profileImageUrl, radius: 28),
      title: Text(
        otherPet.name,
        style: TextStyle(
          fontWeight: hasUnread ? FontWeight.bold : FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: thread.lastMessage == null
          ? null
          : Text(
              thread.lastMessage!.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: hasUnread ? Colors.black87 : Colors.grey,
                fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
      trailing: hasUnread
          ? Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${thread.unreadCount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
    );
  }
}
