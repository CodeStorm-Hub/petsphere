import 'package:flutter/material.dart';

class CommunityGroupsScreen extends StatelessWidget {
  const CommunityGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Groups'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.add_circle_outline)),
        ],
      ),
      body: Column(
        children: [
          _DiscoveryHeader(),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _SectionTitle(title: 'Suggested for You'),
                const SizedBox(height: 12),
                _GroupListItem(
                  name: 'Golden Retriever Lovers',
                  members: '12.4k',
                  description: 'A place for Golden owners to share tips and meetups.',
                  image: 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&q=80&w=200',
                  isJoined: true,
                ),
                _GroupListItem(
                  name: 'NYC Dog Walkers',
                  members: '5.2k',
                  description: 'Finding the best trails in the concrete jungle.',
                  image: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&q=80&w=200',
                ),
                const SizedBox(height: 24),
                _SectionTitle(title: 'Trending Categories'),
                const SizedBox(height: 12),
                _CategoryGrid(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscoveryHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Connect with other pet parents',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join groups based on breed, location, or interests.',
            style: TextStyle(color: colorScheme.onPrimaryContainer.withAlpha(180)),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }
}

class _GroupListItem extends StatelessWidget {
  final String name;
  final String members;
  final String description;
  final String image;
  final bool isJoined;

  const _GroupListItem({
    required this.name,
    required this.members,
    required this.description,
    required this.image,
    this.isJoined = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.network(image, width: 70, height: 70, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('$members members', style: TextStyle(color: colorScheme.primary, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: () {},
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              visualDensity: VisualDensity.compact,
            ),
            child: Text(isJoined ? 'Open' : 'Join'),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Training', 'icon': Icons.psychology},
      {'name': 'Nutrition', 'icon': Icons.restaurant},
      {'name': 'Puppy Care', 'icon': Icons.child_care},
      {'name': 'Senior Pets', 'icon': Icons.elderly},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final cat = categories[index];
        final colorScheme = Theme.of(context).colorScheme;
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withAlpha(100),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(cat['icon'] as IconData, color: colorScheme.secondary),
              const SizedBox(width: 12),
              Text(cat['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        );
      },
    );
  }
}
