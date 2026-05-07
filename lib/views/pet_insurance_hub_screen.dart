import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../controllers/pet_controller.dart';
import '../controllers/auth_controller.dart';
import '../repositories/feature_repositories.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────────────────

import '../controllers/pet_insurance_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Insurance Hub Screen — #52 backed by pet_insurance_claims
// ─────────────────────────────────────────────────────────────────────────────

class PetInsuranceHubScreen extends ConsumerStatefulWidget {
  const PetInsuranceHubScreen({super.key});

  @override
  ConsumerState<PetInsuranceHubScreen> createState() =>
      _PetInsuranceHubScreenState();
}

class _PetInsuranceHubScreenState
    extends ConsumerState<PetInsuranceHubScreen> {
  void _fileClaim() {
    final pet = ref.read(activePetProvider);
    final auth = ref.read(authProvider).user;
    if (pet == null || auth == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No active pet or not signed in')));
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FileClaimSheet(
        petId: pet.id,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePet = ref.watch(activePetProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final claimsAsync = ref.watch(insuranceClaimsProvider);

    // Show error if any from controller
    ref.listen(petInsuranceControllerProvider, (prev, next) {
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
            title: const Text('Insurance Hub',
                style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton.filledTonal(
                  onPressed: () {},
                  icon: const Icon(Icons.help_center_rounded)),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ActivePolicyCard(
                    petName: activePet?.name ?? 'Pet',
                    planName: 'PetProtect Plus',
                    policyNumber: 'PP-2024-9982',
                  ),
                  const SizedBox(height: 32),
                  const _CoverageBreakdown(),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Claims',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.history_rounded, size: 18),
                        label: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  claimsAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Text('Could not load claims: $e'),
                    data: (claims) => claims.isEmpty
                        ? const Text('No claims filed yet.',
                            style: TextStyle(color: Colors.grey))
                        : Column(
                            children:
                                claims.map((c) => _ClaimCard(claim: c)).toList(),
                          ),
                  ),
                  const SizedBox(height: 32),
                  const _DocumentVault(),
                  const SizedBox(height: 32),
                  const _InsurancePerks(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _fileClaim,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('File Claim'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
    );
  }
}

// ─── Policy Card ─────────────────────────────────────────────────────────────

class _ActivePolicyCard extends StatelessWidget {
  final String petName;
  final String planName;
  final String policyNumber;

  const _ActivePolicyCard(
      {required this.petName,
      required this.planName,
      required this.policyNumber});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.tertiary, colorScheme.tertiary.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
              color: colorScheme.tertiary.withAlpha(50),
              blurRadius: 24,
              offset: const Offset(0, 10))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: Colors.white.withAlpha(40),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text('ACTIVE POLICY',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.5)),
                    ),
                    const SizedBox(height: 16),
                    Text(planName,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5)),
                    Text('Protection for $petName',
                        style: TextStyle(
                            color: Colors.white.withAlpha(180),
                            fontSize: 15,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    shape: BoxShape.circle),
                child: const Icon(Icons.verified_user_rounded,
                    color: Colors.white, size: 40),
              ),
            ],
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PolicyInfo(
                  label: 'Deductible',
                  value: r'$250',
                  icon: Icons.remove_circle_outline_rounded),
              _PolicyInfo(
                  label: 'Reimbursement',
                  value: '90%',
                  icon: Icons.add_circle_outline_rounded),
              _PolicyInfo(
                  label: 'Annual Limit',
                  value: r'$15k',
                  icon: Icons.star_outline_rounded),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
                color: Colors.white.withAlpha(25),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withAlpha(30))),
            child: Row(
              children: [
                const Icon(Icons.event_repeat_rounded,
                    color: Colors.white, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Next renewal: Dec 12, 2024',
                      style: TextStyle(
                          color: Colors.white.withAlpha(220),
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white, size: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PolicyInfo extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _PolicyInfo(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withAlpha(150), size: 14),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withAlpha(150),
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900)),
      ],
    );
  }
}

// ─── Coverage Breakdown ───────────────────────────────────────────────────────

class _CoverageBreakdown extends StatelessWidget {
  const _CoverageBreakdown();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Coverage Details',
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              _CoverageItem(
                  title: 'Accidents & Injuries',
                  subtitle: r'Covered up to $15,000',
                  icon: Icons.emergency_rounded,
                  color: colorScheme.error),
              _CoverageItem(
                  title: 'Illnesses',
                  subtitle: 'Hereditary, chronic & more',
                  icon: Icons.medication_rounded,
                  color: colorScheme.primary),
              _CoverageItem(
                  title: 'Diagnostics',
                  subtitle: 'X-rays, MRIs & bloodwork',
                  icon: Icons.biotech_rounded,
                  color: colorScheme.secondary),
              _CoverageItem(
                  title: 'Dental Care',
                  subtitle: 'Injury & illness related',
                  icon: Icons.health_and_safety_rounded,
                  color: colorScheme.tertiary,
                  isLast: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _CoverageItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isLast;

  const _CoverageItem(
      {required this.title,
      required this.subtitle,
      required this.icon,
      required this.color,
      this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                    color: color.withAlpha(30),
                    borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(subtitle,
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                            fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.tertiary,
                  size: 20),
            ],
          ),
        ),
        if (!isLast) const Divider(indent: 64, endIndent: 16, height: 1),
      ],
    );
  }
}

// ─── DB-backed Claim Card ─────────────────────────────────────────────────────

class _ClaimCard extends StatelessWidget {
  final InsuranceClaim claim;
  const _ClaimCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = claim.status == 'approved'
        ? colorScheme.tertiary
        : claim.status == 'rejected'
            ? colorScheme.error
            : colorScheme.secondary;
    final icon = claim.status == 'approved'
        ? Icons.check_circle_rounded
        : claim.status == 'rejected'
            ? Icons.cancel_rounded
            : Icons.pending_rounded;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withAlpha(5),
              blurRadius: 10,
              offset: const Offset(0, 4))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration:
                BoxDecoration(color: color.withAlpha(30), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(claim.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(DateFormat('MMM d, y').format(claim.incurredAt),
                        style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12)),
                    const SizedBox(width: 8),
                    Container(
                        width: 4,
                        height: 4,
                        decoration: BoxDecoration(
                            color: colorScheme.outline,
                            shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(
                      claim.status.toUpperCase(),
                      style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Text(
            '\$${claim.amount.toStringAsFixed(2)}',
            style:
                const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ],
      ),
    );
  }
}

// ─── Document Vault ───────────────────────────────────────────────────────────

class _DocumentVault extends StatelessWidget {
  const _DocumentVault();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Document Vault',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            IconButton.filledTonal(
              onPressed: () {},
              icon: const Icon(Icons.cloud_upload_rounded, size: 20),
              style: IconButton.styleFrom(
                  backgroundColor: colorScheme.secondaryContainer),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh.withAlpha(150),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
                color: colorScheme.outlineVariant.withAlpha(150)),
          ),
          child: const Column(
            children: [
              _VaultItem(
                  name: 'Insurance_Policy_2024.pdf',
                  size: '1.2 MB',
                  icon: Icons.picture_as_pdf_rounded,
                  status: 'Synced'),
              _VaultItem(
                  name: 'Medical_Invoice_Oct.jpg',
                  size: '450 KB',
                  icon: Icons.image_rounded,
                  status: 'Synced'),
              _VaultItem(
                  name: 'Vaccine_Certificate.pdf',
                  size: '2.1 MB',
                  icon: Icons.picture_as_pdf_rounded,
                  status: 'Local Only',
                  isLast: true),
            ],
          ),
        ),
      ],
    );
  }
}

class _VaultItem extends StatelessWidget {
  final String name;
  final String size;
  final IconData icon;
  final String status;
  final bool isLast;

  const _VaultItem(
      {required this.name,
      required this.size,
      required this.icon,
      required this.status,
      this.isLast = false});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withAlpha(5), blurRadius: 10)
                  ],
                ),
                child: Icon(icon, color: colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('$size • $status',
                        style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert_rounded, size: 20)),
            ],
          ),
        ),
        if (!isLast)
          Divider(
              indent: 72,
              height: 1,
              color: colorScheme.outlineVariant.withAlpha(100)),
      ],
    );
  }
}

// ─── Insurance Perks ──────────────────────────────────────────────────────────

class _InsurancePerks extends StatelessWidget {
  const _InsurancePerks();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(32),
        image: const DecorationImage(
          image: NetworkImage(
              'https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&q=80&w=400'),
          fit: BoxFit.cover,
          opacity: 0.15,
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.stars_rounded, color: colorScheme.secondary, size: 48),
          const SizedBox(height: 16),
          const Text('Multi-Pet Advantage',
              style:
                  TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
          const SizedBox(height: 8),
          const Text(
            'Add another pet to your plan and save 15% on your total annual premium instantly.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Another Pet'),
            style: FilledButton.styleFrom(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── File Claim Sheet (DB-backed) ─────────────────────────────────────────────

class _FileClaimSheet extends ConsumerStatefulWidget {
  const _FileClaimSheet({required this.petId});
  final String petId;

  @override
  ConsumerState<_FileClaimSheet> createState() => _FileClaimSheetState();
}

class _FileClaimSheetState extends ConsumerState<_FileClaimSheet> {
  final _titleCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _incurredAt = DateTime.now();
  final bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _titleCtrl.text.trim();
    final amount = double.tryParse(_amountCtrl.text.trim());
    if (title.isEmpty || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in title and amount')));
      return;
    }

    final controller = ref.read(petInsuranceControllerProvider.notifier);
    await controller.fileClaim(
      petId: widget.petId,
      title: title,
      amount: amount,
      incurredAt: _incurredAt,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
    );

    if (mounted && !ref.read(petInsuranceControllerProvider).hasError) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Claim submitted successfully')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(32))),
      padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          MediaQuery.of(context).viewInsets.bottom + 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Text('File New Claim',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextField(
              controller: _titleCtrl,
              decoration: InputDecoration(
                  labelText: 'Claim Subject',
                  hintText: 'e.g., Emergency Surgery',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        labelText: 'Amount (\$)',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20)))),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _incurredAt,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setState(() => _incurredAt = picked);
                    }
                  },
                  child: InputDecorator(
                    decoration: InputDecoration(
                        labelText: 'Date',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20))),
                    child: Text(
                        DateFormat('MMM d, y').format(_incurredAt)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20)))),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _submit,
              style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
              child: _saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white))
                  : const Text('Submit Claim'),
            ),
          ),
        ],
      ),
    );
  }
}
