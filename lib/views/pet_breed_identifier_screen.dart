import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/pet_breed_controller.dart';
import '../repositories/feature_repositories.dart';

class PetBreedIdentifierScreen extends ConsumerStatefulWidget {
  const PetBreedIdentifierScreen({super.key});

  @override
  ConsumerState<PetBreedIdentifierScreen> createState() => _PetBreedIdentifierScreenState();
}

class _PetBreedIdentifierScreenState extends ConsumerState<PetBreedIdentifierScreen> {
  void _startScan() async {
    // In a real app, we would use image_picker here.
    // For this demo, we'll use a dummy path.
    await ref.read(breedIdentifierControllerProvider.notifier).identifyBreed('dummy_path.jpg');
    if (!mounted) return;
    
    final state = ref.read(breedIdentifierControllerProvider);
    if (state.hasValue && state.value != null) {
      _showResults(state.value!);
    } else if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${state.error}')),
      );
    }
  }

  void _showResults(BreedScan result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BreedResultsSheet(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final scanState = ref.watch(breedIdentifierControllerProvider);
    final isScanning = scanState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Breed Identifier', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.history_rounded)),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _ScannerPreview(isScanning: isScanning),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      isScanning ? 'Analyzing Biological Features...' : 'Identify Any Breed',
                      key: ValueKey(isScanning),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Our advanced neural network identifies over 400+ breeds with industry-leading accuracy.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14, height: 1.5),
                  ),
                  const SizedBox(height: 48),
                  _ScannerActions(onCameraTap: _startScan, isScanning: isScanning),
                  const SizedBox(height: 48),
                  const _ScanHistory(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerPreview extends StatelessWidget {
  final bool isScanning;
  const _ScannerPreview({required this.isScanning});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 400,
      width: double.infinity,
      margin: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: colorScheme.primary.withAlpha(50), width: 2),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1543466835-00a732f3b043?auto=format&fit=crop&q=80&w=1000'),
          fit: BoxFit.cover,
        ),
        boxShadow: [
          BoxShadow(color: colorScheme.primary.withAlpha(30), blurRadius: 40, spreadRadius: -10),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (isScanning) _ScannerAnimation(),
          Positioned(
            top: 20,
            right: 20,
            child: IconButton.filled(
              onPressed: () {},
              icon: const Icon(Icons.flip_camera_ios_rounded),
              style: IconButton.styleFrom(backgroundColor: Colors.black54),
            ),
          ),
          if (isScanning)
            Positioned(
              bottom: 32,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(200),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Detecting Facial Landmarks...',
                      style: TextStyle(color: Colors.white.withAlpha(240), fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          // Corners logic (Decoration)
          ...List.generate(4, (i) {
            final isTop = i < 2;
            final isLeft = i % 2 == 0;
            return Positioned(
              top: isTop ? 30 : null,
              bottom: isTop ? null : 30,
              left: isLeft ? 30 : null,
              right: isLeft ? null : 30,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  border: Border(
                    top: isTop ? BorderSide(color: Colors.white.withAlpha(150), width: 4) : BorderSide.none,
                    bottom: !isTop ? BorderSide(color: Colors.white.withAlpha(150), width: 4) : BorderSide.none,
                    left: isLeft ? BorderSide(color: Colors.white.withAlpha(150), width: 4) : BorderSide.none,
                    right: !isLeft ? BorderSide(color: Colors.white.withAlpha(150), width: 4) : BorderSide.none,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ScannerAnimation extends StatefulWidget {
  @override
  State<_ScannerAnimation> createState() => _ScannerAnimationState();
}

class _ScannerAnimationState extends State<_ScannerAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          children: [
            Positioned(
              top: 400 * Curves.easeInOut.transform(_controller.value),
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.transparent, Theme.of(context).colorScheme.primary.withAlpha(80), Colors.transparent],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  Container(
                    height: 3,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: [
                        BoxShadow(color: Theme.of(context).colorScheme.primary, blurRadius: 15, spreadRadius: 2),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ScannerActions extends StatelessWidget {
  final VoidCallback onCameraTap;
  final bool isScanning;
  const _ScannerActions({required this.onCameraTap, required this.isScanning});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 72,
          child: FilledButton.icon(
            onPressed: isScanning ? null : onCameraTap,
            icon: const Icon(Icons.center_focus_strong_rounded, size: 28),
            label: const Text('Start Precision Scan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              elevation: 4,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 64,
          child: OutlinedButton.icon(
            onPressed: isScanning ? null : () {},
            icon: const Icon(Icons.photo_library_rounded, size: 24),
            label: const Text('Import from Gallery', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              side: BorderSide(color: Theme.of(context).colorScheme.outline, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _BreedResultsSheet extends StatelessWidget {
  final BreedScan result;
  const _BreedResultsSheet({required this.result});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.6,
      builder: (_, controller) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ListView(
          controller: controller,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Container(width: 40, height: 4, decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text('Scan Complete', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 32),
            _MatchResultCard(
              breed: result.breedName,
              confidence: result.confidence,
              image: result.imageUrl ?? 'https://images.unsplash.com/photo-1552053831-71594a27632d?auto=format&fit=crop&q=80&w=400',
              isPrimary: true,
            ),
            const SizedBox(height: 32),
            Text('Breed Characteristics', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer.withAlpha(100),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text(
                    result.description ?? 'No description available.',
                    style: const TextStyle(fontSize: 14, height: 1.6),
                  ),
                  const SizedBox(height: 20),
                  if (result.characteristics != null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: result.characteristics!.entries.map((e) => _StatItem(
                        label: e.key,
                        value: e.value,
                        icon: _getIconForStat(e.key),
                      )).toList(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 64),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text('Add to Pet Profile', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Not my pet? Try again'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  IconData _getIconForStat(String key) {
    switch (key.toLowerCase()) {
      case 'lifespan': return Icons.favorite_rounded;
      case 'weight': return Icons.monitor_weight_rounded;
      case 'group': return Icons.groups;
      default: return Icons.info_outline;
    }
  }
}

class _MatchResultCard extends StatelessWidget {
  final String breed;
  final double confidence;
  final String image;
  final bool isPrimary;

  const _MatchResultCard({required this.breed, required this.confidence, required this.image, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPrimary ? colorScheme.primary.withAlpha(20) : colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: isPrimary ? colorScheme.primary.withAlpha(80) : colorScheme.outlineVariant, width: isPrimary ? 2 : 1),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(image, width: 72, height: 72, fit: BoxFit.cover),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(breed, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: isPrimary ? colorScheme.primary : null)),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: (isPrimary ? colorScheme.primary : Colors.grey).withAlpha(30),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${(confidence * 100).toInt()}% Match', style: TextStyle(color: isPrimary ? colorScheme.primary : Colors.grey[700], fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          if (isPrimary) Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 28),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Icon(icon, color: colorScheme.primary, size: 20),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 10, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _ScanHistory extends ConsumerWidget {
  const _ScanHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(breedScanHistoryProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Identifications', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            TextButton(onPressed: () {}, child: const Text('View All')),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 120,
          child: historyAsync.when(
            data: (history) => history.isEmpty 
              ? const Center(child: Text('No history yet'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: history.length,
                  itemBuilder: (context, index) {
                    final scan = history[index];
                    return Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, 4))],
                        image: DecorationImage(
                          image: NetworkImage(scan.imageUrl ?? 'https://images.unsplash.com/photo-1543466835-00a732f3b043?auto=format&fit=crop&q=80&w=200'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
                          ),
                          child: Text(scan.breedName, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        ),
                      ),
                    );
                  },
                ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
      ],
    );
  }
}

