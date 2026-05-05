import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Safely extracts a required path parameter from GoRouter state.
/// Returns null if the parameter is missing or empty.
String? safePathParam(GoRouterState state, String paramName) {
  final value = state.pathParameters[paramName];
  return (value != null && value.isNotEmpty) ? value : null;
}

/// Safely extracts a required query parameter from GoRouter state.
/// Returns null if the parameter is missing or empty.
String? safeQueryParam(GoRouterState state, String paramName) {
  final value = state.uri.queryParameters[paramName];
  return (value != null && value.isNotEmpty) ? value : null;
}

/// Error screen displayed when required route parameters are missing.
class InvalidRouteErrorScreen extends StatelessWidget {
  final String missingParam;

  const InvalidRouteErrorScreen({
    super.key,
    required this.missingParam,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invalid Link'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.link_off,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'This link is not valid',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'The required information ($missingParam) is missing or incomplete.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
