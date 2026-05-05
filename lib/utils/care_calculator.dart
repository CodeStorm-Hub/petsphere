import 'dart:math';

/// Veterinary-grade calculator for daily calorie, water, and exercise needs.
///
/// Calorie formulas follow AAFCO/NRC guidelines:
///   RER (Resting Energy Requirement) = 70 × (weight_kg)^0.75
///   MER (Maintenance Energy Requirement) = RER × multiplier
///
/// Water guidelines follow general veterinary recommendations:
///   Dogs: ~1 oz per pound (~60 ml/kg)
///   Cats: ~3.5-4.5 oz per 5 lbs (~44 ml/kg)
class CareCalculator {
  CareCalculator._();

  // ─────────────────────────────────────────────────────────────────────────
  // Calorie Calculations
  // ─────────────────────────────────────────────────────────────────────────

  /// Resting Energy Requirement in kcal/day.
  static double rerKcal(double weightKg) {
    if (weightKg <= 0) return 0;
    // Exponential formula is more accurate for all sizes
    return 70 * pow(weightKg, 0.75).toDouble();
  }

  /// Alternative linear formula sometimes used for cats: 30 × kg + 70
  static double rerKcalLinear(double weightKg) {
    if (weightKg <= 0) return 0;
    return 30 * weightKg + 70;
  }

  /// MER multiplier based on species, life stage, activity, and neuter status.
  static double merMultiplier({
    required String species,
    required String ageBand,
    required String activity,
    bool isNeutered = true,
  }) {
    // Base multiplier from species + life stage
    double base;
    switch (species.toLowerCase()) {
      case 'dog':
        base = switch (ageBand) {
          'puppy_kitten' => 2.0,
          'senior' => 1.2,
          _ => isNeutered ? 1.4 : 1.6, // adult
        };
      case 'cat':
        base = switch (ageBand) {
          'puppy_kitten' => 2.0,
          'senior' => 1.1,
          _ => isNeutered ? 1.2 : 1.4, // adult
        };
      case 'bird':
        // Birds have high metabolic rates; use as rough multiplier
        base = switch (ageBand) {
          'puppy_kitten' => 2.0,
          'senior' => 1.3,
          _ => 1.5,
        };
      case 'rabbit':
        base = switch (ageBand) {
          'puppy_kitten' => 2.0,
          'senior' => 1.0,
          _ => 1.3,
        };
      default:
        base = 1.4;
    }

    // Activity adjustment
    final actAdj = switch (activity) {
      'low' => -0.2,
      'high' => 0.3,
      _ => 0.0, // moderate
    };

    return (base + actAdj).clamp(0.8, 3.0);
  }

  /// Recommended daily calorie intake in kcal.
  static int dailyCalories({
    required String species,
    required double weightKg,
    required String ageBand,
    required String activity,
    bool isNeutered = true,
  }) {
    if (weightKg <= 0) return 500; // fallback
    final rer = species.toLowerCase() == 'cat' && weightKg >= 2 && weightKg <= 8
        ? rerKcalLinear(weightKg)
        : rerKcal(weightKg);
    final mul =
        merMultiplier(species: species, ageBand: ageBand, activity: activity, isNeutered: isNeutered);
    return (rer * mul).round().clamp(100, 5000);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Water Calculations
  // ─────────────────────────────────────────────────────────────────────────

  /// Daily water intake in ml.
  static double dailyWaterMl({
    required String species,
    required double weightKg,
  }) {
    if (weightKg <= 0) return 500;
    return switch (species.toLowerCase()) {
      'dog' => weightKg * 60, // ~1 oz per pound
      'cat' => weightKg * 44, // ~3.5-4.5 oz per 5 lbs
      'rabbit' => weightKg * 75, // 50-100 ml/kg
      'bird' => weightKg * 50, // variable
      _ => weightKg * 55,
    };
  }

  /// Daily water goal in cups (1 cup ≈ 237 ml).
  static int dailyWaterCups({
    required String species,
    required double weightKg,
  }) {
    final ml = dailyWaterMl(species: species, weightKg: weightKg);
    return (ml / 237).ceil().clamp(1, 20);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Exercise Recommendations
  // ─────────────────────────────────────────────────────────────────────────

  /// Recommended daily exercise in minutes.
  static int dailyExerciseMinutes({
    required String species,
    required String ageBand,
    required String activity,
  }) {
    return switch (species.toLowerCase()) {
      'dog' => _dogExercise(ageBand, activity),
      'cat' => _catExercise(ageBand, activity),
      'rabbit' => _rabbitExercise(ageBand),
      'bird' => _birdExercise(ageBand),
      _ => 30,
    };
  }

  static int _dogExercise(String ageBand, String activity) {
    final base = switch (ageBand) {
      'puppy_kitten' => 30, // short, frequent
      'senior' => 20,
      _ => 45, // adult
    };
    final actMul = switch (activity) {
      'low' => 0.7,
      'high' => 2.0,
      _ => 1.0,
    };
    return (base * actMul).round().clamp(15, 120);
  }

  static int _catExercise(String ageBand, String activity) {
    return switch (ageBand) {
      'puppy_kitten' => 30,
      'senior' => 15,
      _ => switch (activity) {
          'low' => 15,
          'high' => 40,
          _ => 25,
        },
    };
  }

  static int _rabbitExercise(String ageBand) {
    return switch (ageBand) {
      'puppy_kitten' => 120,
      'senior' => 90,
      _ => 180, // 3-4 hours free roam
    };
  }

  static int _birdExercise(String ageBand) {
    return switch (ageBand) {
      'puppy_kitten' => 60,
      'senior' => 45,
      _ => 90, // 1-2 hours out of cage
    };
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Meal Planning
  // ─────────────────────────────────────────────────────────────────────────

  /// Recommended number of meals per day.
  static int mealsPerDay({
    required String species,
    required String ageBand,
  }) {
    if (ageBand == 'puppy_kitten') return 3;
    if (species.toLowerCase() == 'cat') return 2; // or free-feed
    return 2;
  }

  /// Calories per meal (divides daily total evenly).
  static int kcalPerMeal({
    required int dailyKcal,
    required int numMeals,
  }) {
    if (numMeals <= 0) return dailyKcal;
    return (dailyKcal / numMeals).round();
  }

  /// Maximum treat calories (10% of daily intake).
  static int maxTreatKcal(int dailyKcal) => (dailyKcal * 0.1).round();

  // ─────────────────────────────────────────────────────────────────────────
  // Weight Conversions
  // ─────────────────────────────────────────────────────────────────────────

  static double lbsToKg(double lbs) => lbs * 0.453592;
  static double kgToLbs(double kg) => kg / 0.453592;
}
