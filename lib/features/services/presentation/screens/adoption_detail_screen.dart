import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:petfolio/features/community/data/adoption_repository.dart';

class AdoptionDetailScreen extends ConsumerWidget {
  const AdoptionDetailScreen({super.key, required this.listingId});
  final String listingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listingsAsync = ref.watch(_listingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: listingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (listings) {
          final listing = listings.where((l) => l.id == listingId).firstOrNull;
          if (listing == null) {
            return const Center(child: Text('Listing not found'));
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 280,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: listing.imageUrl != null
                      ? Image.network(
                          listing.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _Placeholder(),
                        )
                      : _Placeholder(),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            listing.petName,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (listing.adoptionFee != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '\$${listing.adoptionFee!.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (listing.breed != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          listing.breed!,
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      _InfoChip(icon: Icons.pets, label: listing.species.toUpperCase()),
                      if (listing.ageMonths != null) ...[
                        const SizedBox(height: 8),
                        _InfoChip(icon: Icons.cake, label: listing.ageLabel),
                      ],
                      if (listing.gender != null) ...[
                        const SizedBox(height: 8),
                        _InfoChip(
                          icon: listing.gender == 'male' ? Icons.male : Icons.female,
                          label: listing.gender!.toUpperCase(),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (listing.description != null) ...[
                        Text(
                          'About',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          listing.description!,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 24),
                      ],
                      const _SectionTitle(title: 'Shelter'),
                      const SizedBox(height: 8),
                      _InfoRow(label: 'Name', value: listing.shelterName),
                      if (listing.location != null) ...[
                        const SizedBox(height: 8),
                        _InfoRow(label: 'Location', value: listing.location!),
                      ],
                      const SizedBox(height: 24),
                      if (listing.contactEmail != null) ...[
                        FilledButton.icon(
                          onPressed: () => _sendEmail(context, listing.contactEmail!),
                          icon: const Icon(Icons.email),
                          label: const Text('Contact Shelter'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _applyForAdoption(context, ref, listing),
                        icon: const Icon(Icons.favorite),
                        label: const Text('Apply to Adopt'),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _sendEmail(BuildContext context, String email) async {
    final uri = Uri.parse('mailto:$email?subject=Adoption Inquiry');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email: $email')),
        );
      }
    }
  }

  void _applyForAdoption(BuildContext context, WidgetRef ref, AdoptionListing listing) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _ApplySheet(listing: listing, onApplied: () {
        ref.invalidate(_listingsProvider);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted!')),
        );
      }),
    );
  }
}

final _listingsProvider = FutureProvider<List<AdoptionListing>>((ref) async {
  return adoptionRepository.fetchListings();
});

class _ApplySheet extends StatefulWidget {
  const _ApplySheet({required this.listing, required this.onApplied});
  final AdoptionListing listing;
  final VoidCallback onApplied;

  @override
  State<_ApplySheet> createState() => _ApplySheetState();
}

class _ApplySheetState extends State<_ApplySheet> {
  final _msgCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  Future<void> _apply() async {
    setState(() => _saving = true);
    try {
      await adoptionRepository.applyForAdoption(listingId: widget.listing.id, message: _msgCtrl.text.trim());
      widget.onApplied();
    } catch (e) {
      setState(() => _saving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Apply to Adopt ${widget.listing.petName}', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          TextField(
            controller: _msgCtrl,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Tell them about yourself and your home...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _saving ? null : _apply,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Submit Application'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: colorScheme.primary),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold));
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text('$label: ', style: TextStyle(color: colorScheme.onSurfaceVariant)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.secondaryContainer,
      child: Center(
        child: Icon(Icons.pets, size: 80, color: colorScheme.onSecondaryContainer),
      ),
    );
  }
}