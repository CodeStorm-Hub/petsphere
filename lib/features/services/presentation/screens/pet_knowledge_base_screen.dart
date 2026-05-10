import 'package:flutter/material.dart';

class PetKnowledgeBaseScreen extends StatelessWidget {
  const PetKnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Knowledge base is being migrated.\nPlease check back shortly.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
