import 'package:flutter/material.dart';

class StoryViewerScreen extends StatelessWidget {
  final String petId;

  const StoryViewerScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stories')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Story viewer is being migrated.\nPlease check back shortly.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
