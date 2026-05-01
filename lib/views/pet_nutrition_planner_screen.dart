import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/pet_controller.dart';

class PetNutritionPlannerScreen extends ConsumerStatefulWidget {
  const PetNutritionPlannerScreen({super.key});

  @override
  ConsumerState<PetNutritionPlannerScreen> createState() => _PetNutritionPlannerScreenState();
}

class _PetNutritionPlannerScreenState extends ConsumerState<PetNutritionPlannerScreen> {
  int _waterIntake = 450;
  final int _waterGoal = 800;

  final List<Map<String, dynamic>> _meals = [
    {'title': 'Breakfast', 'time': '08:00 AM', 'calories': 250, 'isDone': true, 'type': 'Kibble', 'macros': {'p': 30, 'f': 15, 'c': 55}},
    {'title': 'Lunch', 'time': '01:00 PM', 'calories': 200, 'isDone': false, 'type': 'Wet Food', 'macros': {'p': 45, 'f': 25, 'c': 30}},
    {'title': 'Dinner', 'time': '07:00 PM', 'calories': 300, 'isDone': false, 'type': 'Raw Mix', 'macros': {'p': 50, 'f': 30, 'c': 20}},
  ];

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider);
    final totalConsumed = _meals.where((m) => m['isDone']).fold<int>(0, (sum, m) => sum + (m['calories'] as int));
    final budget = (pet.activePet?.weightLbs ?? 10) * 70; // Basic RER formula

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            title: const Text('Nutrition & Diet', style: TextStyle(fontWeight: FontWeight.bold)),
            actions: [
              IconButton.filledTonal(onPressed: () {}, icon: const Icon(Icons.analytics_outlined)),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _CalorieBudgetCard(consumed: totalConsumed, total: budget.toInt(), petName: pet.activePet?.name ?? 'Pet'),
                  const SizedBox(height: 24),
                  _HydrationTracker(current: _waterIntake, goal: _waterGoal, onAdd: () => setState(() => _waterIntake += 100)),
                  const SizedBox(height: 32),
                  _SafeFoodLookup(),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Meal Schedule', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                      TextButton.icon(onPressed: () {}, icon: const Icon(Icons.add_rounded), label: const Text('Add Meal')),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ..._meals.asMap().entries.map((entry) => _MealItem(
                        meal: entry.value,
                        onChanged: (val) => setState(() => _meals[entry.key]['isDone'] = val),
                      )),
                  const SizedBox(height: 32),
                  _DietaryProfile(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalorieBudgetCard extends StatelessWidget {
  final int consumed;
  final int total;
  final String petName;

  const _CalorieBudgetCard({required this.consumed, required this.total, required this.petName});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (consumed / total).clamp(0.0, 1.0);

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
          BoxShadow(color: colorScheme.primary.withAlpha(60), blurRadius: 24, offset: const Offset(0, 10))
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
                  Text('$petName\'s Daily Goal', style: TextStyle(color: Colors.white.withAlpha(200), fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('$consumed / $total kcal', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 32)),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.white.withAlpha(40), shape: BoxShape.circle),
                child: const Icon(Icons.restaurant_rounded, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 28),
          Stack(
            children: [
              Container(
                height: 12,
                width: double.infinity,
                decoration: BoxDecoration(color: Colors.white.withAlpha(40), borderRadius: BorderRadius.circular(6)),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [BoxShadow(color: Colors.white.withAlpha(100), blurRadius: 10)],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatMini(label: 'Protein', value: '45%', color: Colors.white.withAlpha(220)),
              _StatMini(label: 'Fats', value: '25%', color: Colors.white.withAlpha(220)),
              _StatMini(label: 'Carbs', value: '30%', color: Colors.white.withAlpha(220)),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatMini({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: color)),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: color.withAlpha(180), fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
      ],
    );
  }
}

class _HydrationTracker extends StatelessWidget {
  final int current;
  final int goal;
  final VoidCallback onAdd;

  const _HydrationTracker({required this.current, required this.goal, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = (current / goal).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.blue.withAlpha(15),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.blue.withAlpha(30)),
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
                    color: Colors.blue,
                    backgroundColor: Colors.blue.withAlpha(30),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                const Icon(Icons.water_drop_rounded, color: Colors.blue, size: 28),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Hydration Level', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: -0.5)),
                const SizedBox(height: 2),
                Text('$current / $goal ml consumed today', style: TextStyle(color: colorScheme.onSurfaceVariant.withAlpha(180), fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Material(
            color: Colors.blue.withAlpha(30),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onAdd,
              borderRadius: BorderRadius.circular(16),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.add_rounded, color: Colors.blue),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafeFoodLookup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Safe Food Search', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SearchBar(
          hintText: 'Can my pet eat apples?',
          leading: const Icon(Icons.search_rounded),
          padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
          elevation: const WidgetStatePropertyAll(0),
          backgroundColor: WidgetStatePropertyAll(colorScheme.surfaceContainerHigh),
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        ),
      ],
    );
  }
}

class _MealItem extends StatelessWidget {
  final Map<String, dynamic> meal;
  final ValueChanged<bool?> onChanged;

  const _MealItem({required this.meal, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDone = meal['isDone'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDone ? colorScheme.primary.withAlpha(20) : colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDone ? colorScheme.primary.withAlpha(50) : colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Checkbox(
            value: isDone,
            onChanged: onChanged,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(meal['title'], style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                  decoration: isDone ? TextDecoration.lineThrough : null,
                  color: isDone ? Colors.grey : null,
                )),
                Text('${meal['time']} • ${meal['type']}', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${meal['calories']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const Text('kcal', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}

class _DietaryProfile extends StatelessWidget {
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
              Text('Dietary Profile', style: TextStyle(color: colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _Tag(label: 'Grain-Free', color: Colors.brown),
              _Tag(label: 'Low Sodium', color: Colors.blue),
              _Tag(label: 'Sensitive Stomach', color: Colors.orange),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Smart Tip: Your pet\'s protein intake is optimal today. Consider adding some fiber-rich veggies like carrots.',
            style: TextStyle(color: colorScheme.onSecondaryContainer.withAlpha(200), fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color;
  const _Tag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }
}
