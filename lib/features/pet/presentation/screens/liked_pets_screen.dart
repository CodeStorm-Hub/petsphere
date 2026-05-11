import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petfolio/core/widgets/petfolio_empty_state.dart';

class LikedPetsScreen extends StatelessWidget {
  const LikedPetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Removed unused cs

    return Scaffold(
      appBar: AppBar(
        title: const Text('Liked Pets'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: PetfolioEmptyState(
        icon: Icons.favorite_border_rounded,
        title: 'No liked pets yet',
        message: 'Explore discovery to like pets and they’ll show up here.',
        buttonText: 'Go to Discovery',
        onButtonPressed: () => context.go('/discovery'),
      ),
    );
  }
}

