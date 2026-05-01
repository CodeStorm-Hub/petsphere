import 'package:flutter/material.dart';

class PetSitterDashboardScreen extends StatelessWidget {
  const PetSitterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Sitters'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.history_outlined)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _SitterStatusCard(),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Top Rated Sitters', style: Theme.of(context).textTheme.titleLarge),
              TextButton(onPressed: () {}, child: const Text('View All')),
            ],
          ),
          const SizedBox(height: 12),
          _SitterList(),
          const SizedBox(height: 32),
          Text('Your Bookings', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _BookingItem(
            sitterName: 'Sarah Jenkins',
            date: 'Oct 28 - Oct 30',
            status: 'Upcoming',
            petName: 'Max',
          ),
        ],
      ),
    );
  }
}

class _SitterStatusCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(50),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.primaryContainer),
      ),
      child: Column(
        children: [
          const Icon(Icons.house_siding, size: 48, color: Colors.blueAccent),
          const SizedBox(height: 16),
          const Text(
            'Need a Sitter?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          const SizedBox(height: 8),
          const Text(
            'Find trusted neighbors to watch your pet while you are away.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 24),
          FilledButton(onPressed: () {}, child: const Text('Post a Job')),
        ],
      ),
    );
  }
}

class _SitterList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SitterCard(name: 'Alice W.', rating: 4.9, jobs: 124, price: '\$25/hr', image: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80'),
        _SitterCard(name: 'Michael R.', rating: 4.8, jobs: 89, price: '\$20/hr', image: 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e'),
      ],
    );
  }
}

class _SitterCard extends StatelessWidget {
  final String name;
  final double rating;
  final int jobs;
  final String price;
  final String image;

  const _SitterCard({required this.name, required this.rating, required this.jobs, required this.price, required this.image});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: colorScheme.outlineVariant)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(radius: 30, backgroundImage: NetworkImage(image)),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Row(
          children: [
            const Icon(Icons.star, color: Colors.amber, size: 14),
            const SizedBox(width: 4),
            Text('$rating ($jobs jobs)', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(price, style: TextStyle(fontWeight: FontWeight.bold, color: colorScheme.primary, fontSize: 16)),
            const Text('per hour', style: TextStyle(fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _BookingItem extends StatelessWidget {
  final String sitterName;
  final String date;
  final String status;
  final String petName;

  const _BookingItem({required this.sitterName, required this.date, required this.status, required this.petName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sitterName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text('$petName · $date', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.blue.withAlpha(30), borderRadius: BorderRadius.circular(8)),
            child: const Text('Upcoming', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10)),
          ),
        ],
      ),
    );
  }
}
