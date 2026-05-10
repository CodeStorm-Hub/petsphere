import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:petsphere/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petsphere/features/pet/presentation/controllers/pet_controller.dart';

class PetProfileScreen extends ConsumerWidget {
  const PetProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final petState = ref.watch(petProvider);
    final pet = petState.activePet;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings),
          ),
        ],
      ),
      body: pet == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No active pet selected',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add a pet to start building your PetFolio.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => context.push('/add_pet'),
                      icon: const Icon(Icons.add),
                      label: const Text('Add pet'),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: cs.surfaceContainerHighest,
                      backgroundImage: pet.profileImageUrl.isNotEmpty
                          ? CachedNetworkImageProvider(pet.profileImageUrl)
                          : null,
                      child: pet.profileImageUrl.isEmpty
                          ? const Icon(Icons.pets, size: 32)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${pet.animalType} · ${pet.breed.isEmpty ? 'Unknown breed' : pet.breed}',
                            style: TextStyle(color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(height: 4),
                          if (auth.user != null)
                            Text(
                              auth.user!.email,
                              style: TextStyle(color: cs.onSurfaceVariant),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                FilledButton.icon(
                  onPressed: () => context.push('/add_pet'),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit pet'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () => context.push('/liked_pets'),
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Liked pets'),
                ),
              ],
            ),
    );
  }
}

