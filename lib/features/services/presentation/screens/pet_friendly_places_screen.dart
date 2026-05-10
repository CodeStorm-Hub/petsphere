import 'package:flutter/material.dart';

class PetFriendlyPlacesScreen extends StatelessWidget {
  const PetFriendlyPlacesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Pet-friendly places is being migrated.\nPlease check back shortly.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
