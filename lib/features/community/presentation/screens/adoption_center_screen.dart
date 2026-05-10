import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/features/community/data/adoption_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

final _listingsProvider = FutureProvider.family<List<AdoptionListing>, String>((
  ref,
  species,
) async {
  return adoptionRepository.fetchListings(
    species: species == 'All' ? null : species,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Adoption Center Screen — #37
// ─────────────────────────────────────────────────────────────────────────────

class AdoptionCenterScreen extends ConsumerStatefulWidget {
  const AdoptionCenterScreen({super.key});

  @override
  ConsumerState<AdoptionCenterScreen> createState() =>
      _AdoptionCenterScreenState();
}

class _AdoptionCenterScreenState extends ConsumerState<AdoptionCenterScreen> {
  String _species = 'All';
  final List<String> _speciesList = [
    'All',
    'dog',
    'cat',
    'bird',
    'rabbit',
    'other',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final async = ref.watch(_listingsProvider(_species));

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (_, _) => [
          SliverAppBar.large(
            title: const Text(
              'Adoption Center',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton.filledTonal(
                onPressed: () {},
                icon: const Icon(Icons.tune_rounded),
                tooltip: 'Filter',
              ),
              const SizedBox(width: 8),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                child: SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _speciesList.length,
                    itemBuilder: (_, i) {
                      final s = _speciesList[i];
                      final selected = _species == s;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(_label(s)),
                          selected: selected,
                          onSelected: (_) => setState(() => _species = s),
                          selectedColor: colorScheme.primary,
                          labelStyle: TextStyle(
                            color: selected
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
        body: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (listings) => listings.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pets, size: 64, color: Colors.grey),
                      SizedBox(height: 12),
                      Text('No pets available for adoption right now.'),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: listings.length,
                  itemBuilder: (_, i) => _ListingCard(
                    listing: listings[i],
                    onApply: () => _openApplySheet(context, listings[i]),
                  ),
                ),
        ),
      ),
    );
  }

  String _label(String s) {
    if (s == 'All') return 'All';
    return '${s[0].toUpperCase()}${s.substring(1)}s';
  }

  void _openApplySheet(BuildContext context, AdoptionListing listing) {
    final auth = ref.read(authProvider);
    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to apply for adoption')),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ApplySheet(
        listing: listing,
        onApplied: () => ref.invalidate(_listingsProvider(_species)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Listing card
// ─────────────────────────────────────────────────────────────────────────────

class _ListingCard extends StatelessWidget {
  const _ListingCard({required this.listing, required this.onApply});
  final AdoptionListing listing;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onApply,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: listing.imageUrl != null
                  ? Image.network(
                      listing.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, _, _) =>
                          _speciesIcon(listing.species, colorScheme),
                    )
                  : _speciesIcon(listing.species, colorScheme),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.petName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (listing.breed != null)
                    Text(
                      listing.breed!,
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (listing.ageMonths != null) ...[
                        Icon(
                          Icons.cake_rounded,
                          size: 12,
                          color: colorScheme.primary,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          listing.ageLabel,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (listing.gender != null) ...[
                        Icon(
                          listing.gender == 'male'
                              ? Icons.male_rounded
                              : Icons.female_rounded,
                          size: 12,
                          color: listing.gender == 'male'
                              ? Colors.blue
                              : Colors.pink,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        listing.adoptionFee != null
                            ? 'Adopt · \$${listing.adoptionFee!.toStringAsFixed(0)}'
                            : 'Adopt · Free',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _speciesIcon(String species, ColorScheme cs) => Container(
    color: cs.secondaryContainer,
    child: Center(
      child: Icon(Icons.pets, size: 48, color: cs.onSecondaryContainer),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Apply for adoption sheet
// ─────────────────────────────────────────────────────────────────────────────

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
      await adoptionRepository.applyForAdoption(
        listingId: widget.listing.id,
        message: _msgCtrl.text.trim(),
      );
      if (!mounted) return;
      widget.onApplied();
      Navigator.pop(context);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Application submitted!')));
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final listing = widget.listing;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Adopt ${listing.petName}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          Text(
            '${listing.shelterName}${listing.location != null ? ' · ${listing.location}' : ''}',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          if (listing.description != null)
            Text(
              listing.description!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
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
          if (listing.contactEmail != null)
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(listing.contactEmail!),
              dense: true,
            ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _saving ? null : _apply,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Submit Application'),
          ),
        ],
      ),
    );
  }
}
