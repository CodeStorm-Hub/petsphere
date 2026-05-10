import 'package:flutter/material.dart';

class PetSitterDashboardScreen extends StatelessWidget {
  const PetSitterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Sitter dashboard is being migrated.\nPlease check back shortly.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
