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
    final media = _MediaPayload.tryParse(message.text);

    return Semantics(
      label: media == null
          ? '${isMe ? 'You sent' : 'Received message'}: ${message.text} at $timeStr'
          : '${isMe ? 'You sent' : 'Received'} a ${media.type} at $timeStr',
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
                if (media == null)
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isMe
                          ? colorScheme.onPrimary
                          : colorScheme.onSurface,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  )
                else
                  _MediaMessagePreview(media: media, isMe: isMe),
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

class _MediaPayload {
  const _MediaPayload(this.type, this.url);
  final String type;
  final String url;

  static _MediaPayload? tryParse(String text) {
    if (!text.startsWith('media:')) return null;
    final parts = text.split(':');
    if (parts.length < 3) return null;
    final type = parts[1];
    final url = text.substring('media:$type:'.length);
    if (url.isEmpty) return null;
    return _MediaPayload(type, url);
  }
}

class _MediaMessagePreview extends StatelessWidget {
  const _MediaMessagePreview({required this.media, required this.isMe});
  final _MediaPayload media;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (media.type == 'image') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Image.network(
          media.url,
          width: 220,
          height: 160,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _mediaFallback(colorScheme),
        ),
      );
    }

    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: isMe
            ? colorScheme.onPrimary.withAlpha(30)
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outline.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(Icons.play_circle_fill_rounded, color: colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Video message',
              style: TextStyle(
                color: isMe ? colorScheme.onPrimary : colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mediaFallback(ColorScheme colorScheme) {
    return Container(
      width: 220,
      height: 160,
      color: colorScheme.surfaceContainerHigh,
      child: Icon(
        Icons.broken_image_outlined,
        color: colorScheme.onSurfaceVariant,
        size: 32,
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
