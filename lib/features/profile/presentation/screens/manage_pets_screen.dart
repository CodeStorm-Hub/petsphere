import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:petfolio/core/constants/app_routes.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/core/widgets/petfolio_widgets.dart';

/// Full-screen management view for all owned pets.
class ManagePetsScreen extends ConsumerWidget {
  const ManagePetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petProvider);
    final activePet = petState.activePet;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Pets'),
        actions: [
          IconButton(
            key: const ValueKey('manage_pets_add_button'),
            onPressed: () => context.push(AppRoutes.addPet),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Add Pet',
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: petState.isLoading
              ? const Center(child: CircularProgressIndicator())
              : petState.myPets.isEmpty
                  ? _buildEmptyState(context, cs, tt)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: petState.myPets.length,
                      itemBuilder: (context, index) {
                        final pet = petState.myPets[index];
                        final isActive = activePet?.id == pet.id;
                        return _ManagePetCard(
                          pet: pet,
                          isActive: isActive,
                          onSetActive: () {
                            ref.read(petProvider.notifier).setActivePet(pet);
                          },
                          onEdit: () =>
                              context.push(AppRoutes.addPet, extra: pet),
                          onViewProfile: () =>
                              context.push(AppRoutes.petProfileById(pet.id)),
                        );
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme cs, TextTheme tt) {
    return PetfolioEmptyState(
      icon: Icons.pets_rounded,
      title: 'No pets yet',
      message: 'Add your first pet to start building your PetFolio!',
      buttonText: 'Add Your First Pet',
      onButtonPressed: () => context.push(AppRoutes.addPet),
    );
  }
}

class _ManagePetCard extends StatelessWidget {
  const _ManagePetCard({
    required this.pet,
    required this.isActive,
    required this.onSetActive,
    required this.onEdit,
    required this.onViewProfile,
  });
  final PetModel pet;
  final bool isActive;
  final VoidCallback onSetActive;
  final VoidCallback onEdit;
  final VoidCallback onViewProfile;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: isActive
            ? BorderSide(color: cs.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onViewProfile,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Pet avatar
              CircleAvatar(
                radius: 32,
                backgroundColor: cs.primaryContainer,
                backgroundImage: pet.profileImageUrl.isNotEmpty
                    ? CachedNetworkImageProvider(pet.profileImageUrl)
                    : null,
                child: pet.profileImageUrl.isEmpty
                    ? Icon(Icons.pets, size: 28, color: cs.onPrimaryContainer)
                    : null,
              ),
              const SizedBox(width: 16),
              // Pet info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(pet.name,
                              style: tt.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700)),
                        ),
                        if (isActive) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: cs.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('Active',
                                style: tt.labelSmall
                                    ?.copyWith(color: cs.onPrimary)),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${pet.animalType} • ${pet.breed.isEmpty ? "Unknown" : pet.breed} • ${pet.age} yrs',
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              // Actions
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: cs.onSurfaceVariant),
                onSelected: (value) {
                  switch (value) {
                    case 'active':
                      onSetActive();
                    case 'edit':
                      onEdit();
                    case 'view':
                      onViewProfile();
                  }
                },
                itemBuilder: (context) => [
                  if (!isActive)
                    const PopupMenuItem(
                      value: 'active',
                      child: ListTile(
                        dense: true,
                        leading: Icon(Icons.check_circle_outline),
                        title: Text('Set as Active'),
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Edit'),
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'view',
                    child: ListTile(
                      dense: true,
                      leading: Icon(Icons.visibility_outlined),
                      title: Text('View Profile'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
