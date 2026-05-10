import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/care_gamification_controller.dart';
import '../controllers/care_log_controller.dart';

import 'package:petfolio/features/care/data/models/care_badge_model.dart';

class GamificationScreen extends ConsumerWidget {
  const GamificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final gamificationState = ref.watch(careGamificationProvider);
    final logState = ref.watch(careLogProvider);
    final stats = gamificationState.gamification;

    if (stats == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Achievements')),
        body: const Center(
          child: Text('No gamification stats yet. Start logging care tasks!'),
        ),
      );
    }

    final level = (stats.totalCarePoints / 100).floor() + 1;
    final pointsInLevel = stats.totalCarePoints % 100;
    final progressToNext = pointsInLevel / 100.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Care Journey')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Level Card
          _LevelCard(
            level: level,
            totalPoints: stats.totalCarePoints,
            progress: progressToNext,
          ),
          const SizedBox(height: 24),
          // Streak & Stats Row
          Row(
            children: [
              Expanded(
                child: _StatBox(
                  label: 'Current Streak',
                  value: '${logState.streakDays} Days',
                  icon: Icons.local_fire_department,
                  color: colorScheme.secondary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatBox(
                  label: 'Best Streak',
                  value: '${stats.bestStreakDays} Days',
                  icon: Icons.emoji_events,
                  color: colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 30-Day Path
          _PathProgress(progress: stats.challenge30dProgress),
          const SizedBox(height: 32),
          // Badges Section
          Text('Your Badges', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          _BadgesGrid(unlocks: gamificationState.unlocks),
        ],
      ),
    );
  }
}

class _LevelCard extends StatelessWidget {
  final int level;
  final int totalPoints;
  final double progress;

  const _LevelCard({
    required this.level,
    required this.totalPoints,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(80),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.onPrimary.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$level',
                  style: TextStyle(
                    color: colorScheme.onPrimary,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level $level Caretaker',
                      style: TextStyle(
                        color: colorScheme.onPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$totalPoints Total Points',
                      style: TextStyle(
                        color: colorScheme.onPrimary.withAlpha(200),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.onPrimary.withAlpha(40),
            valueColor: AlwaysStoppedAnimation(colorScheme.onPrimary),
            minHeight: 12,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(progress * 100).toInt()}% to Level ${level + 1}',
              style: TextStyle(
                color: colorScheme.onPrimary.withAlpha(200),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PathProgress extends StatelessWidget {
  final int progress;
  const _PathProgress({required this.progress});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(100),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.flag_rounded, size: 20),
              const SizedBox(width: 8),
              const Text(
                '30-Day Care Challenge',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              Text(
                '$progress / 30',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: List.generate(30, (i) {
              final done = i < progress;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: i < 29 ? 2 : 0),
                  decoration: BoxDecoration(
                    color: done
                        ? colorScheme.primary
                        : colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            'Keep logging daily to complete the path and earn the Master Caretaker badge!',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _BadgesGrid extends ConsumerWidget {
  final List<PetCareBadgeUnlock> unlocks;
  const _BadgesGrid({required this.unlocks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defsAsync = ref.watch(careBadgeDefinitionsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return defsAsync.when(
      data: (defs) {
        final unlockedSlugs = unlocks.map((u) => u.badgeSlug).toSet();
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 0.8,
          ),
          itemCount: defs.length,
          itemBuilder: (context, index) {
            final def = defs[index];
            final isUnlocked = unlockedSlugs.contains(def.slug);
            return Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? colorScheme.primaryContainer
                        : colorScheme.surfaceContainer,
                    shape: BoxShape.circle,
                    border: isUnlocked
                        ? null
                        : Border.all(color: colorScheme.outlineVariant),
                  ),
                  child: Opacity(
                    opacity: isUnlocked ? 1.0 : 0.3,
                    child: Text(
                      def.iconEmoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  def.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: isUnlocked
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isUnlocked
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const Text('Failed to load badge definitions'),
    );
  }
}
