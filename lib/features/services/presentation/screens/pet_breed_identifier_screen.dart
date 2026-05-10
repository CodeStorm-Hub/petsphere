import 'package:flutter/material.dart';
import 'package:petfolio/core/widgets/petfolio_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class PetBreedIdentifierScreen extends StatelessWidget {
  const PetBreedIdentifierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Breed Identifier',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: PetFolioGradientBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome_rounded,
                  size: 80,
                  color: cs.primary.withValues(alpha: 0.5),
                ),
                const SizedBox(height: 32),
                Text(
                  'Coming Soon',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'We are refining our AI model to provide even more accurate breed identification for your furry friends.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.dmSans(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

