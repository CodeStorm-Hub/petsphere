import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petfolio/features/services/presentation/controllers/pet_sitter_controller.dart';
import 'package:petfolio/features/services/data/sitter_repository.dart';
import 'package:petfolio/core/widgets/async_value_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PetSitterDashboardScreen extends ConsumerWidget {
  const PetSitterDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Pet Sitting',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            labelStyle: GoogleFonts.dmSans(fontWeight: FontWeight.bold),
            unselectedLabelStyle: GoogleFonts.dmSans(),
            tabs: const [
              Tab(text: 'My Requests'),
              Tab(text: 'Marketplace'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _MyRequestsTab(),
            _MarketplaceTab(),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // TODO: Navigate to Post Job Screen
          },
          label: const Text('Post a Job'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }
}

class _MyRequestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(mySitterJobsProvider);

    return AsyncValueWidget<List<SitterJob>>(
      value: jobsAsync,
      data: (List<SitterJob> jobs) {
        if (jobs.isEmpty) {
          return const _EmptyState(
            icon: Icons.assignment_outlined,
            title: 'No requests yet',
            message: 'Post a job to find the perfect sitter for your pet.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          itemBuilder: (context, index) => _JobCard(job: jobs[index]),
        );
      },
    );
  }
}

class _MarketplaceTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(openSitterJobsProvider);

    return AsyncValueWidget<List<SitterJob>>(
      value: jobsAsync,
      data: (List<SitterJob> jobs) {
        if (jobs.isEmpty) {
          return const _EmptyState(
            icon: Icons.search_off,
            title: 'No open jobs',
            message: 'There are no sitter requests in your area right now.',
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: jobs.length,
          itemBuilder: (context, index) => _JobCard(job: jobs[index], isMarketplace: true),
        );
      },
    );
  }
}

class _JobCard extends StatelessWidget {
  final SitterJob job;
  final bool isMarketplace;

  const _JobCard({required this.job, this.isMarketplace = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('MMM d');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: InkWell(
        onTap: () {
          // TODO: Navigate to job detail
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _getStatusColor(job.status, theme),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      job.status.toUpperCase(),
                      style: GoogleFonts.dmSans(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    '\$${job.ratePerDay?.toStringAsFixed(0) ?? "???"}/day',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    '${dateFormat.format(job.startDate)} - ${dateFormat.format(job.endDate)}',
                    style: GoogleFonts.dmSans(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (job.description != null)
                Text(
                  job.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSans(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                    child: Icon(Icons.pets, size: 12, color: theme.colorScheme.primary),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isMarketplace ? 'Pet Owner' : 'Your Request',
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(isMarketplace ? 'Apply' : 'Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'open':
        return Colors.green;
      case 'assigned':
        return theme.colorScheme.primary;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              title,
              style: GoogleFonts.playfairDisplay(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
