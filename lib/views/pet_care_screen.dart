import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/health_controller.dart';
import '../controllers/pet_care_controller.dart';
import '../controllers/pet_controller.dart';
import '../models/pet_care_log_model.dart';
import '../theme/app_theme.dart';
import 'health_tab.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pet Care'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryAccent,
          unselectedLabelColor: AppTheme.textSecondary,
          indicatorColor: AppTheme.primaryAccent,
          tabs: const [
            Tab(text: 'Care Diary'),
            Tab(text: 'Health'),
            Tab(text: 'Feeding'),
          ],
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
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        const Icon(Icons.pets, size: 56, color: AppTheme.textSecondary),
        const SizedBox(height: 16),
        Text(
          'Add a pet to start tracking care',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        const Text(
          'Once you create a pet profile, daily logs, weight history, and vet appointments will live here.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppTheme.textSecondary),
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
    final theme = Theme.of(context);
    final myPets = ref.watch(petProvider).myPets;
    final activePet = ref.watch(activePetProvider);
    final careState = ref.watch(petCareProvider);
    final todayLog = careState.todayLog;

    if (activePet == null) return const _NoActivePet();
    if (todayLog == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final completedTasks = todayLog.completedTasks;
    final totalTasks = todayLog.tasks.length;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (myPets.isNotEmpty) ...[
          _PetSelector(myPets: myPets, activeId: activePet.id),
          const SizedBox(height: 24),
        ],

        // Animated rings
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ProgressRing(
              label: 'Tasks',
              progress:
                  totalTasks == 0 ? 0 : completedTasks / totalTasks,
              color: AppTheme.primaryAccent,
              centerText: '$completedTasks/$totalTasks',
            ),
            _ProgressRing(
              label: 'Calories',
              progress: todayLog.caloriesProgress,
              color: Colors.orange,
              centerText:
                  '${todayLog.consumedKcal}\nkcal',
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
              style: const TextStyle(
                color: AppTheme.primaryAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: totalTasks == 0 ? 0 : completedTasks / totalTasks,
          backgroundColor: AppTheme.border,
          color: AppTheme.primaryAccent,
          borderRadius: BorderRadius.circular(999),
        ),
        const SizedBox(height: 16),

        for (final task in todayLog.tasks)
          _TaskCard(
            task: task,
            onToggle: () =>
                ref.read(petCareProvider.notifier).toggleTask(task.key),
          ),

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
        const SizedBox(height: 80),
      ],
    );
  }
}

// ───────────── Pet selector ─────────────
class _PetSelector extends ConsumerWidget {
  const _PetSelector({required this.myPets, required this.activeId});

  final List myPets;
  final String activeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 72,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: myPets.length,
        itemBuilder: (context, i) {
          final pet = myPets[i];
          final isSelected = pet.id == activeId;
          return GestureDetector(
            onTap: () => ref.read(petProvider.notifier).setActivePet(pet),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? AppTheme.primaryAccent
                      : Colors.transparent,
                  width: 3,
                ),
              ),
              child: CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.surface,
                backgroundImage: pet.profileImageUrl.isNotEmpty
                    ? NetworkImage(pet.profileImageUrl)
                    : null,
                child: pet.profileImageUrl.isEmpty
                    ? const Icon(Icons.pets, color: AppTheme.textSecondary)
                    : null,
              ),
            ),
          );
        },
      ),
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
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
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
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: complete
            ? AppTheme.primaryAccent.withValues(alpha: 0.2)
            : AppTheme.surface,
        border: Border.all(
          color: complete ? AppTheme.primaryAccent : AppTheme.border,
        ),
      ),
      alignment: Alignment.center,
      child: complete
          ? const Icon(Icons.check, size: 16, color: AppTheme.primaryAccent)
          : Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textSecondary,
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
                  backgroundColor: AppTheme.border,
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
        Text(label, style: const TextStyle(
          color: AppTheme.textSecondary,
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
    final isDone = task.done;
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDone
              ? AppTheme.secondaryAccent.withValues(alpha: 0.1)
              : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDone ? AppTheme.secondaryAccent : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    isDone ? AppTheme.secondaryAccent : AppTheme.surface,
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isDone ? AppTheme.secondaryAccent : AppTheme.border,
                ),
              ),
              child: Icon(
                task.icon,
                color: isDone ? Colors.white : AppTheme.textSecondary,
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
                      decoration:
                          isDone ? TextDecoration.lineThrough : null,
                      color: isDone
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    task.subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isDone ? Icons.check_circle : Icons.radio_button_unchecked,
              color: isDone ? AppTheme.secondaryAccent : AppTheme.border,
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
    return GestureDetector(
      onTap: () => ref
          .read(petCareProvider.notifier)
          .setMood(selected ? null : label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primaryAccent.withValues(alpha: 0.2)
              : AppTheme.cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppTheme.primaryAccent : AppTheme.border,
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
                fontWeight:
                    selected ? FontWeight.bold : FontWeight.normal,
                color: selected
                    ? AppTheme.primaryAccent
                    : AppTheme.textSecondary,
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
    final theme = Theme.of(context);
    final activePet = ref.watch(activePetProvider);
    final todayLog = ref.watch(todayCareLogProvider);

    if (activePet == null) return const _NoActivePet();
    if (todayLog == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final notifier = ref.read(petCareProvider.notifier);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              fit: StackFit.expand,
              children: [
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: todayLog.caloriesProgress),
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                  builder: (_, value, __) => CircularProgressIndicator(
                    value: value,
                    strokeWidth: 12,
                    backgroundColor: AppTheme.border,
                    color: Colors.orange,
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
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),

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
        _MealCard(
          name: 'Dinner',
          time: '6:00 PM',
          kcal: todayLog.dinnerKcal,
          food: todayLog.dinnerFood,
          fed: todayLog.dinnerFed,
          onChanged: notifier.setDinnerFed,
        ),

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
                      : AppTheme.cardColor,
                  border: Border.all(
                    color: isFilled ? Colors.blue : AppTheme.border,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  Icons.water_drop,
                  color: isFilled ? Colors.blue : AppTheme.border,
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: fed ? AppTheme.primaryAccent : AppTheme.border,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            title: Text(name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('$time • $kcal kcal'),
            trailing: Switch(
              value: fed,
              onChanged: onChanged,
              activeThumbColor: AppTheme.primaryAccent,
            ),
          ),
          if (fed) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(
                    Icons.restaurant,
                    color: AppTheme.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    food,
                    style: const TextStyle(color: AppTheme.textSecondary),
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
