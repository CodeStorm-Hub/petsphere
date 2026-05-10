import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:petfolio/core/widgets/petfolio_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

/// Safely extracts a required path parameter from GoRouter state.
String? safePathParam(GoRouterState state, String paramName) {
  final value = state.pathParameters[paramName];
  return (value != null && value.isNotEmpty) ? value : null;
}

/// Safely extracts a required query parameter from GoRouter state.
String? safeQueryParam(GoRouterState state, String paramName) {
  final value = state.uri.queryParameters[paramName];
  return (value != null && value.isNotEmpty) ? value : null;
}

/// Error screen displayed when required route parameters are missing.
class InvalidRouteErrorScreen extends StatelessWidget {
  final String missingParam;

  const InvalidRouteErrorScreen({super.key, required this.missingParam});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Invalid Link',
          style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: PetFolioGradientBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: cs.errorContainer.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.link_off_rounded,
                    size: 64,
                    color: cs.error,
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Something went wrong',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'The required information ($missingParam) is missing or incomplete. Please try again or return to the home screen.',
                  style: GoogleFonts.dmSans(
                    color: cs.onSurfaceVariant,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Go Home'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
