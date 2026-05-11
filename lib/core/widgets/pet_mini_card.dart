import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petfolio/core/constants/app_routes.dart';
import 'package:petfolio/core/theme/app_border_radius.dart';
import 'package:petfolio/core/theme/icon_sizes.dart';
import 'package:petfolio/core/theme/spacing.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';

class PetMiniCard extends StatelessWidget {
  const PetMiniCard({
    super.key,
    required this.pet,
    required this.isActive,
    required this.onTap,
  });

  final PetModel pet;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: isActive
              ? cs.primaryContainer.withAlpha(80)
              : cs.surfaceContainerLow,
          borderRadius: AppBorderRadius.circularLg,
          border: isActive
              ? Border.all(color: cs.primary, width: 2)
              : Border.all(color: cs.outlineVariant.withAlpha(80)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 28, // Specific size for mini card avatar
              backgroundColor: cs.primaryContainer,
              backgroundImage: pet.profileImageUrl.isNotEmpty
                  ? CachedNetworkImageProvider(pet.profileImageUrl)
                  : null,
              child: pet.profileImageUrl.isEmpty
                  ? Icon(Icons.pets, color: cs.onPrimaryContainer)
                  : null,
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              pet.name,
              style: tt.bodySmall?.copyWith(
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            if (isActive)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.tiny),
                child: Text(
                  'Active',
                  style: tt.labelSmall?.copyWith(color: cs.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AddPetCard extends StatelessWidget {
  const AddPetCard({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.addPet),
      child: Container(
        width: 100,
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: AppBorderRadius.circularLg,
          border: Border.all(
            color: cs.primary.withAlpha(100),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.m),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: cs.primary.withAlpha(30),
              ),
              child: Icon(
                Icons.add_rounded,
                color: cs.primary,
                size: AppIconSizes.l,
              ),
            ),
            const SizedBox(height: AppSpacing.s),
            Text(
              'Add Pet',
              style: tt.bodySmall?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

