import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/auth_controller.dart';
import '../controllers/health_controller.dart';
import '../controllers/pet_care_controller.dart';
import '../controllers/pet_controller.dart';
import '../models/care_badge_model.dart';
import '../models/pet_care_log_model.dart';
import '../utils/care_gamification_logic.dart';
import '../utils/care_personalization.dart';
import 'care_goal_editor_modal.dart';
import 'health_tab.dart';

class _SetupBanner extends StatelessWidget {
  const _SetupBanner({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.primary.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.tune, color: colorScheme.primary, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Finish care setup for species-specific tips, diet hints, and gentler nudges.',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, color: colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _PointsRow extends StatelessWidget {
  const _PointsRow({
    required this.points,
    required this.challenge,
    this.todayLog,
  });

  final int points;
  final int challenge;
  final PetCareLog? todayLog;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final todayWant = wantedDailyCarePoints(todayLog);
    final n = todayLog?.tasks.length ?? 0;
    final done = todayLog?.completedTasks ?? 0;
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _MiniStat(
              label: 'Care points (lifetime)',
              value: '$points',
              icon: Icons.stars,
            ),
            _MiniStat(
              label: '30-day path',
              value: '$challenge / 30',
              icon: Icons.flag_outlined,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          n == 0
              ? 'Up to 10 care points on a full day; partial days earn 2 per task you check.'
              : 'Today’s progress toward max 10: $done / $n tasks, target today +$todayWant (no penalty if you uncheck; totals never go down).',
          style: Theme.of(context)
              .textTheme
              .labelSmall
              ?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.35),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: colorScheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    label,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AchievementsBlock extends ConsumerWidget {
  const _AchievementsBlock({required this.activePetId});
  final String activePetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final defAsync = ref.watch(careBadgeDefinitionsProvider);
    final care = ref.watch(petCareProvider);
    final unlocks = care.unlocks.where((u) => u.petId == activePetId).toList();
    return defAsync.when(
      data: (defs) {
        if (unlocks.isEmpty) {
          return Text(
            'Log daily care to earn badges for streaks, weeks, and milestones.',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: colorScheme.onSurfaceVariant, height: 1.4),
          );
        }
        final bySlug = {for (final d in defs) d.slug: d};
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Achievements',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => context.push('/achievements'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final u in unlocks)
                  if (bySlug.containsKey(u.badgeSlug))
                    Chip(
                      avatar: Text(bySlug[u.badgeSlug]!.iconEmoji),
                      label: Text(
                        bySlug[u.badgeSlug]!.title,
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
              ],
            ),
            TextButton(
              onPressed: () => _openShowcaseEditor(context, ref, defs, unlocks),
              child: const Text('Choose badges to show on your public profile'),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

Future<void> _openShowcaseEditor(
  BuildContext context,
  WidgetRef ref,
  List<CareBadgeDefinition> allDefs,
  List<PetCareBadgeUnlock> unlocks,
) async {
  final user = ref.read(authProvider).user;
  if (user == null) return;
  final selected = List<String>.from(user.publicCareBadgeSlugs);
  if (!context.mounted) return;
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (context, setModal) {
    final colorScheme = Theme.of(context).colorScheme;
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 16,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Show on profile (max 3)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Only what you select is visible to others. Full unlock list stays private unless showcased.',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                for (final u in unlocks)
                  Builder(
                    builder: (context) {
                      CareBadgeDefinition? d;
                      for (final def in allDefs) {
                        if (def.slug == u.badgeSlug) {
                          d = def;
                          break;
                        }
                      }
                      if (d == null) {
                        return const SizedBox.shrink();
                      }
                      final def = d;
                      final on = selected.contains(def.slug);
                      return CheckboxListTile(
                        value: on,
                        title: Text('${def.iconEmoji} ${def.title}'),
                        onChanged: (v) {
                          setModal(() {
                            if (v == true) {
                              if (selected.length < 3) selected.add(def.slug);
                            } else {
                              selected.remove(def.slug);
                            }
                          });
                        },
                      );
                    },
                  ),
                FilledButton(
                  onPressed: () async {
                    final ok =
                        await ref.read(authProvider.notifier).updateProfile(
                      {
                        'public_care_badge_slugs': selected,
                        'show_care_badges_on_profile': selected.isNotEmpty,
                      },
                    );
                    if (ok && ctx.mounted) Navigator.pop(ctx);
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

class PetCareScreen extends ConsumerStatefulWidget {
  const PetCareScreen({super.key});

  @override
  ConsumerState<PetCareScreen> createState() => _PetCareScreenState();
}

class _PetCareScreenState extends ConsumerState<PetCareScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController =
      TabController(length: 3, vsync: this);

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final myPets = ref.watch(petProvider).myPets;
    final activePet = ref.watch(activePetProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Care'),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
            (myPets.length > 1 ? 80.0 : 0.0) + kTextTabBarHeight,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Per-pet selector row (shown when user has multiple pets)
              if (myPets.length > 1)
                SizedBox(
                  height: 80,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    itemCount: myPets.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final pet = myPets[i];
                      final isSelected = pet.id == activePet?.id;
                      return GestureDetector(
                        onTap: () =>
                            ref.read(petProvider.notifier).setActivePet(pet),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary.withAlpha(28)
                                : colorScheme.surfaceContainerHighest,
                            border: Border.all(
                              color: isSelected
                                  ? colorScheme.primary
                                  : colorScheme.outline.withAlpha(70),
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor:
                                    colorScheme.surfaceContainerHighest,
                                backgroundImage:
                                    pet.profileImageUrl.isNotEmpty
                                        ? NetworkImage(pet.profileImageUrl)
                                        : null,
                                child: pet.profileImageUrl.isEmpty
                                    ? Icon(Icons.pets,
                                        size: 16,
                                        color: isSelected
                                            ? colorScheme.primary
                                            : colorScheme.onSurfaceVariant)
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                pet.name,
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  fontSize: 13,
                                  color: isSelected
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              TabBar(
                controller: _tabController,
                labelColor: colorScheme.primary,
                unselectedLabelColor: colorScheme.onSurfaceVariant,
                indicatorColor: colorScheme.primary,
                tabs: const [
                  Tab(text: 'Care Diary'),
                  Tab(text: 'Health'),
                  Tab(text: 'Feeding'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(petCareProvider.notifier).refresh();
          await ref.read(healthProvider.notifier).refresh();
        },
        child: TabBarView(
          controller: _tabController,
          children: const [
            _DashboardTab(),
            HealthTab(),
            _FeedingTab(),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared empty-state for "no active pet"
// ─────────────────────────────────────────────────────────────────────────────
class _NoActivePet extends StatelessWidget {
  const _NoActivePet();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.pets, size: 56, color: colorScheme.onSurfaceVariant),
        const SizedBox(height: 16),
        Text(
          'Add a pet to start tracking care',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Once you create a pet profile, daily logs, weight history, and vet appointments will live here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. DASHBOARD (CARE DIARY)
// ─────────────────────────────────────────────────────────────────────────────
class _DashboardTab extends ConsumerWidget {
  const _DashboardTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final activePet = ref.watch(activePetProvider);
    final careState = ref.watch(petCareProvider);
    final todayLog = careState.todayLog;

    if (activePet == null) return const _NoActivePet();
    if (todayLog == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final completedTasks = todayLog.completedTasks;
    final totalTasks = todayLog.tasks.length;

    final o = careState.onboarding;
    final oData = o?.data ?? const <String, dynamic>{};
    final needsSetup = o == null || !o.isComplete;
    final nudge = careChecklistNudge(
      oData,
      completed: completedTasks,
      total: totalTasks,
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (needsSetup) ...[
          _SetupBanner(
            onTap: () async {
              await context.push(
                '/pet_care_onboarding?petId=${activePet.id}',
              );
              await ref.read(petCareProvider.notifier).refresh();
            },
          ),
          const SizedBox(height: 16),
        ],
        if (careState.gamification != null) ...[
          _PointsRow(
            points: careState.gamification!.totalCarePoints,
            challenge: careState.gamification!.challenge30dProgress,
            todayLog: todayLog,
          ),
          const SizedBox(height: 8),
          _WeekMaskRow(
            weekStartMonday: careState.gamification!.weekStartMonday,
            mask: careState.gamification!.weekCompletedMask,
          ),
          const SizedBox(height: 12),
        ],

        // ────────── PREMIUM BENTO GRID ──────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Today's Overview", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () => CareGoalEditorModal.show(context, todayLog, oData),
                    icon: const Icon(Icons.edit_calendar, size: 16),
                    label: const Text('Edit Goals'),
                    style: TextButton.styleFrom(
                      foregroundColor: colorScheme.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ProgressRing(
                    label: 'Tasks',
                    progress: totalTasks == 0 ? 0 : completedTasks / totalTasks,
                    color: colorScheme.primary,
                    centerText: '$completedTasks/$totalTasks',
                  ),
                  _ProgressRing(
                    label: 'Calories',
                    progress: todayLog.caloriesProgress,
                    color: Colors.orange,
                    centerText: '${todayLog.consumedKcal}\nkcal',
                  ),
                  _ProgressRing(
                    label: 'Water',
                    progress: todayLog.waterProgress,
                    color: Colors.blue,
                    centerText:
                        '${todayLog.waterCups}/${todayLog.dailyWaterGoalCups}\ncups',
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        _StreakBanner(
          streakDays: careState.streakDays,
          flags: careState.streakFlags,
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Daily Checklist', style: theme.textTheme.titleLarge),
            Text(
              '${(totalTasks == 0 ? 0 : completedTasks / totalTasks * 100).toInt()}%',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          nudge,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: totalTasks == 0 ? 0 : completedTasks / totalTasks,
          backgroundColor: colorScheme.outlineVariant,
          color: colorScheme.primary,
          borderRadius: BorderRadius.circular(999),
        ),
        const SizedBox(height: 16),

        for (final task in todayLog.tasks)
          _TaskCard(
            task: task,
            onToggle: () =>
                ref.read(petCareProvider.notifier).toggleTask(task.key),
          ),

        const SizedBox(height: 20),
        _AchievementsBlock(activePetId: activePet.id),
        const SizedBox(height: 24),
        Text('How is your pet feeling?', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _MoodButton(
              emoji: '😴',
              label: 'Sleepy',
              selected: todayLog.mood == 'Sleepy',
            ),
            _MoodButton(
              emoji: '😊',
              label: 'Happy',
              selected: todayLog.mood == 'Happy',
            ),
            _MoodButton(
              emoji: '🤪',
              label: 'Playful',
              selected: todayLog.mood == 'Playful',
            ),
            _MoodButton(
              emoji: '🤒',
              label: 'Sick',
              selected: todayLog.mood == 'Sick',
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text('Care Resources', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 4,
          mainAxisSpacing: 16,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
          children: [
            _QuickActionItem(
              label: 'Vet Booking',
              icon: Icons.calendar_month,
              color: Colors.blue,
              onTap: () => context.push('/vet_booking'),
            ),
            _QuickActionItem(
              label: 'Emergency',
              icon: Icons.emergency,
              color: Colors.red,
              onTap: () => context.push('/emergency_care'),
            ),
            _QuickActionItem(
              label: 'Nutrition',
              icon: Icons.restaurant,
              color: Colors.orange,
              onTap: () => context.push('/nutrition_planner'),
            ),
            _QuickActionItem(
              label: 'Expenses',
              icon: Icons.payments,
              color: Colors.green,
              onTap: () => context.push('/expenses'),
            ),
            _QuickActionItem(
              label: 'Growth',
              icon: Icons.show_chart,
              color: Colors.purple,
              onTap: () => context.push('/growth_charts'),
            ),
            _QuickActionItem(
              label: 'Insurance',
              icon: Icons.security,
              color: Colors.cyan,
              onTap: () => context.push('/insurance'),
            ),
            _QuickActionItem(
              label: 'Training',
              icon: Icons.school,
              color: Colors.brown,
              onTap: () => context.push('/training'),
            ),
            _QuickActionItem(
              label: 'Adoption',
              icon: Icons.favorite,
              color: Colors.pink,
              onTap: () => context.push('/adoption_center'),
            ),
            _QuickActionItem(
              label: 'Places',
              icon: Icons.map,
              color: Colors.teal,
              onTap: () => context.push('/pet_friendly_places'),
            ),
            _QuickActionItem(
              label: 'Events',
              icon: Icons.event,
              color: Colors.indigo,
              onTap: () => context.push('/events'),
            ),
            _QuickActionItem(
              label: 'Medical',
              icon: Icons.folder_shared_rounded,
              color: Colors.blueGrey,
              onTap: () => context.push('/medical_records'),
            ),
            _QuickActionItem(
              label: 'Sitters',
              icon: Icons.person_search,
              color: Colors.amber,
              onTap: () => context.push('/sitters'),
            ),
            _QuickActionItem(
              label: 'Timeline',
              icon: Icons.history,
              color: Colors.deepPurple,
              onTap: () => context.push('/pet_timeline'),
            ),
            _QuickActionItem(
              label: 'Identifier',
              icon: Icons.camera_alt,
              color: Colors.blue,
              onTap: () => context.push('/breed_identifier'),
            ),
            _QuickActionItem(
              label: 'Knowledge',
              icon: Icons.menu_book,
              color: Colors.lightGreen,
              onTap: () => context.push('/knowledge_base'),
            ),
            _QuickActionItem(
              label: 'Reviews',
              icon: Icons.rate_review,
              color: Colors.orangeAccent,
              onTap: () => context.push('/gear_reviews'),
            ),
            _QuickActionItem(
              label: 'Groups',
              icon: Icons.groups,
              color: Colors.deepOrange,
              onTap: () => context.push('/community_groups'),
            ),
            _QuickActionItem(
              label: 'Lost/Found',
              icon: Icons.location_searching,
              color: Colors.redAccent,
              onTap: () => context.push('/lost_and_found'),
            ),
            _QuickActionItem(
              label: 'Memorial',
              icon: Icons.cloud,
              color: Colors.blueAccent,
              onTap: () => context.push('/memorial'),
            ),
          ],
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

// ───────────── Week mask (Mon–Sun, this ISO week) ─────────────
class _WeekMaskRow extends StatelessWidget {
  const _WeekMaskRow({
    required this.weekStartMonday,
    required this.mask,
  });

  final DateTime? weekStartMonday;
  final int mask;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final start = weekStartMonday ?? _mondayOf(DateTime.now());
    const labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This week (care day complete)',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < 7; i++)
                _WeekDayCell(
                  label: labels[i],
                  done: (mask & (1 << i)) != 0,
                  isToday: _isSameDate(
                    start.add(Duration(days: i)),
                    DateTime.now(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

DateTime _mondayOf(DateTime d) {
  final x = DateTime(d.year, d.month, d.day);
  return x.subtract(Duration(days: x.weekday - 1));
}

bool _isSameDate(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

class _WeekDayCell extends StatelessWidget {
  const _WeekDayCell({
    required this.label,
    required this.done,
    required this.isToday,
  });

  final String label;
  final bool done;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: isToday ? colorScheme.primary : colorScheme.onSurfaceVariant,
            fontWeight: isToday ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: done
                ? colorScheme.primary.withValues(alpha: 0.2)
                : colorScheme.surface,
            border: Border.all(
              color: done ? colorScheme.primary : colorScheme.outlineVariant,
            ),
          ),
          alignment: Alignment.center,
          child: done
              ? Icon(Icons.check, size: 16, color: colorScheme.primary)
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

// ───────────── Streak banner ─────────────
class _StreakBanner extends StatelessWidget {
  const _StreakBanner({required this.streakDays, required this.flags});

  final int streakDays;
  final List<bool> flags;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department,
                color: Colors.orange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                streakDays > 0
                    ? '$streakDays-Day Streak!'
                    : 'Start today\u2019s streak',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < flags.length; i++)
                _StreakDot(label: 'D${i + 1}', complete: flags[i]),
            ],
          ),
        ],
      ),
    );
  }
}

class _StreakDot extends StatelessWidget {
  const _StreakDot({required this.label, required this.complete});

  final String label;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: complete
            ? colorScheme.primary.withValues(alpha: 0.2)
            : colorScheme.surface,
        border: Border.all(
          color: complete ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      alignment: Alignment.center,
      child: complete
          ? Icon(Icons.check, size: 16, color: colorScheme.primary)
          : Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
    );
  }
}

// ───────────── Progress ring ─────────────
class _ProgressRing extends StatelessWidget {
  const _ProgressRing({
    required this.label,
    required this.progress,
    required this.color,
    required this.centerText,
  });

  final String label;
  final double progress;
  final Color color;
  final String centerText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: Stack(
            fit: StackFit.expand,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutCubic,
                builder: (_, value, __) => CircularProgressIndicator(
                  value: value,
                  strokeWidth: 8,
                  backgroundColor: colorScheme.outlineVariant,
                  color: color,
                ),
              ),
              Center(
                child: Text(
                  centerText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            )),
      ],
    );
  }
}

// ───────────── Task card ─────────────
class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.onToggle});

  final DailyTask task;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDone = task.done;
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone
              ? colorScheme.secondary.withValues(alpha: 0.1)
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone ? colorScheme.secondary : colorScheme.outlineVariant,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDone ? colorScheme.secondary : colorScheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDone ? colorScheme.secondary : colorScheme.outlineVariant,
                ),
              ),
              child: Icon(
                task.icon,
                color: isDone ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    task.subtitle,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? colorScheme.secondary : colorScheme.outlineVariant,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

// ───────────── Mood button ─────────────
class _MoodButton extends ConsumerWidget {
  const _MoodButton({
    required this.emoji,
    required this.label,
    required this.selected,
  });

  final String emoji;
  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () =>
          ref.read(petCareProvider.notifier).setMood(selected ? null : label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? colorScheme.primary.withValues(alpha: 0.2)
              : colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? colorScheme.primary : colorScheme.outlineVariant,
          ),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color:
                    selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. HEALTH TAB — extracted to lib/views/health_tab.dart
// ─────────────────────────────────────────────────────────────────────────────
// (HealthTab is imported above and used directly in TabBarView)

// ─────────────────────────────────────────────────────────────────────────────
// 3. FEEDING TAB
// ─────────────────────────────────────────────────────────────────────────────
class _FeedingTab extends ConsumerWidget {
  const _FeedingTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final activePet = ref.watch(activePetProvider);
    final todayLog = ref.watch(todayCareLogProvider);
    final oData = ref.watch(petCareProvider).onboarding?.data;
    final dietHint = careFeedingHint(oData ?? const {});

    if (activePet == null) return const _NoActivePet();
    if (todayLog == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final notifier = ref.read(petCareProvider.notifier);
    final isSnackEnabled =
        (oData?[PetCareOnboarding.kAgeBand] as String? ?? 'adult') ==
            'puppy_kitten';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Personalized diet recommendation banner
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.lightbulb_outline,
                  color: colorScheme.primary, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  dietHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: TextButton.icon(
            onPressed: () => CareGoalEditorModal.show(context, todayLog, oData ?? const {}),
            icon: const Icon(Icons.tune, size: 18),
            label: const Text('Adjust Nutrition Goals'),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Calorie progress ring with meal vs treat breakdown
        Center(
          child: SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Outer ring — total calories
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: todayLog.caloriesProgress),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 12,
                    backgroundColor: colorScheme.outlineVariant,
                    color: todayLog.treatsOverBudget
                        ? colorScheme.error
                        : Colors.orange,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${todayLog.consumedKcal}',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '/ ${todayLog.dailyCalorieGoal} kcal',
                        style: TextStyle(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (todayLog.treatsKcal > 0)
                        Text(
                          '🍪 ${todayLog.treatsKcal} kcal treats',
                          style: TextStyle(
                            fontSize: 11,
                            color: todayLog.treatsOverBudget
                                ? colorScheme.error
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Calorie breakdown chips
        if (todayLog.consumedKcal > 0)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CalorieChip(
                label: 'Meals',
                value: '${todayLog.mealKcal}',
                color: Colors.orange,
              ),
              if (todayLog.treatsKcal > 0) ...[
                const SizedBox(width: 8),
                _CalorieChip(
                  label: 'Treats',
                  value: '${todayLog.treatsKcal}',
                  color: todayLog.treatsOverBudget
                      ? colorScheme.error
                      : Colors.amber,
                ),
              ],
            ],
          ),
        const SizedBox(height: 24),

        Text('Meals', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        _MealCard(
          name: 'Breakfast',
          time: '8:00 AM',
          kcal: todayLog.breakfastKcal,
          food: todayLog.breakfastFood,
          fed: todayLog.breakfastFed,
          onChanged: notifier.setBreakfastFed,
        ),
        if (isSnackEnabled)
          _MealCard(
            name: 'Lunch / Snack',
            time: '12:00 PM',
            kcal: todayLog.snackKcal,
            food: todayLog.snackFood.isEmpty
                ? 'Puppy meal — smaller portion'
                : todayLog.snackFood,
            fed: todayLog.snackFed,
            onChanged: notifier.setSnackFed,
          ),
        _MealCard(
          name: 'Dinner',
          time: '6:00 PM',
          kcal: todayLog.dinnerKcal,
          food: todayLog.dinnerFood,
          fed: todayLog.dinnerFed,
          onChanged: notifier.setDinnerFed,
        ),

        // Treat tracker section
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Treats', style: theme.textTheme.titleLarge),
            Text(
              '${todayLog.treatsCount} today · ${todayLog.treatsKcal} kcal',
              style: TextStyle(
                color: todayLog.treatsOverBudget
                    ? colorScheme.error
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (todayLog.treatsOverBudget)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: colorScheme.error,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.error),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber,
                    size: 16, color: colorScheme.error),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Treats exceed 10% of daily calories (${todayLog.maxTreatKcal} kcal max). Consider reducing treats.',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: _TreatButton(
                label: 'Small (15 kcal)',
                emoji: '🦴',
                onTap: () => notifier.addTreat(kcalPerTreat: 15),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TreatButton(
                label: 'Medium (30 kcal)',
                emoji: '🍪',
                onTap: () => notifier.addTreat(kcalPerTreat: 30),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _TreatButton(
                label: 'Large (50 kcal)',
                emoji: '🥩',
                onTap: () => notifier.addTreat(kcalPerTreat: 50),
              ),
            ),
          ],
        ),

        // Water intake section
        const SizedBox(height: 32),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Water Intake', style: theme.textTheme.titleLarge),
            Text(
              '${todayLog.waterCups} / ${todayLog.dailyWaterGoalCups} cups',
              style: const TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(todayLog.dailyWaterGoalCups, (index) {
            final isFilled = index < todayLog.waterCups;
            return GestureDetector(
              onTap: () {
                if (isFilled && index == todayLog.waterCups - 1) {
                  notifier.setWaterCups(todayLog.waterCups - 1);
                } else {
                  notifier.setWaterCups(index + 1);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 48,
                height: 64,
                decoration: BoxDecoration(
                  color: isFilled
                      ? Colors.blue.withValues(alpha: 0.2)
                      : colorScheme.surfaceContainer,
                  border: Border.all(
                    color: isFilled ? Colors.blue : colorScheme.outlineVariant,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: isFilled ? Colors.blue : colorScheme.outlineVariant,
                  size: 28,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 80),
      ],
    );
  }
}

class _CalorieChip extends StatelessWidget {
  const _CalorieChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$label: $value kcal',
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
      ),
    );
  }
}

class _TreatButton extends StatelessWidget {
  const _TreatButton({
    required this.label,
    required this.emoji,
    required this.onTap,
  });

  final String label;
  final String emoji;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.name,
    required this.time,
    required this.kcal,
    required this.food,
    required this.fed,
    required this.onChanged,
  });

  final String name;
  final String time;
  final int kcal;
  final String food;
  final bool fed;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: fed ? colorScheme.primary : colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            title:
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$time • $kcal kcal'),
            trailing: Switch(
              value: fed,
              onChanged: onChanged,
              activeThumbColor: colorScheme.primary,
            ),
          ),
          if (fed) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.restaurant,
                    color: colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    food,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
