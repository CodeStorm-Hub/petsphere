import 'package:flutter/material.dart';

class PetBreedIdentifierScreen extends StatelessWidget {
  const PetBreedIdentifierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Breed Identifier')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Breed identifier is temporarily disabled while the feature layer is being consolidated.',
            textAlign: TextAlign.center,
            style: TextStyle(color: cs.onSurfaceVariant),
          ),
        ),
      ),
    );
  }
}

