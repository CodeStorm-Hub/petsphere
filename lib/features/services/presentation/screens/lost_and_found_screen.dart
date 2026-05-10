import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/features/community/data/lost_found_repository.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Lost & Found Screen — #34 backed by lost_and_found_reports table
// ─────────────────────────────────────────────────────────────────────────────

final _lostFoundProvider = FutureProvider.family<List<LostFoundReport>, String>(
  (ref, status) async {
    return lostFoundRepository.fetchReports(status: status);
  },
);

class LostAndFoundScreen extends ConsumerWidget {
  const LostAndFoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverAppBar.large(
              title: const Text(
                'Lost & Found',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton.filledTonal(
                  onPressed: () => _openReportSheet(context, ref),
                  icon: const Icon(Icons.add_alert_rounded),
                  tooltip: 'Report a pet',
                ),
                const SizedBox(width: 8),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(64),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: TabBar(
                      dividerColor: Colors.transparent,
                      indicatorSize: TabBarIndicatorSize.tab,
                      indicator: BoxDecoration(
                        color: colorScheme.primary,
                        borderRadius: BorderRadius.circular(28),
                      ),
                      labelColor: colorScheme.onPrimary,
                      unselectedLabelColor: colorScheme.onSurfaceVariant,
                      tabs: const [
                        Tab(text: 'Lost Pets'),
                        Tab(text: 'Found Pets'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
          body: const TabBarView(
            children: [
              _ReportList(status: 'lost'),
              _ReportList(status: 'found'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _openReportSheet(context, ref),
          label: const Text('Report Pet'),
          icon: const Icon(Icons.add_alert_rounded),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
        ),
      ),
    );
  }

  void _openReportSheet(BuildContext context, WidgetRef ref) {
    final auth = ref.read(authProvider);
    if (auth.user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign in to report a lost/found pet')),
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => _ReportSheet(
        reporterId: auth.user!.id,
        onSaved: () {
          ref.invalidate(_lostFoundProvider('lost'));
          ref.invalidate(_lostFoundProvider('found'));
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Report list
// ─────────────────────────────────────────────────────────────────────────────

class _ReportList extends ConsumerWidget {
  final String status;
  const _ReportList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(_lostFoundProvider(status));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (reports) {
        if (reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.search_off,
                  size: 64,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 12),
                Text(
                  'No ${status == 'lost' ? 'lost' : 'found'} pet reports',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                const Text('Tap the button below to add one'),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: reports.length,
          itemBuilder: (context, index) => _ReportCard(report: reports[index]),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single report card
// ─────────────────────────────────────────────────────────────────────────────

class _ReportCard extends StatelessWidget {
  final LostFoundReport report;
  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLost = report.status == 'lost';

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant.withAlpha(100)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image or placeholder
          Stack(
            children: [
              SizedBox(
                height: 200,
                width: double.infinity,
                child: report.imageUrl != null
                    ? Image.network(
                        report.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            _PetImagePlaceholder(isLost: isLost),
                      )
                    : _PetImagePlaceholder(isLost: isLost),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: _StatusBadge(isLost: isLost),
              ),
              if (report.hasReward)
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '\$${report.rewardAmount!.toStringAsFixed(0)} REWARD',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w900,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        report.petName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    Text(
                      DateFormat('MMM d').format(report.createdAt),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                if (report.breed != null)
                  Text(
                    report.breed!,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                if (report.lastSeenLocation != null) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          report.lastSeenLocation!,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
                if (report.description != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    report.description!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (report.contactInfo != null)
                  FilledButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.phone_rounded, size: 16),
                    label: const Text('Contact Reporter'),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final bool isLost;
  const _StatusBadge({required this.isLost});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: (isLost ? colorScheme.error : colorScheme.tertiary).withAlpha(
          230,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLost
                ? Icons.error_outline_rounded
                : Icons.check_circle_outline_rounded,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            isLost ? 'LOST' : 'FOUND',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PetImagePlaceholder extends StatelessWidget {
  final bool isLost;
  const _PetImagePlaceholder({required this.isLost});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: isLost
          ? colorScheme.errorContainer
          : colorScheme.tertiaryContainer,
      child: Center(
        child: Icon(
          isLost ? Icons.pets : Icons.search,
          size: 64,
          color: isLost
              ? colorScheme.onErrorContainer
              : colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Report creation sheet
// ─────────────────────────────────────────────────────────────────────────────

class _ReportSheet extends StatefulWidget {
  final String reporterId;
  final VoidCallback onSaved;
  const _ReportSheet({required this.reporterId, required this.onSaved});

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  final _formKey = GlobalKey<FormState>();
  final _petNameCtrl = TextEditingController();
  final _breedCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _rewardCtrl = TextEditingController();
  String _status = 'lost';
  String _petType = 'dog';
  bool _saving = false;

  @override
  void dispose() {
    _petNameCtrl.dispose();
    _breedCtrl.dispose();
    _locationCtrl.dispose();
    _descCtrl.dispose();
    _contactCtrl.dispose();
    _rewardCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final report = LostFoundReport(
      id: '',
      reporterId: widget.reporterId,
      status: _status,
      petName: _petNameCtrl.text.trim(),
      petType: _petType,
      breed: _breedCtrl.text.trim().isEmpty ? null : _breedCtrl.text.trim(),
      lastSeenLocation: _locationCtrl.text.trim().isEmpty
          ? null
          : _locationCtrl.text.trim(),
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      contactInfo: _contactCtrl.text.trim().isEmpty
          ? null
          : _contactCtrl.text.trim(),
      rewardAmount: double.tryParse(_rewardCtrl.text.trim()),
      isActive: true,
      createdAt: DateTime.now(),
    );

    try {
      await lostFoundRepository.createReport(report);
      if (!mounted) return;
      widget.onSaved();
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report submitted successfully')),
      );
    } catch (e) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      builder: (_, ctrl) => Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: ctrl,
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                'Report a Pet',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              // Status
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'lost', label: Text('Lost Pet')),
                  ButtonSegment(value: 'found', label: Text('Found Pet')),
                ],
                selected: {_status},
                onSelectionChanged: (s) => setState(() => _status = s.first),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _petNameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Pet Name *',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _petType,
                decoration: const InputDecoration(
                  labelText: 'Animal Type',
                  border: OutlineInputBorder(),
                ),
                items: ['dog', 'cat', 'bird', 'rabbit', 'other']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _petType = v!),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _breedCtrl,
                decoration: const InputDecoration(
                  labelText: 'Breed (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(
                  labelText: 'Last seen location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Description / identifying features',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact info (phone/email)',
                  border: OutlineInputBorder(),
                ),
              ),
              if (_status == 'lost') ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _rewardCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Reward amount (optional)',
                    prefixText: r'$',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Submit Report'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
