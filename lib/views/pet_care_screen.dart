import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/health_controller.dart';
import '../controllers/pet_care_controller.dart';
import '../controllers/pet_controller.dart';
import '../models/pet_care_log_model.dart';
import '../models/pet_health_models.dart';
import '../theme/app_theme.dart';
import 'health_tab.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Symptom preset types
// ─────────────────────────────────────────────────────────────────────────────
const _kSymptomTypes = [
  'Lethargy',
  'Vomiting',
  'Diarrhea',
  'Loss of Appetite',
  'Itching',
  'Sneezing',
  'Limping',
  'Other',
];

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
// 2. HEALTH LOG
// ─────────────────────────────────────────────────────────────────────────────
class _HealthLogTab extends ConsumerWidget {
  const _HealthLogTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final activePet = ref.watch(activePetProvider);
    final careState = ref.watch(petCareProvider);
    if (activePet == null) return const _NoActivePet();

    final weights = careState.recentWeights;
    final latest = weights.isNotEmpty ? weights.last : null;
    final prior = weights.length >= 2 ? weights[weights.length - 2] : null;
    final delta = (latest != null && prior != null)
        ? latest.weightLbs - prior.weightLbs
        : null;
    final maxWeight = weights.isEmpty
        ? 1.0
        : weights.map((w) => w.weightLbs).reduce((a, b) => a > b ? a : b);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Weight Tracking', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.border),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Current Weight',
                      style: TextStyle(color: AppTheme.textSecondary)),
                  if (delta != null)
                    Row(
                      children: [
                        Icon(
                          delta >= 0
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          color: delta >= 0
                              ? Colors.redAccent
                              : AppTheme.secondaryAccent,
                        ),
                        Text(
                          '${delta.abs().toStringAsFixed(1)} lbs vs yesterday',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  else
                    const Text(
                      'Log to see change',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 12),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  latest == null
                      ? '— lbs'
                      : '${latest.weightLbs.toStringAsFixed(1)} lbs',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              if (weights.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'No weight history yet. Tap "Log weight" below to start.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (var i = 0; i < weights.length; i++)
                      _WeightBar(
                        heightFactor: weights[i].weightLbs / maxWeight,
                        label: DateFormat('E')
                            .format(weights[i].logDate)
                            .substring(0, 1),
                        isToday: i == weights.length - 1,
                      ),
                  ],
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _showLogWeightSheet(context, ref, activePet.id),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: AppTheme.primaryAccent.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.monitor_weight,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text('Log weight for today',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Icon(Icons.chevron_right,
                    color: AppTheme.primaryAccent),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),
        Text('Upcoming Vet Appointments', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        if (careState.upcomingAppointments.isEmpty)
          _EmptyHint(
            icon: Icons.event_available,
            text: 'No upcoming appointments scheduled.',
          )
        else
          for (final appt in careState.upcomingAppointments)
            _AppointmentCard(appointment: appt),

        const SizedBox(height: 24),
        Text('Vaccination Timeline', style: theme.textTheme.titleLarge),
        const SizedBox(height: 12),
        if (careState.vaccinations.isEmpty)
          _EmptyHint(
            icon: Icons.vaccines,
            text: 'No vaccinations recorded yet.',
          )
        else
          for (final vax in careState.vaccinations) _VaccinationItem(vax: vax),

        const SizedBox(height: 24),
        _SymptomTrackerSection(
          activeSymptoms: careState.activeSymptoms,
          resolvedSymptoms: careState.resolvedSymptoms,
          petId: activePet.id,
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  Future<void> _showLogWeightSheet(
    BuildContext context,
    WidgetRef ref,
    String petId,
  ) async {
    final controller = TextEditingController();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log today\u2019s weight',
              style: Theme.of(ctx).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Weight (lbs)',
                hintText: 'e.g. 42.5',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final value = double.tryParse(controller.text.trim());
                  if (value == null || value <= 0) return;
                  ref.read(petCareProvider.notifier).logWeight(value);
                  Navigator.of(ctx).pop();
                },
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeightBar extends StatelessWidget {
  const _WeightBar({
    required this.heightFactor,
    required this.label,
    required this.isToday,
  });

  final double heightFactor;
  final String label;
  final bool isToday;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 24,
          height: 100 * heightFactor.clamp(0.05, 1.0),
          decoration: BoxDecoration(
            color: isToday ? AppTheme.primaryAccent : AppTheme.border,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  const _AppointmentCard({required this.appointment});

  final PetVetAppointment appointment;

  @override
  Widget build(BuildContext context) {
    final monthLabel =
        DateFormat('MMM').format(appointment.scheduledAt).toUpperCase();
    final dayLabel = DateFormat('d').format(appointment.scheduledAt);
    final timeLabel =
        DateFormat('h:mm a').format(appointment.scheduledAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: const Border(
          top: BorderSide(color: AppTheme.border),
          right: BorderSide(color: AppTheme.border),
          bottom: BorderSide(color: AppTheme.border),
          left: BorderSide(color: AppTheme.secondaryAccent, width: 4),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  monthLabel,
                  style: const TextStyle(
                    color: AppTheme.secondaryAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                Text(
                  dayLabel,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${appointment.doctor ?? 'Vet'} • $timeLabel',
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VaccinationItem extends StatelessWidget {
  const _VaccinationItem({required this.vax});

  final PetVaccination vax;

  @override
  Widget build(BuildContext context) {
    final dateLabel = vax.isCompleted
        ? (vax.completedOn != null
            ? 'Completed - ${DateFormat('MMM yyyy').format(vax.completedOn!)}'
            : 'Completed')
        : (vax.scheduledFor != null
            ? 'Scheduled - ${DateFormat('MMM yyyy').format(vax.scheduledFor!)}'
            : 'Scheduled');

    final color =
        vax.isCompleted ? AppTheme.secondaryAccent : Colors.orange;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(vax.vaccineName,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(dateLabel,
                    style: const TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              vax.isCompleted ? 'Completed' : 'Scheduled',
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppTheme.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Symptom Tracker Section (embedded in Health tab)
// ─────────────────────────────────────────────────────────────────────────────
class _SymptomTrackerSection extends ConsumerStatefulWidget {
  const _SymptomTrackerSection({
    required this.activeSymptoms,
    required this.resolvedSymptoms,
    required this.petId,
  });

  final List<PetSymptom> activeSymptoms;
  final List<PetSymptom> resolvedSymptoms;
  final String petId;

  @override
  ConsumerState<_SymptomTrackerSection> createState() =>
      _SymptomTrackerSectionState();
}

class _SymptomTrackerSectionState
    extends ConsumerState<_SymptomTrackerSection> {
  bool _showResolved = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasActive = widget.activeSymptoms.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text('Symptom Tracker', style: theme.textTheme.titleLarge),
            const SizedBox(width: 10),
            if (hasActive)
              Container(
                width: 10,
                height: 10,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => _showLogSymptomSheet(context),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryAccent.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: AppTheme.primaryAccent,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.medical_services,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text('Log New Symptom',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Icon(Icons.chevron_right,
                    color: AppTheme.primaryAccent),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (!hasActive && widget.resolvedSymptoms.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: const [
                Icon(Icons.medical_services,
                    size: 36, color: AppTheme.textSecondary),
                SizedBox(height: 12),
                Text(
                  'No symptoms logged.\nTap above to track one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 14),
                ),
              ],
            ),
          )
        else ...[
          for (final s in widget.activeSymptoms)
            _SymptomCard(symptom: s, onResolve: _onResolve),
          if (widget.resolvedSymptoms.isNotEmpty) ...[
            GestureDetector(
              onTap: () =>
                  setState(() => _showResolved = !_showResolved),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Text(
                      '${widget.resolvedSymptoms.length} Resolved',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _showResolved
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: AppTheme.textSecondary,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            if (_showResolved)
              for (final s in widget.resolvedSymptoms)
                _SymptomCard(symptom: s, onResolve: null),
          ],
        ],
      ],
    );
  }

  void _onResolve(String symptomId) {
    ref.read(petCareProvider.notifier).resolveSymptom(symptomId);
  }

  Future<void> _showLogSymptomSheet(BuildContext context) async {
    String? selectedType;
    String severity = 'mild';
    final notesCtrl = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Log a Symptom',
                        style: Theme.of(ctx).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _kSymptomTypes.map((type) {
                        final selected = selectedType == type;
                        return GestureDetector(
                          onTap: () =>
                              setSheetState(() => selectedType = type),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppTheme.primaryAccent
                                      .withValues(alpha: 0.2)
                                  : AppTheme.surface,
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: selected
                                    ? AppTheme.primaryAccent
                                    : AppTheme.border,
                              ),
                            ),
                            child: Text(
                              type,
                              style: TextStyle(
                                fontSize: 13,
                                color: selected
                                    ? AppTheme.primaryAccent
                                    : AppTheme.textSecondary,
                                fontWeight: selected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Text('Severity',
                        style: Theme.of(ctx).textTheme.titleSmall),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        for (final (label, key, color) in [
                          ('Mild', 'mild', AppTheme.secondaryAccent),
                          ('Moderate', 'moderate', Colors.orange),
                          ('Severe', 'severe', Colors.redAccent),
                        ])
                          Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setSheetState(() => severity = key),
                              child: AnimatedContainer(
                                duration: const Duration(
                                    milliseconds: 200),
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 4),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10),
                                decoration: BoxDecoration(
                                  color: severity == key
                                      ? color.withValues(alpha: 0.25)
                                      : AppTheme.surface,
                                  borderRadius:
                                      BorderRadius.circular(12),
                                  border: Border.all(
                                    color: severity == key
                                        ? color
                                        : AppTheme.border,
                                    width: 2,
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontWeight: severity == key
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: severity == key
                                        ? color
                                        : AppTheme.textSecondary,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: notesCtrl,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'e.g. started this morning…',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedType == null
                            ? null
                            : () {
                                ref
                                    .read(petCareProvider.notifier)
                                    .logSymptom(
                                      symptomType: selectedType!,
                                      severity: severity,
                                      notes: notesCtrl.text.trim(),
                                    );
                                Navigator.of(ctx).pop();
                              },
                        child: const Text('Save Symptom'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _SymptomCard extends StatelessWidget {
  const _SymptomCard({
    required this.symptom,
    required this.onResolve,
  });

  final PetSymptom symptom;
  final void Function(String id)? onResolve;

  @override
  Widget build(BuildContext context) {
    final isResolved = symptom.isResolved;
    final elapsed = DateTime.now().difference(symptom.observedAt);
    final timeAgo = elapsed.inHours < 24
        ? '${elapsed.inHours}h ago'
        : '${elapsed.inDays}d ago';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isResolved
            ? AppTheme.surface
            : AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isResolved
              ? AppTheme.border
              : symptom.severityColor.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isResolved
                  ? AppTheme.secondaryAccent
                  : symptom.severityColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        symptom.symptomType,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: isResolved
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary,
                          decoration: isResolved
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: (isResolved
                                ? AppTheme.secondaryAccent
                                : symptom.severityColor)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        isResolved ? 'Resolved' : symptom.severityLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isResolved
                              ? AppTheme.secondaryAccent
                              : symptom.severityColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  timeAgo,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                if (symptom.notes != null &&
                    symptom.notes!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    symptom.notes!,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
                if (!isResolved && onResolve != null) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () => onResolve!(symptom.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: const Text(
                        'Mark Resolved',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

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
