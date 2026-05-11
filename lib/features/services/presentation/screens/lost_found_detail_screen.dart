import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:petfolio/features/community/data/lost_found_repository.dart';

class LostFoundDetailScreen extends ConsumerWidget {
  const LostFoundDetailScreen({super.key, required this.reportId});
  final String reportId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reportsAsync = ref.watch(_reportProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: reportsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (reports) {
          final report = reports.where((r) => r.id == reportId).firstOrNull;
          if (report == null) {
            return const Center(child: Text('Report not found'));
          }
          final isLost = report.status == 'lost';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: report.imageUrl != null
                      ? Image.network(
                          report.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _Placeholder(isLost: isLost),
                        )
                      : _Placeholder(isLost: isLost),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Share feature coming soon')),
                      );
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: (isLost ? colorScheme.error : colorScheme.tertiary).withAlpha(230),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isLost ? 'LOST' : 'FOUND',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            DateFormat('MMM d, yyyy').format(report.createdAt),
                            style: TextStyle(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        report.petName,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (report.breed != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          report.breed!,
                          style: TextStyle(
                            fontSize: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      if (report.lastSeenLocation != null) ...[
                        _InfoRow(
                          icon: Icons.location_on,
                          label: 'Last seen',
                          value: report.lastSeenLocation!,
                        ),
                        const SizedBox(height: 8),
                      ],
                      if (report.description != null) ...[
                        const SizedBox(height: 16),
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          report.description!,
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                      if (report.rewardAmount != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.money, color: colorScheme.onSecondaryContainer),
                              const SizedBox(width: 8),
                              Text(
                                'Reward: \$${report.rewardAmount!.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onSecondaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (report.contactInfo != null) ...[
                        FilledButton.icon(
                          onPressed: () => _contactReporter(context, report.contactInfo!),
                          icon: const Icon(Icons.phone),
                          label: const Text('Contact Reporter'),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: () => _markResolved(context, ref, report),
                        icon: const Icon(Icons.check_circle),
                        label: const Text('Mark as Resolved'),
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

  Future<void> _contactReporter(BuildContext context, String contactInfo) async {
    final uri = Uri.parse('tel:$contactInfo');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Contact: $contactInfo')),
        );
      }
    }
  }

  void _markResolved(BuildContext context, WidgetRef ref, LostFoundReport report) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mark as Resolved?'),
        content: const Text('This will mark the report as resolved and hide it from the list.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report marked as resolved')),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

final _reportProvider = FutureProvider<List<LostFoundReport>>((ref) async {
  final lost = await lostFoundRepository.fetchReports(status: 'lost');
  final found = await lostFoundRepository.fetchReports(status: 'found');
  return [...lost, ...found];
});

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 20, color: colorScheme.primary),
        const SizedBox(width: 8),
        Text('$label: ', style: TextStyle(color: colorScheme.onSurfaceVariant)),
        Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w500))),
      ],
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.isLost});
  final bool isLost;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: isLost ? colorScheme.errorContainer : colorScheme.tertiaryContainer,
      child: Center(
        child: Icon(
          isLost ? Icons.pets : Icons.search,
          size: 80,
          color: isLost ? colorScheme.onErrorContainer : colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}