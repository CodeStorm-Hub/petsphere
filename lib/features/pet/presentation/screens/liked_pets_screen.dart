import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:petfolio/core/widgets/brand_logo.dart';

class LikedPetsScreen extends StatelessWidget {
  const LikedPetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Liked pets')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const BrandLogo(customSize: 56),
              const SizedBox(height: 16),
              Text(
                'No liked pets yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Explore discovery to like pets and they’ll show up here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.go('/discovery'),
                icon: const Icon(Icons.search),
                label: const Text('Go to discovery'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

