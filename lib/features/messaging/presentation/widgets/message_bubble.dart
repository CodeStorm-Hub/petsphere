import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petfolio/features/messaging/data/models/message_model.dart';

class MessageBubble extends StatelessWidget {

  const MessageBubble({super.key, required this.message, required this.isMe});
  final MessageModel message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeStr = DateFormat('h:mm a').format(message.createdAt.toLocal());

    return Semantics(
      label:
          '${isMe ? 'You sent' : 'Received message'}: ${message.text} at $timeStr',
      excludeSemantics: true,
      child: Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.80,
          ),
          child: Container(
            margin: EdgeInsets.only(
              top: 4,
              bottom: 4,
              left: isMe ? 60 : 0,
              right: isMe ? 0 : 60,
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              // Sent: gradient from primary to primaryContainer (blue theme)
              gradient: isMe
                  ? LinearGradient(
                      colors: [
                        colorScheme.primary,
                        colorScheme.primaryContainer,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              // Received: surface-container-highest
              color: isMe ? null : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              boxShadow: isMe
                  ? [
                      BoxShadow(
                        color: colorScheme.primary.withAlpha(25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  message.text,
                  style: TextStyle(
                    color: isMe ? colorScheme.onPrimary : colorScheme.onSurface,
                    fontSize: 15,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 10,
                        color: isMe
                            ? colorScheme.onPrimary.withAlpha(180)
                            : colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.isRead ? Icons.done_all : Icons.done,
                        size: 13,
                        color: message.isRead
                            ? colorScheme.tertiary
                            : colorScheme.onPrimary.withAlpha(180),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Date separator (pill style as per Stitch) ─────────────────────────────
class DateSeparator extends StatelessWidget {
  const DateSeparator({super.key, required this.date});
  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(date.year, date.month, date.day);
    final label = msgDay == today
        ? 'Today'
        : msgDay == today.subtract(const Duration(days: 1))
        ? 'Yesterday'
        : DateFormat('MMM d, yyyy').format(date);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: colorScheme.onSurfaceVariant,
              letterSpacing: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
