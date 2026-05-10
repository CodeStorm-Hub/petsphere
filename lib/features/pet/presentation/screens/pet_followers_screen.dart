import 'package:flutter/material.dart';

class PetFollowersScreen extends StatelessWidget {
  final String? petId;
  final String? userId;
  final String title;

  const PetFollowersScreen({
    super.key,
    this.petId,
    this.userId,
    required this.title,
  }) : assert(petId != null || userId != null);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Follower lists are coming soon.\n\n'
            'petId: ${petId ?? '-'}\n'
            'userId: ${userId ?? '-'}',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

