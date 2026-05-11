import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petfolio/features/nutrition/data/nutrition_repository.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/care/presentation/controllers/pet_nutrition_controller.dart';
import 'package:petfolio/core/widgets/async_value_widget.dart';
import 'package:petfolio/core/widgets/petfolio_widgets.dart';

class PetNutritionPlannerScreen extends ConsumerStatefulWidget {
  const PetNutritionPlannerScreen({super.key});

  @override
  ConsumerState<PetNutritionPlannerScreen> createState() =>
      _PetNutritionPlannerScreenState();
}

class _PetNutritionPlannerScreenState
    extends ConsumerState<PetNutritionPlannerScreen> {
  void _showAddMealSheet(String? petId) {
    if (petId == null) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddMealSheet(
        petId: petId,
        onAdded: () => ref.invalidate(todayNutritionProvider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petProvider);
    final nutritionAsync = ref.watch(todayNutritionProvider);
    final activePet = petState.activePet;

    if (activePet == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Nutrition & Diet'),
        ),
        body: const PetfolioEmptyState(
          icon: Icons.pets_rounded,
          title: 'No Active Pet',
          message: 'Please select a pet to view and manage their nutrition plan.',
        ),
      );
    }

    return Scaffold(
      body: AsyncValueWidget<List<NutritionLog>>(
        value: nutritionAsync,
        onRetry: () => ref.invalidate(todayNutritionProvider),
        data: (logs) {
          final totalConsumed = logs.fold<int>(
            0,
            (sum, log) => sum + (log.calories ?? 0),
          );
          final waterIntake = logs.fold<int>(
            0,
            (sum, log) => sum + (log.waterMl ?? 0),
          );
          final budget = (activePet.weightLbs ?? 10) * 70; // Basic RER formula
          const waterGoal = 800; // Hardcoded goal for now

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverAppBar.large(
                title: const Text(
                  'Nutrition & Diet',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                actions: [
                  IconButton.filledTonal(
                    onPressed: () {},
                    icon: const Icon(Icons.analytics_outlined),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _CalorieBudgetCard(
                        consumed: totalConsumed,
                        total: budget.toInt(),
                        petName: activePet.name,
                        logs: logs,
                      ),
                      const SizedBox(height: 24),
                      _HydrationTracker(
                        current: waterIntake,
                        goal: waterGoal,
                        onAdd: () async {
                          await ref
                              .read(petNutritionControllerProvider.notifier)
                              .addMeal(
                                petId: activePet.id,
                                mealName: 'Water',
                                mealType: 'Beverage',
                                waterMl: 100,
                              );
                        },
                      ),
                      const SizedBox(height: 32),
                      const _SafeFoodLookup(),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Meal History',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          TextButton.icon(
                            onPressed: () => _showAddMealSheet(activePet.id),
                            icon: const Icon(Icons.add_rounded),
                            label: const Text('Add Meal'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (logs.where((l) => l.mealName != 'Water').isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: PetfolioEmptyState(
                              icon: Icons.restaurant_menu_rounded,
                              title: 'No Meals Logged',
                              message: 'Log your first meal for today to track calories.',
                            ),
                          ),
                        )
                      else
                        ...logs
                            .where((l) => l.mealName != 'Water')
                            .map((log) => _MealItem(log: log)),
                      const SizedBox(height: 32),
                      const _DietaryProfile(),
                      const SizedBox(height: 40),
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
}

class _CalorieBudgetCard extends StatelessWidget {

  const _CalorieBudgetCard({
    required this.consumed,
    required this.total,
    required this.petName,
    required this.logs,
  });
  final int consumed;
  final int total;
  final String petName;
  final List<NutritionLog> logs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (consumed / total).clamp(0.0, 1.0);

    // Calculate averages for macros
    var avgProtein = 0;
    var avgFat = 0;
    var avgCarb = 0;
    final foodLogs = logs.where((l) => l.mealName != 'Water').toList();
    if (foodLogs.isNotEmpty) {
      avgProtein =
          foodLogs.fold<int>(0, (sum, l) => sum + (l.proteinPct ?? 0)) ~/
          foodLogs.length;
      avgFat =
          foodLogs.fold<int>(0, (sum, l) => sum + (l.fatPct ?? 0)) ~/
          foodLogs.length;
      avgCarb =
          foodLogs.fold<int>(0, (sum, l) => sum + (l.carbPct ?? 0)) ~/
          foodLogs.length;
    }

    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primary.withAlpha(200)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(36),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(60),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$petName\'s Daily Goal',
                    style: TextStyle(
                      color: Colors.white.withAlpha(200),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$consumed / $total kcal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 32,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.restaurant_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(40),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress.clamp(0.05, 1.0),
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withAlpha(100),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatMini(
                label: 'Protein',
                value: foodLogs.isEmpty ? '0%' : '$avgProtein%',
                color: Colors.white.withAlpha(220),
              ),
              _StatMini(
                label: 'Fats',
                value: foodLogs.isEmpty ? '0%' : '$avgFat%',
                color: Colors.white.withAlpha(220),
              ),
              _StatMini(
                label: 'Carbs',
                value: foodLogs.isEmpty ? '0%' : '$avgCarb%',
                color: Colors.white.withAlpha(220),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  const _StatMini({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: color.withAlpha(180),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _HydrationTracker extends StatelessWidget {

  const _HydrationTracker({
    required this.current,
    required this.goal,
    required this.onAdd,
  });
  final int current;
  final int goal;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (current / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withAlpha(15),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorScheme.secondary.withAlpha(30)),
      ),
      child: Row(
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 1500),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    color: colorScheme.secondary,
                    backgroundColor: colorScheme.secondary.withAlpha(30),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Icon(
                  Icons.water_drop_rounded,
                  color: colorScheme.secondary,
                  size: 28,
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hydration Level',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$current / $goal ml consumed today',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant.withAlpha(180),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Material(
            color: colorScheme.secondary.withAlpha(30),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Icon(Icons.add_rounded, color: colorScheme.secondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafeFoodLookup extends StatelessWidget {
  const _SafeFoodLookup();
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Safe Food Search',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        SearchBar(
          hintText: 'Can my pet eat apples?',
          leading: const Icon(Icons.search_rounded),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 16),
          ),
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(
            colorScheme.surfaceContainerHigh,
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
        ),
      ],
    );
  }
}

class _MealItem extends StatelessWidget {

  const _MealItem({required this.log});
  final NutritionLog log;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final timeStr =
        '${log.loggedAt.hour}:${log.loggedAt.minute.toString().padLeft(2, '0')}';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha(30),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.restaurant_rounded,
              color: colorScheme.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  log.mealName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$timeStr • ${log.mealType}',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${log.calories ?? 0}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Text(
                'kcal',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DietaryProfile extends StatelessWidget {
  const _DietaryProfile();
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withAlpha(100),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.shield_rounded, color: colorScheme.secondary),
              const SizedBox(width: 12),
              Text(
                'Dietary Profile',
                style: TextStyle(
                  color: colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(label: 'Grain-Free', color: colorScheme.error),
              _Tag(label: 'Low Sodium', color: colorScheme.secondary),
              _Tag(label: 'Sensitive Stomach', color: colorScheme.tertiary),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Smart Tip: Your pet\'s protein intake is optimal today. Consider adding some fiber-rich veggies like carrots.',
            style: TextStyle(
              color: colorScheme.onSecondaryContainer.withAlpha(200),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

class _AddMealSheet extends ConsumerStatefulWidget {

  const _AddMealSheet({required this.petId, required this.onAdded});
  final String petId;
  final VoidCallback onAdded;

  @override
  ConsumerState<_AddMealSheet> createState() => _AddMealSheetState();
}

class _AddMealSheetState extends ConsumerState<_AddMealSheet> {
  final _mealNameCtrl = TextEditingController();
  final _foodTypeCtrl = TextEditingController();
  final _calsCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _carbCtrl = TextEditingController();

  @override
  void dispose() {
    _mealNameCtrl.dispose();
    _foodTypeCtrl.dispose();
    _calsCtrl.dispose();
    _proteinCtrl.dispose();
    _fatCtrl.dispose();
    _carbCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_mealNameCtrl.text.isEmpty) return;

    await ref
        .read(petNutritionControllerProvider.notifier)
        .addMeal(
          petId: widget.petId,
          mealName: _mealNameCtrl.text.trim(),
          mealType: _foodTypeCtrl.text.trim(),
          calories: int.tryParse(_calsCtrl.text),
          proteinPct: int.tryParse(_proteinCtrl.text),
          fatPct: int.tryParse(_fatCtrl.text),
          carbPct: int.tryParse(_carbCtrl.text),
        );

    if (mounted) {
      final state = ref.read(petNutritionControllerProvider);
      if (state.hasError) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${state.error}')));
      } else {
        widget.onAdded();
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final saving = ref.watch(petNutritionControllerProvider).isLoading;

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
      child: SingleChildScrollView(
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
              'Log a Meal',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _mealNameCtrl,
              decoration: InputDecoration(
                labelText: 'Meal Name (e.g. Breakfast)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _foodTypeCtrl,
              decoration: InputDecoration(
                labelText: 'Food Type (e.g. Kibble, Wet Food)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _calsCtrl,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Calories (kcal)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _proteinCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Protein %',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _fatCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Fat %',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _carbCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Carbs %',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ],
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
                    : const Text('Add Meal'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
