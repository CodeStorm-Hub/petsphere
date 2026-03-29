import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/match_controller.dart';
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
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet(context, ref, matchState.filterBreed);
            },
          ),
          IconButton(
             icon: const Icon(Icons.notifications_none),
             onPressed: () {
                context.push('/notifications');
             },
          )
        ],
      ),
      body: matchState.discoveryPets.isEmpty
          ? const Center(child: Text('No pets found for these filters.'))
          : ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              itemCount: matchState.discoveryPets.length,
              itemBuilder: (context, index) {
                final pet = matchState.discoveryPets[index];
                return MatchPetCard(
                  pet: pet,
                  onTap: () {
                     // Pass ID context when clicking through
                     context.push('/pet/${pet.id}');
                  },
                );
              },
            ),
    );
  }

  void _showFilterBottomSheet(BuildContext context, WidgetRef ref, String? currentFilter) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Filter by Breed', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: [
                  _FilterChip('All', null, currentFilter, ref, context),
                  _FilterChip('Golden Retriever', 'Golden Retriever', currentFilter, ref, context),
                  _FilterChip('Siberian Husky', 'Siberian Husky', currentFilter, ref, context),
                  _FilterChip('Maine Coon', 'Maine Coon', currentFilter, ref, context),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final String? filterValue;
  final String? currentFilter;
  final WidgetRef ref;
  final BuildContext ctx;

  const _FilterChip(this.label, this.filterValue, this.currentFilter, this.ref, this.ctx);

  @override
  Widget build(BuildContext context) {
    final isSelected = filterValue == currentFilter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        ref.read(matchProvider.notifier).setFilterBreed(filterValue);
        Navigator.pop(ctx);
      },
    );
  }
}
