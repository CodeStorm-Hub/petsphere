import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:petfolio/core/constants/app_routes.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';

/// Bottom sheet modal for quickly switching the active pet.
class ActivePetSwitcherModal {
  ActivePetSwitcherModal._();

  static void show(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _SwitcherContent(),
    );
  }
}

class _SwitcherContent extends ConsumerWidget {
  const _SwitcherContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petProvider);
    final activePet = petState.activePet;
    final pets = petState.myPets;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 8, 0, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: cs.onSurfaceVariant.withAlpha(80),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Switch Pet',
                      style: tt.titleLarge
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      context.push(AppRoutes.managePets);
                    },
                    child: const Text('Manage Pets'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Pet list
            if (pets.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.pets_rounded, size: 48, color: cs.primary),
                    const SizedBox(height: 12),
                    Text('No pets yet', style: tt.bodyLarge),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push(AppRoutes.addPet);
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add Your First Pet'),
                    ),
                  ],
                ),
              )
            else
              ...pets.map((pet) => _PetTile(
                    pet: pet,
                    isActive: activePet?.id == pet.id,
                    onTap: () {
                      ref.read(petProvider.notifier).setActivePet(pet);
                      Navigator.pop(context);
                    },
                  )),
            // Add pet option
            if (pets.isNotEmpty)
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: cs.primary.withAlpha(30),
                  ),
                  child: Icon(Icons.add_rounded, color: cs.primary),
                ),
                title: Text('Add a new pet',
                    style: tt.bodyLarge
                        ?.copyWith(color: cs.primary, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  context.push(AppRoutes.addPet);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PetTile extends StatelessWidget {
  const _PetTile({
    required this.pet,
    required this.isActive,
    required this.onTap,
  });
  final PetModel pet;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return ListTile(
      selected: isActive,
      selectedTileColor: cs.primaryContainer.withAlpha(50),
      onTap: onTap,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: cs.primaryContainer,
        backgroundImage: pet.profileImageUrl.isNotEmpty
            ? CachedNetworkImageProvider(pet.profileImageUrl)
            : null,
        child: pet.profileImageUrl.isEmpty
            ? Icon(Icons.pets, color: cs.onPrimaryContainer)
            : null,
      ),
      title: Text(pet.name,
          style: tt.bodyLarge?.copyWith(
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          )),
      subtitle: Text(
        '${pet.animalType} • ${pet.breed.isEmpty ? "Unknown" : pet.breed}',
        style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
      ),
      trailing: isActive
          ? Icon(Icons.check_circle, color: cs.primary)
          : Icon(Icons.radio_button_unchecked, color: cs.outlineVariant),
    );
  }
}
