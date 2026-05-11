import 'package:flutter/material.dart';
import 'package:petfolio/core/theme/icon_sizes.dart';

class OwnerAvatar extends StatelessWidget {
  const OwnerAvatar({
    super.key,
    required this.imageUrl,
    this.radius = AppIconSizes.s,
    this.onTap,
  });

  final String imageUrl;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: radius,
        backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
        backgroundColor: colorScheme.surfaceContainerHighest,
        child: imageUrl.isEmpty
            ? Icon(
                Icons.person_outline,
                size: radius,
                color: colorScheme.onSurfaceVariant,
              )
            : null,
      ),
    );
  }
}
