import 'package:flutter/material.dart';

class PetAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final bool hasStory;

  const PetAvatar({
    super.key,
    required this.imageUrl,
    this.radius = 20,
    this.hasStory = false,
  });

  @override
  Widget build(BuildContext context) {
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
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: Colors.grey.shade300,
      ),
    );
  }
}
