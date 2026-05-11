import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:petfolio/features/services/presentation/controllers/pet_events_controller.dart';
import 'package:petfolio/features/services/data/models/pet_event_models.dart';

class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(petEventsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Scaffold(
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (events) {
          final event = events.where((e) => e.id == eventId).firstOrNull;
          if (event == null) {
            return const Center(child: Text('Event not found'));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 240,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: event.imageUrl != null
                      ? CachedNetworkImage(imageUrl: event.imageUrl!, fit: BoxFit.cover)
                      : Container(
                          color: colorScheme.primaryContainer,
                          child: Icon(Icons.event, size: 80, color: colorScheme.onPrimaryContainer),
                        ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share feature coming soon')),
                      );
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          event.eventType.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        event.title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _DetailRow(
                        icon: Icons.calendar_month,
                        label: dateFormat.format(event.eventDate),
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(
                        icon: Icons.access_time,
                        label: timeFormat.format(event.eventDate),
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(
                        icon: Icons.location_on,
                        label: event.location ?? 'Online / TBD',
                      ),
                      const SizedBox(height: 8),
                      _DetailRow(
                        icon: Icons.people,
                        label: '${event.maxAttendees ?? "50+"} spots available',
                      ),
                      if (event.description.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'About This Event',
                          style: GoogleFonts.dmSans(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          event.description,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        onPressed: () => _rsvpEvent(context, ref, event),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('RSVP to Event'),
                        style: FilledButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _rsvpEvent(BuildContext context, WidgetRef ref, PetEvent event) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('RSVP'),
        content: Text('Would you like to RSVP to "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('RSVP confirmed! See you there!')),
              );
            },
            child: const Text('Confirm RSVP'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}