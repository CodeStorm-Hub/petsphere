import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petfolio/core/widgets/brand_logo.dart';
import 'package:petfolio/core/widgets/petfolio_widgets.dart';

class LikedPetsScreen extends StatelessWidget {
  const LikedPetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Pets'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: PetFolioGradientBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BrandLogo(customSize: 80),
                const SizedBox(height: 32),
                Text(
                  'No liked pets yet',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Explore discovery to like pets and they’ll show up here.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: cs.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => context.go('/discovery'),
                  icon: const Icon(Icons.search_rounded),
                  label: const Text('Go to Discovery'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

