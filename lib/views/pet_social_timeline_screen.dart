import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/pet_controller.dart';

class PetSocialTimelineScreen extends ConsumerStatefulWidget {
  const PetSocialTimelineScreen({super.key});

  @override
  ConsumerState<PetSocialTimelineScreen> createState() => _PetSocialTimelineScreenState();
}

class _PetSocialTimelineScreenState extends ConsumerState<PetSocialTimelineScreen> {
  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _SliverPetHeader(petName: pet.activePet?.name ?? 'My Pet'),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PetStatsRow(),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Life Journey', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.filter_list_rounded, size: 18),
                        label: const Text('Filter'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          _TimelineList(),
          const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_photo_alternate_rounded),
        label: const Text('Add Memory'),
        elevation: 4,
      ),
    );
  }
}

class _SliverPetHeader extends StatelessWidget {
  final String petName;
  const _SliverPetHeader({required this.petName});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 340,
      pinned: true,
      stretch: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.blurBackground],
        title: Text('$petName\'s Journey', 
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 18,
            shadows: [Shadow(color: Colors.black45, blurRadius: 10)]),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&q=80&w=1000',
              fit: BoxFit.cover,
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.transparent, Colors.transparent, Colors.black54],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [0.0, 0.3, 0.7, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PetStatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Memories', value: '124', icon: Icons.photo_library_rounded),
          _StatItem(label: 'Milestones', value: '12', icon: Icons.auto_awesome_rounded),
          _StatItem(label: 'Rank', value: 'Top 5%', icon: Icons.emoji_events_rounded),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 24),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 11, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _TimelineList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final events = [
      {'title': 'First Visit to the Beach!', 'date': 'Oct 20, 2024', 'type': 'photo', 'desc': 'He loved the waves! No fear at all!'},
      {'title': 'Expert Agility Level', 'date': 'Sep 25, 2024', 'type': 'achievement', 'desc': 'Completed the advanced course in record time.'},
      {'title': 'Vaccination Day', 'date': 'Aug 02, 2024', 'type': 'health', 'desc': 'Annual checkup done. Perfectly healthy.'},
      {'title': 'New Best Friend', 'date': 'Jul 15, 2024', 'type': 'milestone', 'desc': 'Met Luna at the park today.'},
      {'title': 'Adoption Anniversary', 'date': 'Jun 12, 2024', 'type': 'milestone', 'desc': 'One year of pure happiness.'},
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _TimelineItem(event: events[index % events.length], isFirst: index == 0, isLast: index == events.length - 1),
        childCount: events.length,
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final Map<String, String> event;
  final bool isFirst;
  final bool isLast;

  const _TimelineItem({required this.event, required this.isFirst, required this.isLast});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    IconData icon;
    Color iconColor;
    switch (event['type']) {
      case 'achievement': icon = Icons.workspace_premium_rounded; iconColor = Colors.amber; break;
      case 'health': icon = Icons.medical_services_rounded; iconColor = Colors.redAccent; break;
      case 'photo': icon = Icons.camera_alt_rounded; iconColor = Colors.blueAccent; break;
      default: icon = Icons.stars_rounded; iconColor = colorScheme.primary;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 2,
                height: 24,
                color: isFirst ? Colors.transparent : colorScheme.primary.withAlpha(100),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withAlpha(30),
                  shape: BoxShape.circle,
                  border: Border.all(color: iconColor, width: 2),
                ),
                child: Icon(icon, size: 18, color: iconColor),
              ),
              Container(
                width: 2,
                height: 120,
                color: isLast ? Colors.transparent : colorScheme.primary.withAlpha(100),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event['date']!, style: TextStyle(color: colorScheme.primary, fontSize: 13, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.outlineVariant),
                      boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 8),
                        Text(event['desc']!, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14, height: 1.4)),
                        if (event['type'] == 'photo') ...[
                          const SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network('https://images.unsplash.com/photo-1530281700549-e82e7bf110d6', height: 160, width: double.infinity, fit: BoxFit.cover),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _ReactionIcon(icon: Icons.favorite_rounded, count: '24', color: Colors.red),
                            const SizedBox(width: 16),
                            _ReactionIcon(icon: Icons.chat_bubble_rounded, count: '8', color: colorScheme.primary),
                          ],
                        ),
                      ],
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

class _ReactionIcon extends StatelessWidget {
  final IconData icon;
  final String count;
  final Color color;
  const _ReactionIcon({required this.icon, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color.withAlpha(200)),
        const SizedBox(width: 4),
        Text(count, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey)),
      ],
    );
  }
}
