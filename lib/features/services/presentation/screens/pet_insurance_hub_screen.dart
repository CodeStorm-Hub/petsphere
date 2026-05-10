import 'package:flutter/material.dart';

class PetInsuranceHubScreen extends StatelessWidget {
  const PetInsuranceHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Insurance hub is being migrated.\nPlease check back shortly.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
