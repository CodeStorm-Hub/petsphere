import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:petfolio/core/widgets/petfolio_widgets.dart';
import 'package:petfolio/features/services/presentation/controllers/pet_insurance_controller.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/services/data/insurance_repository.dart';
import 'package:petfolio/core/theme/app_theme.dart';

class PetInsuranceHubScreen extends ConsumerWidget {
  const PetInsuranceHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePet = ref.watch(activePetProvider);
    final claimsAsync = ref.watch(insuranceClaimsProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: PetFolioGradientBackground(
        child: CustomScrollView(
          slivers: [
            const SliverAppBar.large(
              title: Text(
                'Insurance Hub',
                style: TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              floating: true,
            ),
            
            // ── Active Policy Status ────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.md),
                child: GlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activePet?.name ?? 'No active pet',
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Comprehensive Coverage',
                                style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.primary),
                              ),
                            ],
                          ),
                          AnimatedBadge(
                            child: Text(
                              'ACTIVE',
                              style: TextStyle(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTheme.lg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatItem(context, 'Monthly', '\$42.50'),
                          _buildStatItem(context, 'Deductible', '\$250'),
                          _buildStatItem(context, 'Coverage', '90%'),
                        ],
                      ),
                    ],
                  ),
                ).animate().fade().slideY(begin: 0.1, end: 0),
              ),
            ),

            // ── Recent Claims Header ──────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.lg, vertical: AppTheme.md),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SectionTag('Recent Claims'),
                    TextButton(
                      onPressed: () {}, // TODO: View all claims
                      child: const Text('View All'),
                    ),
                  ],
                ),
              ),
            ),

            // ── Claims List ──────────────────────────────────────────
            claimsAsync.when(
              data: (claims) => claims.isEmpty
                  ? SliverFillRemaining(
                      hasScrollBody: false,
                      child: _buildEmptyState(context),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final claim = claims[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: AppTheme.md, vertical: 6),
                            child: _ClaimCard(claim: claim),
                          );
                        },
                        childCount: claims.length,
                      ),
                    ),
              loading: () => const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, _) => SliverFillRemaining(
                child: Center(child: Text('Error: $err')),
              ),
            ),

            const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
          ],
        ),
      ),
      floatingActionButton: PillButton(
        icon: Icons.add_circle_outline,
        onPressed: activePet == null ? null : () => _showFileClaimSheet(context, ref, activePet.id),
        child: const Text('File New Claim'),
      ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_turned_in_outlined, size: 64, color: colorScheme.outline),
          const SizedBox(height: AppTheme.md),
          Text(
            'No claims yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Text(
            'Your medical expenses will appear here.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: colorScheme.outline),
          ),
        ],
      ),
    );
  }

  void _showFileClaimSheet(BuildContext context, WidgetRef ref, String petId) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FileClaimSheet(petId: petId),
    );
  }
}

class _ClaimCard extends StatelessWidget {
  const _ClaimCard({required this.claim});
  final InsuranceClaim claim;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateStr = DateFormat('MMM d, y').format(claim.incurredAt);

    return GlassCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.description_outlined, size: 24, color: colorScheme.onPrimaryContainer),
          ),
          const SizedBox(width: AppTheme.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  claim.title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  dateStr,
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${claim.amount.toStringAsFixed(2)}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _getStatusColor(claim.status).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  claim.status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: _getStatusColor(claim.status),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _FileClaimSheet extends ConsumerStatefulWidget {
  const _FileClaimSheet({required this.petId});
  final String petId;

  @override
  ConsumerState<_FileClaimSheet> createState() => _FileClaimSheetState();
}

class _FileClaimSheetState extends ConsumerState<_FileClaimSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(24, 12, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'New Insurance Claim',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontFamily: 'Playfair Display',
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Claim Title',
                  hintText: 'e.g., Annual Vaccination',
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixIcon: Icon(Icons.attach_money),
                      ),
                      validator: (v) {
                        if (v?.isEmpty ?? true) return 'Required';
                        if (double.tryParse(v!) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime.now().subtract(const Duration(days: 90)),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) setState(() => _selectedDate = picked);
                      },
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(DateFormat('MMM d').format(_selectedDate)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 32),
              PillButton(
                onPressed: _submit,
                child: const Text('Submit Claim'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await ref.read(petInsuranceControllerProvider.notifier).fileClaim(
      petId: widget.petId,
      title: _titleController.text.trim(),
      amount: double.parse(_amountController.text),
      incurredAt: _selectedDate,
      notes: _notesController.text.trim(),
    );

    if (mounted) Navigator.pop(context);
  }
}
