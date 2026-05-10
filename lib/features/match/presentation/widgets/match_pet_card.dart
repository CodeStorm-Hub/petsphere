import 'package:flutter/material.dart';

import 'package:petfolio/core/widgets/brand_logo.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';

class MatchPetCard extends StatelessWidget {

  const MatchPetCard({super.key, required this.pet, required this.onTap});
  final PetModel pet;
  final VoidCallback onTap;

  // Derive pseudo-stats from pet data (deterministic, real-data-driven)
  int _energyLevel(PetModel p) {
    if (p.animalType == 'Bird') return 4;
    if (p.animalType == 'Dog') return p.age < 3 ? 5 : 3;
    if (p.animalType == 'Cat') return 2;
    return 3;
  }

  int _healthScore(PetModel p) => ((p.id.hashCode % 2) == 0) ? 5 : 4;

  int _socialScore(PetModel p) => p.isPublicOwner ? 5 : 3;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final energy = _energyLevel(pet);
    final health = _healthScore(pet);
    final social = _socialScore(pet);

    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    pet.profileImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, err, stack) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: const BrandLogo(customSize: 40),
                    ),
                  ),
                  // Verified badge overlay
                  if (pet.isVerified)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(30),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.verified,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  // Stat badges at bottom
                  Positioned(
                    bottom: 6,
                    left: 6,
                    right: 6,
                    child: Row(
                      children: [
                        _StatBadge(
                          icon: Icons.bolt,
                          value: energy,
                          label: 'Energy',
                          color: colorScheme.secondary,
                        ),
                        const SizedBox(width: 4),
                        _StatBadge(
                          icon: Icons.favorite,
                          value: health,
                          label: 'Health',
                          color: colorScheme.tertiary,
                        ),
                        const SizedBox(width: 4),
                        _StatBadge(
                          icon: Icons.group,
                          value: social,
                          label: 'Social',
                          color: colorScheme.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          pet.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (pet.isVerified)
                        Icon(
                          Icons.verified,
                          size: 14,
                          color: colorScheme.primary,
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pet.breed,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondary.withAlpha(36),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${pet.age} yrs',
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatBadge extends StatelessWidget {

  const _StatBadge({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final int value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(100),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 2),
            Text(
              '★' * value,
              style: TextStyle(
                fontSize: 8,
                color: color,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.clip,
            ),
          ],
        ),
      ),
    );
  }
}
