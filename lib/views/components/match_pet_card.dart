import 'package:flutter/material.dart';
import '../../models/pet_model.dart';

class MatchPetCard extends StatelessWidget {
  final PetModel pet;
  final VoidCallback onTap;

  const MatchPetCard({
    super.key,
    required this.pet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
              child: Image.network(
                pet.profileImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(
                  color: colorScheme.surface,
                  child: Icon(Icons.broken_image, color: colorScheme.onSurfaceVariant),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Text(
                     pet.name,
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                   ),
                   const SizedBox(height: 2),
                   Text(
                     pet.breed,
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                     style: TextStyle(fontSize: 11, color: colorScheme.onSurfaceVariant),
                   ),
                   const SizedBox(height: 4),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                       Icon(Icons.favorite_border, size: 16, color: colorScheme.onSurfaceVariant),
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
