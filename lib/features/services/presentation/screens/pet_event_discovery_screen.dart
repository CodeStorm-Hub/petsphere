import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/services/presentation/controllers/pet_events_controller.dart';
import 'package:petfolio/features/services/data/models/pet_event_models.dart';
import 'package:petfolio/core/widgets/async_value_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_animate/flutter_animate.dart';

import 'package:petfolio/core/widgets/petfolio_widgets.dart';

class PetEventDiscoveryScreen extends ConsumerWidget {
  const PetEventDiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final eventsAsync = ref.watch(petEventsProvider);
    final selectedType = ref.watch(petEventTypeFilterProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: PetFolioGradientBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 120,
              floating: true,
              pinned: true,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'Discover Events',
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                centerTitle: false,
                titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 16),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // TODO: Advanced filters
                  },
                ),
              ],
            ),
          SliverToBoxAdapter(
            child: _TypeFilterBar(ref: ref, selectedType: selectedType),
          ),
          AsyncValueWidget<List<PetEvent>>(
            value: eventsAsync,
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            ),
            data: (List<PetEvent> events) {
              if (events.isEmpty) {
                return const SliverFillRemaining(
                  child: _EmptyEventsView(),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _EventCard(event: events[index]),
                    childCount: events.length,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    ),
    );
  }
}

class _TypeFilterBar extends StatelessWidget {

  const _TypeFilterBar({required this.ref, required this.selectedType});
  final WidgetRef ref;
  final String selectedType;

  static const types = ['All', 'Meetup', 'Workshop', 'Show', 'Charity'];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          final isSelected = type == selectedType;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  ref.read(petEventTypeFilterProvider.notifier).set(type);
                }
              },
              labelStyle: GoogleFonts.dmSans(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
            ),
          );
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {

  const _EventCard({required this.event});
  final PetEvent event;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEE, MMM d • h:mm a');

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to event details
        },
        borderRadius: BorderRadius.circular(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: event.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: event.imageUrl!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          height: 160,
                          width: double.infinity,
                          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
                          child: Icon(
                            Icons.event_available,
                            size: 48,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      event.eventType.toUpperCase(),
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.calendar_month_outlined,
                          size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        dateFormat.format(event.eventDate),
                        style: GoogleFonts.dmSans(
                          fontSize: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined,
                          size: 16, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.location ?? 'Online / TBD',
                          style: GoogleFonts.dmSans(
                            fontSize: 14,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _AvatarStack(),
                      const SizedBox(width: 8),
                      Text(
                        '${event.maxAttendees ?? "50+"} spots available',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.secondary,
                        ),
                      ),
                      const Spacer(),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('RSVP'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn().scale(delay: 100.ms, begin: const Offset(0.95, 0.95));
  }
}

class _AvatarStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 24,
      child: Stack(
        children: List.generate(3, (index) {
          return Positioned(
            left: index * 16.0,
            child: CircleAvatar(
              radius: 12,
              backgroundColor: Colors.white,
              child: CircleAvatar(
                radius: 10,
                backgroundImage: NetworkImage(
                  'https://i.pravatar.cc/100?u=$index',
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyEventsView extends StatelessWidget {
  const _EmptyEventsView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No events found',
            style: GoogleFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Check back later for new pet meetups!'),
        ],
      ),
    );
  }
}
