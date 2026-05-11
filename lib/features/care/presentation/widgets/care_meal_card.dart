import 'package:flutter/material.dart';

/// A card for logging and displaying meal details.
class CareMealCard extends StatelessWidget {
  const CareMealCard({
    super.key,
    required this.name,
    required this.time,
    required this.kcal,
    required this.food,
    required this.fed,
    required this.onChanged,
  });

  final String name;
  final String time;
  final int kcal;
  final String food;
  final bool fed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: fed ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('$time • $kcal kcal'),
            trailing: Switch(
              value: fed,
              onChanged: onChanged,
              activeThumbColor: colorScheme.primary,
            ),
          ),
          if (fed) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      food,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
