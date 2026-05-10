import 'package:flutter/material.dart';
import 'brand_logo.dart';

class PetAvatar extends StatelessWidget {

  const PetAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.hasStory = false,
  });
  final String imageUrl;
  final double radius;
  final bool hasStory;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: hasStory
          ? BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 2.5,
              ),
            )
          : null,
      padding: hasStory ? const EdgeInsets.all(2) : EdgeInsets.zero,
      child: CircleAvatar(
        radius: radius,
        backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
        backgroundColor: colorScheme.surface,
        child: imageUrl.isEmpty
            ? BrandLogo(customSize: radius, color: colorScheme.onSurfaceVariant)
            : null,
      ),
    );
  }
}
