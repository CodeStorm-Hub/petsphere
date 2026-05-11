import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/core/theme/spacing.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'pet_avatar.dart';
import 'app_bottom_sheet.dart';

class PetSwitcher extends ConsumerWidget {
  const PetSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petProvider);
    final activePet = petState.activePet;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (activePet == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => _showPetPicker(context, ref),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        decoration: BoxDecoration(
          color: colorScheme.primaryContainer.withAlpha(100),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: colorScheme.primary.withAlpha(50),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            PetAvatar(
              imageUrl: activePet.profileImageUrl,
              radius: 12,
            ),
            const SizedBox(width: AppSpacing.xs),
            Text(
              activePet.name,
              style: theme.textTheme.labelMedium?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              Icons.keyboard_arrow_down,
              size: 16,
              color: colorScheme.primary,
            ),
          ],
        ),
      ),
    );
  }

  void _showPetPicker(BuildContext context, WidgetRef ref) {
    final petState = ref.read(petProvider);
    final myPets = petState.myPets;
    final activePet = petState.activePet;

    AppBottomSheet.show<void>(
      context: context,
      title: 'Switch Pet',
      child: Column(
        children: [
          ...myPets.map((pet) {
            final isSelected = pet.id == activePet?.id;
            return ListTile(
              leading: PetAvatar(
                imageUrl: pet.profileImageUrl,
              ),
              title: Text(
                pet.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(pet.breed),
              trailing: isSelected
                  ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () {
                ref.read(petProvider.notifier).setActivePet(pet);
                Navigator.pop(context);
              },
            );
          }),
          const Divider(),
          ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.add),
            ),
            title: const Text('Add New Pet'),
            onTap: () {
              // TODO: Navigate to add pet screen
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
