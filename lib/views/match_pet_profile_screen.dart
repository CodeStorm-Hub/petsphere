import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/pet_repository.dart';
import '../models/pet_model.dart';
import '../controllers/match_controller.dart';
import 'package:go_router/go_router.dart';

bool _looksLikeUuid(String value) {
  final uuidPattern = RegExp(
    '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}',
  );
  return uuidPattern.hasMatch(value);
}

// Load pet by ID from Supabase
final _petByIdProvider = FutureProvider.family<PetModel?, String>((
  ref,
  petId,
) async {
  if (!_looksLikeUuid(petId)) return null;

  try {
    return await petRepository.fetchPetById(petId);
  } catch (_) {
    return null;
  }
});

class MatchPetProfileScreen extends ConsumerWidget {
  final String petId;

  const MatchPetProfileScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petAsync = ref.watch(_petByIdProvider(petId));

    return petAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text('Error loading pet: $e'))),
      data: (pet) {
        if (pet == null) {
          return const Scaffold(body: Center(child: Text('Pet not found')));
        }

        return Scaffold(
          appBar: AppBar(title: Text(pet.name)),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 300,
                  child: pet.profileImageUrl.isNotEmpty
                      ? Image.network(pet.profileImageUrl, fit: BoxFit.cover)
                      : Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.pets,
                            size: 80,
                            color: Colors.grey,
                          ),
                        ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            pet.name,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${pet.age} yrs',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Breed: ${pet.breed}',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'About',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        pet.bio,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Medical Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 8),
                          const Text('Fully Vaccinated'),
                          const Spacer(),
                          if (pet.isPublicOwner)
                            const Chip(label: Text('Owner Info Public')),
                        ],
                      ),
                      const SizedBox(height: 48),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.favorite),
                          label: const Text('Send Match Request'),
                          onPressed: () {
                            ref
                                .read(matchProvider.notifier)
                                .sendLikeRequest(pet.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Breeding request sent for ${pet.name}!',
                                ),
                              ),
                            );
                            context.pop();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
