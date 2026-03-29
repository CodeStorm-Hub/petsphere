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
    return GestureDetector(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Image.network(
                pet.profileImageUrl,
                fit: BoxFit.cover,
                errorBuilder: (ctx, err, stack) => Container(color: Colors.grey.shade200, child: const Icon(Icons.broken_image, color: Colors.grey)),
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
                     style: const TextStyle(fontSize: 11, color: Colors.grey),
                   ),
                   const SizedBox(height: 4),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                     children: [
                       Container(
                         padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                         decoration: BoxDecoration(
                           color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                           borderRadius: BorderRadius.circular(4),
                         ),
                         child: Text(
                           '${pet.age} yrs',
                           style: TextStyle(
                             fontSize: 11,
                             color: Theme.of(context).colorScheme.primary,
                             fontWeight: FontWeight.bold,
                           ),
                         ),
                       ),
                       const Icon(Icons.favorite_border, size: 16, color: Colors.grey),
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
