import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/care_log_controller.dart';

import 'package:petfolio/features/care/data/models/pet_care_log_model.dart';
import 'package:petfolio/features/care/utils/care_calculator.dart';

class CareGoalEditorModal extends ConsumerStatefulWidget {
  const CareGoalEditorModal({
    super.key,
    required this.todayLog,
    required this.onboardingData,
  });

  final PetCareLog todayLog;
  final Map<String, dynamic> onboardingData;

  static Future<void> show(
    BuildContext context,
    PetCareLog todayLog,
    Map<String, dynamic> onboardingData,
  ) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CareGoalEditorModal(
        todayLog: todayLog,
        onboardingData: onboardingData,
      ),
    );
  }

  @override
  ConsumerState<CareGoalEditorModal> createState() =>
      _CareGoalEditorModalState();
}

class _CareGoalEditorModalState extends ConsumerState<CareGoalEditorModal> {
  late double _calorieGoal;
  late double _waterGoal;
  late double _exerciseGoal;

  late int _baselineKcal;
  late int _baselineWater;
  late int _baselineExercise;

  @override
  void initState() {
    super.initState();
    _calorieGoal = widget.todayLog.dailyCalorieGoal.toDouble();
    _waterGoal = widget.todayLog.dailyWaterGoalCups.toDouble();
    _exerciseGoal = widget.todayLog.dailyExerciseGoalMinutes.toDouble();

    // Calculate baselines using CareCalculator
    const weightKg =
        10.0; // Fallback, we'd ideally get this from the pet profile. Assuming 10kg for generic warnings if weight is missing.
    final species = widget.onboardingData['species'] as String? ?? 'Dog';
    final isNeutered = widget.onboardingData['is_neutered'] as bool? ?? false;
    final activity = widget.onboardingData['activity'] as String? ?? 'moderate';
    final ageBand = widget.onboardingData['age_band'] as String? ?? 'adult';

    _baselineKcal = CareCalculator.dailyCalories(
      weightKg: weightKg,
      species: species,
      isNeutered: isNeutered,
      activity: activity,
      ageBand: ageBand,
    );
    _baselineWater = CareCalculator.dailyWaterCups(
      species: species,
      weightKg: weightKg,
    );
    _baselineExercise = CareCalculator.dailyExerciseMinutes(
      species: species,
      ageBand: ageBand,
      activity: activity,
    );
  }

  bool get _hasCalorieWarning =>
      _calorieGoal < _baselineKcal * 0.7 || _calorieGoal > _baselineKcal * 1.3;

  bool get _hasWaterWarning =>
      _waterGoal < _baselineWater * 0.5 || _waterGoal > _baselineWater * 2.0;

  bool get _hasExerciseWarning =>
      _exerciseGoal < _baselineExercise * 0.5 ||
      _exerciseGoal > _baselineExercise * 2.0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Daily Goals',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  tooltip: 'Close',
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Customize your pet's daily targets. Baselines are calculated using veterinary formulas based on their profile.",
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),

            // Calorie Slider
            _buildGoalSection(
              title: 'Daily Calories',
              value: '${_calorieGoal.toInt()} kcal',
              baseline: 'Calculated baseline: $_baselineKcal kcal',
              warning: _hasCalorieWarning
                  ? 'Warning: This calorie target deviates significantly from the recommended baseline. Rapid weight loss or gain can cause severe health issues. Please consult your vet.'
                  : null,
              slider: Slider(
                value: _calorieGoal,
                min: 100,
                max: 3000,
                divisions: 290,
                activeColor: _hasCalorieWarning
                    ? colorScheme.error
                    : colorScheme.primary,
                onChanged: (v) => setState(() => _calorieGoal = v),
              ),
            ),

            // Water Slider
            _buildGoalSection(
              title: 'Daily Water Intake',
              value: '${_waterGoal.toInt()} cups',
              baseline: 'Calculated baseline: $_baselineWater cups',
              warning: _hasWaterWarning
                  ? 'Warning: Unusually high or low water intake goals can be dangerous or indicate underlying conditions like kidney disease.'
                  : null,
              slider: Slider(
                value: _waterGoal,
                min: 1,
                max: 20,
                divisions: 19,
                activeColor: _hasWaterWarning
                    ? colorScheme.error
                    : colorScheme.primary,
                onChanged: (v) => setState(() => _waterGoal = v),
              ),
            ),

            // Exercise Slider
            _buildGoalSection(
              title: 'Daily Exercise',
              value: '${_exerciseGoal.toInt()} min',
              baseline: 'Calculated baseline: $_baselineExercise min',
              warning: _hasExerciseWarning
                  ? 'Note: This exercise goal is far outside the typical range for this species/age. Ensure it is safe for your pet.'
                  : null,
              slider: Slider(
                value: _exerciseGoal,
                max: 240,
                divisions: 24,
                activeColor: _hasExerciseWarning
                    ? colorScheme.tertiary
                    : colorScheme.secondary,
                onChanged: (v) => setState(() => _exerciseGoal = v),
              ),
            ),

            const SizedBox(height: 16),
            FilledButton(
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: (_hasCalorieWarning || _hasWaterWarning)
                    ? colorScheme.error
                    : colorScheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                ref
                    .read(careLogProvider.notifier)
                    .updateDailyGoals(
                      calorieGoal: _calorieGoal.toInt(),
                      waterGoalCups: _waterGoal.toInt(),
                      exerciseGoalMinutes: _exerciseGoal.toInt(),
                    );
                Navigator.pop(context);
              },
              child: Text(
                (_hasCalorieWarning || _hasWaterWarning)
                    ? 'Confirm Changes & Accept Risk'
                    : 'Save Goals',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalSection({
    required String title,
    required String value,
    required String baseline,
    required String? warning,
    required Widget slider,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: warning != null
              ? colorScheme.error
              : colorScheme.outlineVariant,
          width: warning != null ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: warning != null
                      ? colorScheme.error
                      : colorScheme.onSurface,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            baseline,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
          slider,
          if (warning != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber,
                    size: 18,
                    color: Theme.of(context).colorScheme.error,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      warning,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
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
