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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Discover Matches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {
              context.push('/notifications');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showListPetSheet(context, ref);
        },
        icon: const Icon(Icons.favorite),
        label: const Text('List Pet'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
            child: matchState.discoveryPets.isEmpty
                ? const Center(child: Text('No pets found for these filters.'))
                : GridView.builder(
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
        ],
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

class _ListPetSheetWidget extends ConsumerStatefulWidget {
  final List<PetModel> myOwnedPets;
  const _ListPetSheetWidget({required this.myOwnedPets});

  @override
  ConsumerState<_ListPetSheetWidget> createState() =>
      _ListPetSheetWidgetState();
}

class _ListPetSheetWidgetState extends ConsumerState<_ListPetSheetWidget> {
  String? _selectedPetId;
  bool _isSubmitting = false;
  String? _submitError;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, left: 16, right: 16, bottom: 32),
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

          if (widget.myOwnedPets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('You have no registered pets.'),
            )
          else
            ...widget.myOwnedPets.map((pet) {
              return RadioListTile<String>(
                title: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(pet.profileImageUrl),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      pet.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
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
                    _submitError = null;
                  });
                },
              );
            }),

          if (_submitError != null) ...[
            const SizedBox(height: 8),
            Text(
              _submitError!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ],

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _selectedPetId == null || _isSubmitting
                  ? null
                  : () async {
                      setState(() {
                        _isSubmitting = true;
                        _submitError = null;
                      });

                      final ok = await ref
                          .read(matchProvider.notifier)
                          .listPetForDiscovery(_selectedPetId!);

                      if (!context.mounted) return;

                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Successfully listed your pet for breeding!',
                            ),
                          ),
                        );
                        Navigator.of(context).pop();
                      } else {
                        setState(() {
                          _isSubmitting = false;
                          _submitError =
                              ref.read(matchProvider).error ??
                              'Could not list pet. Please try again.';
                        });
                      }
                    },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Confirm Listing',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
