import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:petfolio/core/widgets/petfolio_widgets.dart';
import '../controllers/breed_identifier_controller.dart';
import '../../data/breed_identifier_repository.dart';

class PetBreedIdentifierScreen extends ConsumerWidget {
  const PetBreedIdentifierScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(breedIdentifierProvider);
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
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    _buildImageSelector(context, ref, state, cs),
                    const SizedBox(height: 32),
                    if (state.isLoading)
                      _buildScanningState(cs)
                    else if (state.result != null)
                      _buildResultCard(state.result!, cs)
                    else
                      _buildInitialState(state, ref, cs),
                    const SizedBox(height: 48),
                    if (state.history.isNotEmpty) _buildHistory(state.history, cs),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageSelector(
      BuildContext context, WidgetRef ref, BreedIdentifierState state, ColorScheme cs) {
    return GestureDetector(
      onTap: state.isLoading
          ? null
          : () => _showPickerOptions(context, ref),
      child: Container(
        height: 300,
        width: double.infinity,
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: cs.primary.withValues(alpha: 0.2),
            width: 2,
          ),
          image: state.selectedImage != null
              ? DecorationImage(
                  image: FileImage(state.selectedImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: state.selectedImage == null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_rounded, size: 48, color: cs.primary),
                  const SizedBox(height: 16),
                  Text(
                    'Upload or Take a Photo',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }

  void _showPickerOptions(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Source',
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceButton(
                  context,
                  Icons.camera_alt_rounded,
                  'Camera',
                  () {
                    ref.read(breedIdentifierProvider.notifier).pickImage(ImageSource.camera);
                    Navigator.pop(context);
                  },
                ),
                _buildSourceButton(
                  context,
                  Icons.photo_library_rounded,
                  'Gallery',
                  () {
                    ref.read(breedIdentifierProvider.notifier).pickImage(ImageSource.gallery);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceButton(
      BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: cs.primaryContainer,
              child: Icon(icon, color: cs.onPrimaryContainer),
            ),
            const SizedBox(height: 8),
            Text(label, style: GoogleFonts.dmSans(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningState(ColorScheme cs) {
    return Column(
      children: [
        const LinearProgressIndicator(),
        const SizedBox(height: 24),
        Text(
          'Analyzing Image...',
          style: GoogleFonts.playfairDisplay(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Our AI is identifying the breed characteristics.',
          style: GoogleFonts.dmSans(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildResultCard(BreedScan result, ColorScheme cs) {
    return Card(
      elevation: 0,
      color: cs.primaryContainer.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: cs.primary.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result.breedName,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Match Confidence: ${(result.confidence * 100).toInt()}%',
                        style: GoogleFonts.dmSans(
                          color: cs.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.verified_rounded, color: cs.primary, size: 32),
              ],
            ),
            if (result.description != null) ...[
              const SizedBox(height: 16),
              Text(
                result.description!,
                style: GoogleFonts.dmSans(height: 1.5, color: cs.onSurfaceVariant),
              ),
            ],
            if (result.characteristics != null) ...[
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: result.characteristics!.entries.map((e) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.key,
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          e.value,
                          style: GoogleFonts.dmSans(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState(
      BreedIdentifierState state, WidgetRef ref, ColorScheme cs) {
    return Column(
      children: [
        Text(
          'Identify Your Pet',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Take a clear photo of your pet to identify its breed and learn about its traits.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmSans(
            color: cs.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 32),
        ElevatedButton.icon(
          onPressed: state.selectedImage == null || state.isLoading
              ? null
              : () => ref.read(breedIdentifierProvider.notifier).identify(),
          icon: const Icon(Icons.auto_fix_high_rounded),
          label: const Text('Start Identification'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildHistory(List<BreedScan> history, ColorScheme cs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Scans',
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: history.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final scan = history[index];
            return ListTile(
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: scan.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(scan.imageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: cs.surfaceContainerHighest,
                ),
              ),
              title: Text(scan.breedName, style: GoogleFonts.dmSans(fontWeight: FontWeight.bold)),
              subtitle: Text(
                '${(scan.confidence * 100).toInt()}% confidence',
                style: GoogleFonts.dmSans(fontSize: 12),
              ),
              trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: cs.outlineVariant),
              ),
            );
          },
        ),
      ],
    );
  }
}
