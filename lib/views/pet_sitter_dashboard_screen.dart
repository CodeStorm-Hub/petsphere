import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/pet_controller.dart';
import '../controllers/auth_controller.dart';
import '../repositories/feature_repositories.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

import '../controllers/pet_sitter_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Pet Sitter Dashboard — #51 backed by pet_sitter_jobs
// ─────────────────────────────────────────────────────────────────────────────

class PetSitterDashboardScreen extends ConsumerStatefulWidget {
  const PetSitterDashboardScreen({super.key});

  @override
  ConsumerState<PetSitterDashboardScreen> createState() =>
      _PetSitterDashboardScreenState();
}

class _PetSitterDashboardScreenState
    extends ConsumerState<PetSitterDashboardScreen> {
  void _postJob() {
    final auth = ref.read(authProvider).user;
    if (auth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in to post a job')));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PostJobSheet(
        ownerId: auth.id,
        petId: ref.read(activePetProvider)?.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final myJobsAsync = ref.watch(mySitterJobsProvider);
    final openJobsAsync = ref.watch(openSitterJobsProvider);

    // Show error if any from controller
    ref.listen(petSitterControllerProvider, (prev, next) {
      if (next is AsyncError) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: ${next.error}')));
      }
    });

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            title: Text(
              'Pet Sitters',
              style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  ref.invalidate(mySitterJobsProvider);
                  ref.invalidate(openSitterJobsProvider);
                },
                icon: const Icon(Icons.refresh_rounded),
                tooltip: 'Refresh',
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero CTA card
                  _SitterHeroCard(onPostJob: _postJob),
                  const SizedBox(height: 32),

                  // Open Jobs (discover sitters)
                  Text(
                    'Available Jobs Nearby',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  openJobsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error loading jobs: $e'),
                    data: (jobs) => jobs.isEmpty
                        ? _EmptyState(
                            icon: Icons.work_off_rounded,
                            message: 'No open jobs near you right now.',
                          )
                        : Column(
                            children:
                                jobs.map((j) => _JobCard(job: j)).toList(),
                          ),
                  ),
                  const SizedBox(height: 32),

                  // My Jobs
                  Text(
                    'My Bookings',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  myJobsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Error loading my jobs: $e'),
                    data: (jobs) => jobs.isEmpty
                        ? _EmptyState(
                            icon: Icons.house_siding_rounded,
                            message:
                                'No bookings yet. Post a job to find a sitter!',
                          )
                        : Column(
                            children: jobs
                                .map((j) => _BookingCard(job: j))
                                .toList(),
                          ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _postJob,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Post a Job'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}

// ─── Hero Card ────────────────────────────────────────────────────────────────

class _SitterHeroCard extends StatelessWidget {
  final VoidCallback onPostJob;
  const _SitterHeroCard({required this.onPostJob});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Need a Sitter?',
                  style: GoogleFonts.playfairDisplay(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Find trusted neighbors to watch your pet while you\'re away.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton.tonal(
                  onPressed: onPostJob,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Post a Job'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.house_siding_rounded,
            size: 80,
            color: Colors.white.withValues(alpha: 0.2),
          ),
        ],
      ),
    );
  }
}

// ─── Open Job Card (for sitter discovery) ────────────────────────────────────

class _JobCard extends StatelessWidget {
  final SitterJob job;
  const _JobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('MMM d');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.pets_rounded,
                color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.description?.isNotEmpty == true
                      ? job.description!
                      : 'Pet sitting needed',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '${fmt.format(job.startDate)} – ${fmt.format(job.endDate)}',
                  style: TextStyle(
                      color: colorScheme.onSurfaceVariant, fontSize: 13),
                ),
              ],
            ),
          ),
          if (job.ratePerDay != null) ...[
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${job.ratePerDay!.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                    fontSize: 16,
                  ),
                ),
                const Text('/ day',
                    style:
                        TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ─── My Booking Card ──────────────────────────────────────────────────────────

class _BookingCard extends StatelessWidget {
  final SitterJob job;
  const _BookingCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('MMM d');
    final statusColor = switch (job.status) {
      'confirmed' => colorScheme.tertiary,
      'completed' => colorScheme.secondary,
      'cancelled' => colorScheme.error,
      _ => colorScheme.primary,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.description?.isNotEmpty == true
                      ? job.description!
                      : 'Pet Sitting',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${fmt.format(job.startDate)} – ${fmt.format(job.endDate)}',
                  style: TextStyle(
                      color: colorScheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              job.status.toUpperCase(),
              style: TextStyle(
                color: statusColor,
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  const _EmptyState({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.onSurfaceVariant, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                  color: colorScheme.onSurfaceVariant, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Post Job Sheet ───────────────────────────────────────────────────────────

class _PostJobSheet extends ConsumerStatefulWidget {
  final String ownerId;
  final String? petId;

  const _PostJobSheet({required this.ownerId, this.petId});

  @override
  ConsumerState<_PostJobSheet> createState() => _PostJobSheetState();
}

class _PostJobSheetState extends ConsumerState<_PostJobSheet> {
  final _descCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  DateTime _start = DateTime.now().add(const Duration(days: 1));
  DateTime _end = DateTime.now().add(const Duration(days: 3));
  final bool _saving = false;

  @override
  void dispose() {
    _descCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isStart) async {
    final initial = isStart ? _start : _end;
    final first = isStart ? DateTime.now() : _start;
    final last = DateTime.now().add(const Duration(days: 365));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _start = picked;
        if (_end.isBefore(_start)) {
          _end = _start.add(const Duration(days: 1));
        }
      } else {
        _end = picked;
      }
    });
  }

  Future<void> _submit() async {
    final controller = ref.read(petSitterControllerProvider.notifier);
    await controller.postJob(
      petId: widget.petId,
      startDate: _start,
      endDate: _end,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      ratePerDay: double.tryParse(_rateCtrl.text.trim()),
    );

    if (mounted && !ref.read(petSitterControllerProvider).hasError) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job posted successfully!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('MMM d, y');
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Post a Sitter Job',
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _pickDate(true),
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'Start Date',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                    ),
                    child: Text(fmt.format(_start),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => _pickDate(false),
                  borderRadius: BorderRadius.circular(16),
                  child: InputDecorator(
                    decoration: InputDecoration(
                      labelText: 'End Date',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16)),
                      prefixIcon: const Icon(Icons.calendar_today_rounded),
                    ),
                    child: Text(fmt.format(_end),
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descCtrl,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'e.g., Friendly dog needs walking twice a day',
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _rateCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: 'Rate per day (\$)',
              prefixIcon: const Icon(Icons.attach_money_rounded),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
              child: ref.watch(petSitterControllerProvider).isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Post Job'),
            ),
          ),
        ],
      ),
    );
  }
}
