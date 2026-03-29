import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/feed_controller.dart';

class PetProfileScreen extends ConsumerWidget {
  const PetProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Current pet is mocked
    final pet = mockPets[0];
    final allPosts = ref.watch(feedProvider);
    final myPosts = allPosts.where((p) => p.pet.id == pet.id).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(pet.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {}, // Future: Go to settings
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(pet.profileImageUrl),
                      ),
                      const Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _StatColumn(label: 'Posts', value: '1'), // Or myPosts.length
                            _StatColumn(label: 'Followers', value: '128'),
                            _StatColumn(label: 'Following', value: '150'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(pet.breed, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(pet.bio),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Edit Profile'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          child: const Text('Share Profile'),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 2,
              crossAxisSpacing: 2,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final post = myPosts[index];
                return Image.network(
                  post.mediaUrl,
                  fit: BoxFit.cover,
                );
              },
              childCount: myPosts.length,
            ),
          )
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String value;
  
  const _StatColumn({required this.label, required this.value});
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }
}
