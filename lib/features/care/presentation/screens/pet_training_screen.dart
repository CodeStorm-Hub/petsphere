import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:petsphere/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petsphere/features/care/presentation/controllers/pet_training_controller.dart';
import 'package:petsphere/core/widgets/brand_logo.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:petsphere/core/widgets/skeleton_loader.dart';

class PetTrainingScreen extends ConsumerWidget {
  const PetTrainingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activePet = ref.watch(activePetProvider);
    final trainingAsync = ref.watch(petTrainingProgressProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    if (activePet == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Training',
            style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const BrandLogo(customSize: 64),
                const SizedBox(height: 24),
                Text(
                  'No Active Pet',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Select a pet from the home screen to start their training journey.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 32),
                FilledButton.icon(
                  onPressed: () => context.go('/home'),
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Go to Home'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: trainingAsync.when(
        data: (progressList) {
          final masteredCount = progressList.where((p) => p.mastered).length;
          final level = (masteredCount / 5).floor() + 1;
          final levelProgress = (masteredCount % 5) / 5.0;

          return CustomScrollView(
            slivers: [
              SliverAppBar.large(
                title: Text(
                  'Training',
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.stars_rounded),
                    tooltip: 'Training Medals',
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _TrainingHeroCard(
                          petName: activePet.name,
                          level: level,
                          progress: levelProgress,
                          masteredCount: masteredCount,
                        )
                        .animate()
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.1, curve: Curves.easeOutQuad),
                    const SizedBox(height: 32),
                    Text(
                      'Skill Categories',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn(duration: 500.ms, delay: 100.ms),
                    const SizedBox(height: 16),
                    GridView.count(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 1.3,
                          children: [
                            _SkillCard(
                              label: 'Obedience',
                              icon: Icons.gavel_rounded,
                              color: colorScheme.primary,
                              skillsCount: 12,
                              completed: progressList
                                  .where(
                                    (p) =>
                                        [
                                          'Sit',
                                          'Stay',
                                          'Come',
                                          'Heel',
                                          'Down',
                                          'Leave it',
                                        ].contains(p.command) &&
                                        p.mastered,
                                  )
                                  .length,
                            ),
                            _SkillCard(
                              label: 'Agility',
                              icon: Icons.run_circle_outlined,
                              color: colorScheme.tertiary,
                              skillsCount: 8,
                              completed: progressList
                                  .where(
                                    (p) =>
                                        [
                                          'Jump',
                                          'Tunnel',
                                          'Weave',
                                          'A-Frame',
                                        ].contains(p.command) &&
                                        p.mastered,
                                  )
                                  .length,
                            ),
                            _SkillCard(
                              label: 'Social',
                              icon: Icons.diversity_3_rounded,
                              color: colorScheme.secondary,
                              skillsCount: 10,
                              completed: progressList
                                  .where(
                                    (p) =>
                                        [
                                          'Wait at Door',
                                          'Greeting',
                                          'No Barking',
                                        ].contains(p.command) &&
                                        p.mastered,
                                  )
                                  .length,
                            ),
                            _SkillCard(
                              label: 'Tricks',
                              icon: Icons.auto_awesome_rounded,
                              color: colorScheme.primaryContainer,
                              skillsCount: 15,
                              completed: progressList
                                  .where(
                                    (p) =>
                                        [
                                          'Shake',
                                          'Roll Over',
                                          'Play Dead',
                                          'Spin',
                                          'High Five',
                                        ].contains(p.command) &&
                                        p.mastered,
                                  )
                                  .length,
                            ),
                          ],
                        )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 200.ms)
                        .slideY(begin: 0.05),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Daily Exercises',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontFamily:
                                GoogleFonts.playfairDisplay().fontFamily,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All'),
                        ),
                      ],
                    ).animate().fadeIn(duration: 500.ms, delay: 300.ms),
                    const SizedBox(height: 12),
                    _ExerciseItem(
                          title: 'Perfect Recall',
                          subtitle: '5 minutes • Basic',
                          icon: Icons.settings_voice_rounded,
                          isMastered: progressList.any(
                            (p) => p.command == 'Come' && p.mastered,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 400.ms)
                        .slideX(begin: 0.05),
                    _ExerciseItem(
                          title: 'Stay with Distractions',
                          subtitle: '3 minutes • Advanced',
                          icon: Icons.pause_circle_filled_rounded,
                          isMastered: progressList.any(
                            (p) => p.command == 'Stay' && p.mastered,
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 400.ms, delay: 500.ms)
                        .slideX(begin: 0.05),
                    const SizedBox(height: 32),
                    const _TrainerPromotionCard()
                        .animate()
                        .fadeIn(duration: 600.ms, delay: 600.ms)
                        .scale(begin: const Offset(0.9, 0.9)),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => const TrainingSkeletonLoader(),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet<void>(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (_) => _LogSessionSheet(
              petId: activePet.id,
              onLogged: () => ref.invalidate(petTrainingProgressProvider),
            ),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Session'),
      ),
    );
  }
}

class _TrainingHeroCard extends StatelessWidget {
  const _TrainingHeroCard({
    required this.petName,
    required this.level,
    required this.progress,
    required this.masteredCount,
  });

  final String petName;
  final int level;
  final double progress;
  final int masteredCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary,
            colorScheme.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'LEVEL $level',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 10,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$petName\'s Journey',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            masteredCount == 0
                ? 'Start your training journey! Master 5 skills to reach Level 2.'
                : 'You\'ve mastered $masteredCount skills! Keep going to reach the next level.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Stack(
            children: [
              Container(
                height: 10,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(
                  0.05,
                  1.0,
                ), // Minimum width for visibility
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.5),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SkillCard extends StatelessWidget {
  const _SkillCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.skillsCount,
    required this.completed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final int skillsCount;
  final int completed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (completed / skillsCount).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const Spacer(),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: colorScheme.outlineVariant.withValues(
                      alpha: 0.3,
                    ),
                    color: color,
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$completed/$skillsCount',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExerciseItem extends StatelessWidget {
  const _ExerciseItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isMastered,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final bool isMastered;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMastered
            ? colorScheme.primaryContainer.withValues(alpha: 0.2)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isMastered
              ? colorScheme.primary.withValues(alpha: 0.3)
              : colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: isMastered ? TextDecoration.lineThrough : null,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          if (isMastered)
            const Icon(Icons.check_circle_rounded, color: Colors.green)
          else
            Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
        ],
      ),
    );
  }
}

class _TrainerPromotionCard extends StatelessWidget {
  const _TrainerPromotionCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: colorScheme.secondary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expert Guidance',
                  style: GoogleFonts.playfairDisplay(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Connect with top-rated trainers for personalized sessions.',
                  style: TextStyle(
                    color: colorScheme.onSecondaryContainer.withValues(
                      alpha: 0.8,
                    ),
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.tonal(
                  onPressed: () {},
                  child: const Text('Find Trainers'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Icon(
            Icons.school_rounded,
            size: 80,
            color: colorScheme.secondary.withValues(alpha: 0.15),
          ),
        ],
      ),
    );
  }
}

class _LogSessionSheet extends ConsumerStatefulWidget {
  final String petId;
  final VoidCallback onLogged;

  const _LogSessionSheet({required this.petId, required this.onLogged});

  @override
  ConsumerState<_LogSessionSheet> createState() => _LogSessionSheetState();
}

class _LogSessionSheetState extends ConsumerState<_LogSessionSheet> {
  final _commandCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _mastered = false;

  @override
  void dispose() {
    _commandCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_commandCtrl.text.trim().isEmpty) return;

    await ref
        .read(petTrainingControllerProvider.notifier)
        .logSession(
          petId: widget.petId,
          command: _commandCtrl.text.trim(),
          mastered: _mastered,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );

    if (mounted) {
      final state = ref.read(petTrainingControllerProvider);
      if (state.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
      } else {
        widget.onLogged();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(petTrainingControllerProvider).isLoading;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Log Training Session',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _commandCtrl,
            decoration: InputDecoration(
              labelText: 'Command / Skill (e.g. Sit, Stay)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _notesCtrl,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Notes (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Mastered?'),
            subtitle: const Text(
              'Check if pet consistently performs this command',
            ),
            value: _mastered,
            onChanged: (val) => setState(() => _mastered = val),
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: saving ? null : _submit,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: saving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Save Session'),
            ),
          ),
        ],
      ),
    );
  }
}

