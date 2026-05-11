import 'package:flutter/material.dart';
import 'package:petfolio/core/theme/icon_sizes.dart';
import 'package:petfolio/core/theme/spacing.dart';
import 'brand_logo.dart';

class PetAvatar extends StatelessWidget {
  const PetAvatar({
    super.key,
    required this.imageUrl,
    this.radius = AppIconSizes.s,
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
                color: colorScheme.primary,
                width: 2.5,
              ),
            )
          : null,
      padding: hasStory ? const EdgeInsets.all(AppSpacing.tiny) : EdgeInsets.zero,
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

