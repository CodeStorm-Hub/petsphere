import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/pet_controller.dart';

class PetInsuranceHubScreen extends ConsumerStatefulWidget {
  const PetInsuranceHubScreen({super.key});

  @override
  ConsumerState<PetInsuranceHubScreen> createState() => _PetInsuranceHubScreenState();
}

class _PetInsuranceHubScreenState extends ConsumerState<PetInsuranceHubScreen> {


  void _fileClaim() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FileClaimSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final List<Map<String, dynamic>> claims = [
      {'title': 'Annual Wellness Exam', 'date': 'Oct 12, 2024', 'amount': 145.00, 'status': 'Approved', 'icon': Icons.check_circle_rounded, 'color': colorScheme.tertiary},
      {'title': 'Ear Infection Treatment', 'date': 'Sep 28, 2024', 'amount': 88.50, 'status': 'Pending', 'icon': Icons.pending_rounded, 'color': colorScheme.secondary},
    ];

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            title: const Text('Insurance Hub', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.help_center_rounded)),
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
                    petName: pet.activePet?.name ?? 'Pet',
                    planName: 'PetProtect Plus',
                    policyNumber: 'PP-2024-9982',
                  ),
                  const SizedBox(height: 32),
                  _CoverageBreakdown(),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Recent Claims', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.history_rounded, size: 18),
                        label: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...claims.map((claim) => _ClaimCard(claim: claim)),
                  const SizedBox(height: 32),
                  _DocumentVault(),
                  const SizedBox(height: 32),
                  _InsurancePerks(),
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

class _ActivePolicyCard extends StatelessWidget {
  final String petName;
  final String planName;
  final String policyNumber;

  const _ActivePolicyCard({required this.petName, required this.planName, required this.policyNumber});

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
          BoxShadow(color: colorScheme.tertiary.withAlpha(50), blurRadius: 24, offset: const Offset(0, 10))
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.white.withAlpha(40), borderRadius: BorderRadius.circular(20)),
                      child: const Text('ACTIVE POLICY', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
                    ),
                    const SizedBox(height: 16),
                    Text(planName, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                    Text('Protection for $petName', style: TextStyle(color: Colors.white.withAlpha(180), fontSize: 15, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white.withAlpha(40), shape: BoxShape.circle),
                child: const Icon(Icons.verified_user_rounded, color: Colors.white, size: 40),
              ),
            ],
          ),
          const SizedBox(height: 36),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _PolicyInfo(label: 'Deductible', value: r'$250', icon: Icons.remove_circle_outline_rounded),
              _PolicyInfo(label: 'Reimbursement', value: '90%', icon: Icons.add_circle_outline_rounded),
              _PolicyInfo(label: 'Annual Limit', value: r'$15k', icon: Icons.star_outline_rounded),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(color: Colors.white.withAlpha(25), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withAlpha(30))),
            child: Row(
              children: [
                const Icon(Icons.event_repeat_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Next renewal: Dec 12, 2024', style: TextStyle(color: Colors.white.withAlpha(220), fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 12),
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
  const _PolicyInfo({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.white.withAlpha(150), size: 14),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(color: Colors.white.withAlpha(150), fontSize: 11, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w900)),
      ],
    );
  }
}

class _CoverageBreakdown extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Coverage Details', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              _CoverageItem(title: 'Accidents & Injuries', subtitle: r'Covered up to $15,000', icon: Icons.emergency_rounded, color: colorScheme.error),
              _CoverageItem(title: 'Illnesses', subtitle: 'Hereditary, chronic & more', icon: Icons.medication_rounded, color: colorScheme.primary),
              _CoverageItem(title: 'Diagnostics', subtitle: 'X-rays, MRIs & bloodwork', icon: Icons.biotech_rounded, color: colorScheme.secondary),
              _CoverageItem(title: 'Dental Care', subtitle: 'Injury & illness related', icon: Icons.health_and_safety_rounded, color: colorScheme.tertiary, isLast: true),
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

  const _CoverageItem({required this.title, required this.subtitle, required this.icon, required this.color, this.isLast = false});

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
                decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(subtitle, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.check_circle_rounded, color: Theme.of(context).colorScheme.tertiary, size: 20),
            ],
          ),
        ),
        if (!isLast) const Divider(indent: 64, endIndent: 16, height: 1),
      ],
    );
  }
}

class _ClaimCard extends StatelessWidget {
  final Map<String, dynamic> claim;
  const _ClaimCard({required this.claim});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = claim['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: color.withAlpha(30), shape: BoxShape.circle),
            child: Icon(claim['icon'] as IconData, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(claim['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(claim['date'] as String, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
                    const SizedBox(width: 8),
                    Container(width: 4, height: 4, decoration: BoxDecoration(color: colorScheme.outline, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(claim['status'] as String, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          Text(r'$' + (claim['amount'] as double).toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        ],
      ),
    );
  }
}

class _DocumentVault extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Document Vault', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            IconButton.filledTonal(
              onPressed: () {},
              icon: const Icon(Icons.cloud_upload_rounded, size: 20),
              style: IconButton.styleFrom(backgroundColor: colorScheme.secondaryContainer),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHigh.withAlpha(150),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: colorScheme.outlineVariant.withAlpha(150)),
          ),
          child: Column(
            children: [
              _VaultItem(name: 'Insurance_Policy_2024.pdf', size: '1.2 MB', icon: Icons.picture_as_pdf_rounded, status: 'Synced'),
              _VaultItem(name: 'Medical_Invoice_Oct.jpg', size: '450 KB', icon: Icons.image_rounded, status: 'Synced'),
              _VaultItem(name: 'Vaccine_Certificate.pdf', size: '2.1 MB', icon: Icons.picture_as_pdf_rounded, status: 'Local Only', isLast: true),
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

  const _VaultItem({required this.name, required this.size, required this.icon, required this.status, this.isLast = false});

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
                  boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 10)],
                ),
                child: Icon(icon, color: colorScheme.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('$size • $status', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded, size: 20)),
            ],
          ),
        ),
        if (!isLast) Divider(indent: 72, height: 1, color: colorScheme.outlineVariant.withAlpha(100)),
      ],
    );
  }
}

class _InsurancePerks extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(
          image: const NetworkImage('https://images.unsplash.com/photo-1548199973-03cce0bbc87b?auto=format&fit=crop&q=80&w=400'),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(colorScheme.primaryContainer.withAlpha(200), BlendMode.srcOver),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.stars_rounded, color: colorScheme.secondary, size: 48),
          const SizedBox(height: 16),
          const Text('Multi-Pet Advantage', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22)),
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
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FileClaimSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(color: colorScheme.surface, borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 40, height: 4, decoration: BoxDecoration(color: colorScheme.outlineVariant, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 24),
          Text('File New Claim', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          TextField(decoration: InputDecoration(labelText: 'Claim Subject', hintText: 'e.g., Emergency Surgery', border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)))),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: TextField(decoration: InputDecoration(labelText: 'Amount (\$)', border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))))),
              const SizedBox(width: 16),
              Expanded(child: TextField(decoration: InputDecoration(labelText: 'Date', border: OutlineInputBorder(borderRadius: BorderRadius.circular(20))))),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                Icon(Icons.cloud_upload_rounded, size: 32, color: colorScheme.primary),
                const SizedBox(height: 12),
                const Text('Upload Medical Invoices', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('PDF, JPG or PNG (Max 10MB)', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 18), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
              child: const Text('Submit Claim Verification'),
            ),
          ),
        ],
      ),
    );
  }
}
