import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/match_controller.dart';
import '../controllers/pet_controller.dart';
import '../models/pet_model.dart';
import 'components/match_pet_card.dart';

class DiscoveryScreen extends ConsumerWidget {
  const DiscoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchState = ref.watch(matchProvider);
    final myPets = ref.watch(petProvider).myPets;
    final listedPets = myPets.where((p) => p.isBreedingListed).toList();

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Breeding Discovery'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Discover'),
              Tab(text: 'My Listings'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.favorite_outline),
              tooltip: 'Liked Pets',
              onPressed: () => context.push('/liked_pets'),
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              tooltip: 'Messages',
              onPressed: () => context.push('/messages'),
            ),
            IconButton(
              icon: const Icon(Icons.notifications_none),
              tooltip: 'Notifications',
              onPressed: () => context.push('/notifications'),
            ),
            const SizedBox(width: 4),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'discovery_fab',
          onPressed: () {
            _showListPetSheet(context, ref);
          },
          icon: const Icon(Icons.add),
          label: const Text('New Listing'),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        body: TabBarView(
          children: [
            // TAB 1: DISCOVER
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Animal Types Filter
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 12),
                  child: Row(
                    children: [
                      _AnimalChip(
                        label: 'All Animals',
                        value: null,
                        current: matchState.filterAnimal,
                      ),
                      const SizedBox(width: 8),
                      _AnimalChip(
                        label: 'Dogs',
                        value: 'Dog',
                        current: matchState.filterAnimal,
                      ),
                      const SizedBox(width: 8),
                      _AnimalChip(
                        label: 'Cats',
                        value: 'Cat',
                        current: matchState.filterAnimal,
                      ),
                      const SizedBox(width: 8),
                      _AnimalChip(
                        label: 'Birds',
                        value: 'Bird',
                        current: matchState.filterAnimal,
                      ),
                    ],
                  ),
                ),

                // Filter Breeds Row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      _BreedChip(
                        label: 'All Breeds',
                        value: null,
                        current: matchState.filterBreed,
                      ),
                      const SizedBox(width: 8),
                      _BreedChip(
                        label: 'Golden Retriever',
                        value: 'Golden Retriever',
                        current: matchState.filterBreed,
                      ),
                      const SizedBox(width: 8),
                      _BreedChip(
                        label: 'Siberian Husky',
                        value: 'Siberian Husky',
                        current: matchState.filterBreed,
                      ),
                      const SizedBox(width: 8),
                      _BreedChip(
                        label: 'Maine Coon',
                        value: 'Maine Coon',
                        current: matchState.filterBreed,
                      ),
                      const SizedBox(width: 8),
                      _BreedChip(
                        label: 'Persian',
                        value: 'Persian',
                        current: matchState.filterBreed,
                      ),
                      const SizedBox(width: 8),
                      _BreedChip(
                        label: 'Macaw',
                        value: 'Macaw',
                        current: matchState.filterBreed,
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => ref.read(matchProvider.notifier).refresh(),
                    child: matchState.discoveryPets.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Center(
                                  child: Text('No pets found for these filters.')),
                            ],
                          )
                        : GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.all(16),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: matchState.discoveryPets.length,
                            itemBuilder: (context, index) {
                              final pet = matchState.discoveryPets[index];
                              return MatchPetCard(
                                pet: pet,
                                onTap: () {
                                  context.push('/pet/${pet.id}');
                                },
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),

            // TAB 2: MY LISTINGS
            RefreshIndicator(
              onRefresh: () => ref.read(petProvider.notifier).reload(),
              child: listedPets.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        const SizedBox(height: 100),
                        const Icon(Icons.favorite_border,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Center(
                            child: Text('You haven\'t listed any pets yet.',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold))),
                        const SizedBox(height: 8),
                        const Center(
                            child: Text(
                                'Tap "New Listing" to add your pet to discovery.',
                                style: TextStyle(color: Colors.grey))),
                        const SizedBox(height: 24),
                        Center(
                          child: OutlinedButton(
                            onPressed: () => _showListPetSheet(context, ref),
                            child: const Text('Start Listing'),
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: listedPets.length,
                      itemBuilder: (context, index) {
                        final pet = listedPets[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundImage:
                                  NetworkImage(pet.profileImageUrl),
                            ),
                            title: Text(pet.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            subtitle: Text('${pet.breed} • ${pet.animalType}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline,
                                  color: Colors.red),
                              onPressed: () async {
                                final success = await ref
                                    .read(petProvider.notifier)
                                    .toggleBreedingListing(pet.id, false);
                                if (context.mounted && success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            '${pet.name} removed from breeding listings.')),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimalChip extends ConsumerWidget {
  final String label;
  final String? value;
  final String? current;

  const _AnimalChip({
    required this.label,
    required this.value,
    required this.current,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = current == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          ref.read(matchProvider.notifier).setFilterAnimal(value);
        } else if (value != null) {
          // Deselecting a specific animal -> clears filter
          ref.read(matchProvider.notifier).setFilterAnimal(null);
        }
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}

class _BreedChip extends ConsumerWidget {
  final String label;
  final String? value;
  final String? current;

  const _BreedChip({
    required this.label,
    required this.value,
    required this.current,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = current == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        if (selected) {
          ref.read(matchProvider.notifier).setFilterBreed(value);
        } else if (value != null) {
          ref.read(matchProvider.notifier).setFilterBreed(null);
        }
      },
      selectedColor: Theme.of(context).colorScheme.primaryContainer,
    );
  }
}

void _showListPetSheet(BuildContext context, WidgetRef ref) {
  // Pull authenticated user's pets from petProvider
  final myOwnedPets = ref.read(petProvider).myPets;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return _ListPetSheetWidget(myOwnedPets: myOwnedPets);
    },
  );
}

class _ListPetSheetWidget extends StatefulWidget {
  final List<PetModel> myOwnedPets;
  const _ListPetSheetWidget({required this.myOwnedPets});

  @override
  State<_ListPetSheetWidget> createState() => _ListPetSheetWidgetState();
}

class _ListPetSheetWidgetState extends State<_ListPetSheetWidget> {
  String? _selectedPetId;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Only show pets that are NOT yet listed for breeding
    final availablePets =
        widget.myOwnedPets.where((p) => !p.isBreedingListed).toList();

    return Consumer(
      builder: (context, ref, child) {
        return Padding(
          padding:
              const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'List a Pet for Breeding',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Select which of your pets you want to add to the discovery matchmaking pool.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),
              if (availablePets.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey, size: 48),
                      SizedBox(height: 16),
                      Text(
                        'No pets available to list. All your pets are already listed or you haven\'t added any pets yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availablePets.length,
                    itemBuilder: (context, index) {
                      final pet = availablePets[index];
                      return RadioListTile<String>(
                        title: Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: NetworkImage(pet.profileImageUrl),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              pet.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        subtitle: Text(pet.breed),
                        value: pet.id,
                        groupValue: _selectedPetId,
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (val) {
                          setState(() {
                            _selectedPetId = val;
                          });
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _selectedPetId == null || _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);
                          final success = await ref
                              .read(petProvider.notifier)
                              .toggleBreedingListing(_selectedPetId!, true);
                          if (context.mounted) {
                            setState(() => _isLoading = false);
                            if (success) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Successfully listed your pet for breeding!',
                                  ),
                                ),
                              );
                            } else {
                              final error = ref.read(petProvider).error;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    error ?? 'Failed to list pet for breeding.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Confirm Listing',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
