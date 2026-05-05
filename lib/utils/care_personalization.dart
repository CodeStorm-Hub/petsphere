import '../models/care_badge_model.dart';
import '../models/pet_care_log_model.dart';
import 'care_calculator.dart';

/// Short hints derived from [PetCareOnboarding.data] for checklist encouragement.
String careChecklistNudge(
  Map<String, dynamic> data, {
  required int completed,
  required int total,
}) {
  final act = data[PetCareOnboarding.kActivity] as String? ?? 'moderate';
  final multi = data[PetCareOnboarding.kMultiPet] as bool? ?? false;
  final species = data[PetCareOnboarding.kSpecies] as String? ?? 'Dog';
  if (total == 0) return 'Set up care preferences for tailored tips.';
  if (completed == total) {
    return _completionMessage(species, multi);
  }
  final base = switch (act) {
    'low' => 'Short, gentle activities still count. ',
    'high' => 'Channel that energy: small wins add up. ',
    _ => 'Every check-in helps. ',
  };
  final extra =
      multi ? 'In multi-pet homes, a calm minute per pet reduces stress. ' : '';
  return '$base${extra}You are $completed / $total today.';
}

String _completionMessage(String species, bool multiPet) {
  final speciesMsg = switch (species.toLowerCase()) {
    'cat' => 'Purr-fect! Your kitty is set for a wonderful day.',
    'bird' => 'Tweet-tastic! Your feathered friend is thriving.',
    'rabbit' => 'Hoppy days! Your bunny is well cared for.',
    _ => 'Nice work—your pet is set up for a great day.',
  };
  return multiPet
      ? '$speciesMsg Keep the love going for your other pets too!'
      : speciesMsg;
}

/// Resolves the checklist template for care logs from [PetCareOnboarding.data].
/// When [kUseCustomChecklist] is true and [kCustomTasks] is a non-empty list, returns those tasks; otherwise [DailyTask.defaults].
List<DailyTask> dailyTaskTemplateFromOnboardingData(Map<String, dynamic> data) {
  if (data[PetCareOnboarding.kUseCustomChecklist] == true) {
    final raw = data[PetCareOnboarding.kCustomTasks];
    if (raw is List) {
      final out = <DailyTask>[];
      for (final item in raw) {
        if (item is! Map) continue;
        final m = Map<String, dynamic>.from(item);
        final key = m['key'] as String? ?? 'custom_${out.length}';
        m['key'] = key;
        out.add(DailyTask.fromJson(m));
      }
      if (out.isNotEmpty) return out;
    }
  }

  // Species-specific task templates
  final species = data[PetCareOnboarding.kSpecies] as String? ?? 'Dog';
  final ageBand = data[PetCareOnboarding.kAgeBand] as String? ?? 'adult';
  final activity = data[PetCareOnboarding.kActivity] as String? ?? 'moderate';
  return speciesTaskTemplate(
    species: species,
    ageBand: ageBand,
    activity: activity,
  );
}

/// Generates species-specific daily task templates based on pet profile.
List<DailyTask> speciesTaskTemplate({
  required String species,
  String ageBand = 'adult',
  String activity = 'moderate',
}) {
  return switch (species.toLowerCase()) {
    'cat' => _catTasks(ageBand, activity),
    'bird' => _birdTasks(ageBand),
    'rabbit' => _rabbitTasks(ageBand),
    _ => _dogTasks(ageBand, activity),
  };
}

List<DailyTask> _dogTasks(String ageBand, String activity) {
  final walkSubtitle = switch (ageBand) {
    'puppy_kitten' => '15 min — keep it short for growing joints',
    'senior' => '15–20 min gentle walk',
    _ => switch (activity) {
        'low' => '20 min at an easy pace',
        'high' => '45–60 min vigorous exercise',
        _ => '30 min walk or outdoor play',
      },
  };

  final feedSubtitle = ageBand == 'puppy_kitten'
      ? '3 meals today — puppies need frequent feeding'
      : '2 balanced meals — portion to daily calorie goal';

  return [
    DailyTask(
      key: 'walk',
      title: 'Exercise Time',
      subtitle: walkSubtitle,
      iconKey: 'pets',
    ),
    DailyTask(
      key: 'feed',
      title: 'Feeding',
      subtitle: feedSubtitle,
      iconKey: 'restaurant',
    ),
    DailyTask(
      key: 'med',
      title: 'Medication / Vitamins',
      subtitle: 'As your vet directed',
      iconKey: 'medical_services',
    ),
    DailyTask(
      key: 'groom',
      title: 'Grooming',
      subtitle: ageBand == 'senior'
          ? 'Gentle brush + check for lumps'
          : 'Brush coat & check ears',
      iconKey: 'brush',
    ),
    if (ageBand != 'puppy_kitten')
      const DailyTask(
        key: 'dental',
        title: 'Dental Care',
        subtitle: 'Brush teeth or give dental chew',
        iconKey: 'brush',
      ),
  ];
}

List<DailyTask> _catTasks(String ageBand, String activity) {
  final playSubtitle = switch (ageBand) {
    'puppy_kitten' => '3–4 short play bursts — kittens love to chase!',
    'senior' => '10–15 min gentle play to keep joints moving',
    _ => '2–3 sessions of 10–15 min interactive play',
  };

  return [
    DailyTask(
      key: 'feed',
      title: 'Feeding',
      subtitle: ageBand == 'puppy_kitten'
          ? '3–4 meals — kittens need frequent nutrition'
          : 'Wet + dry portions as scheduled',
      iconKey: 'restaurant',
    ),
    DailyTask(
      key: 'play',
      title: 'Interactive Play',
      subtitle: playSubtitle,
      iconKey: 'pets',
    ),
    const DailyTask(
      key: 'litter',
      title: 'Litter Box',
      subtitle: 'Scoop & check — clean is happy',
      iconKey: 'shower',
    ),
    DailyTask(
      key: 'water',
      title: 'Fresh Water',
      subtitle: ageBand == 'senior'
          ? 'Extra important for kidney health'
          : 'Refill water bowl or fountain',
      iconKey: 'water_drop',
    ),
    const DailyTask(
      key: 'groom',
      title: 'Grooming',
      subtitle: 'Brush coat + nail check',
      iconKey: 'brush',
    ),
  ];
}

List<DailyTask> _birdTasks(String ageBand) {
  return [
    DailyTask(
      key: 'feed',
      title: 'Feeding',
      subtitle: ageBand == 'puppy_kitten'
          ? 'Frequent feedings — young birds need more'
          : 'Fresh seed/pellets + produce',
      iconKey: 'restaurant',
    ),
    const DailyTask(
      key: 'social',
      title: 'Social Time',
      subtitle: '1–2 hours out of cage for bonding',
      iconKey: 'pets',
    ),
    const DailyTask(
      key: 'cage',
      title: 'Cage Cleaning',
      subtitle: 'Replace liner + wipe perches',
      iconKey: 'shower',
    ),
    const DailyTask(
      key: 'forage',
      title: 'Foraging Enrichment',
      subtitle: 'Puzzle toys or hidden treats',
      iconKey: 'pets',
    ),
    const DailyTask(
      key: 'water',
      title: 'Fresh Water',
      subtitle: 'Clean & refill water dish',
      iconKey: 'water_drop',
    ),
  ];
}

List<DailyTask> _rabbitTasks(String ageBand) {
  return [
    const DailyTask(
      key: 'hay',
      title: 'Hay Supply',
      subtitle: 'Unlimited timothy hay — always available',
      iconKey: 'restaurant',
    ),
    DailyTask(
      key: 'exercise',
      title: 'Free Roam Time',
      subtitle: ageBand == 'senior'
          ? '1.5+ hours — gentle exercise'
          : '3–4 hours minimum in safe area',
      iconKey: 'pets',
    ),
    const DailyTask(
      key: 'veggies',
      title: 'Fresh Greens',
      subtitle: 'Leafy vegetables — varied daily',
      iconKey: 'restaurant',
    ),
    const DailyTask(
      key: 'litter',
      title: 'Litter Box',
      subtitle: 'Clean daily for hygiene',
      iconKey: 'shower',
    ),
    const DailyTask(
      key: 'water',
      title: 'Fresh Water',
      subtitle: 'Clean bowl or bottle',
      iconKey: 'water_drop',
    ),
  ];
}

/// Aligns a stored [tasks] list with a new [template] by key, preserving [done] state.
List<DailyTask> reconcileTaskProgress(
  List<DailyTask> stored,
  List<DailyTask> template,
) {
  final byKey = {for (final t in stored) t.key: t};
  return [
    for (final t in template)
      (byKey[t.key] ?? t).copyWith(
        title: t.title,
        subtitle: t.subtitle,
        iconKey: t.iconKey,
      )
  ];
}

List<PetCareLog> applyOnboardingToCareLogs(
  List<PetCareLog> logs,
  PetCareOnboarding? onboarding,
) {
  if (onboarding == null) return logs;
  final data = onboarding.data;
  final template = dailyTaskTemplateFromOnboardingData(data);
  return [
    for (final log in logs)
      log.copyWith(
        tasks: reconcileTaskProgress(log.tasks, template),
      ),
  ];
}

String careFeedingHint(Map<String, dynamic> data) {
  final diet = data[PetCareOnboarding.kDiet] as String? ?? 'mixed';
  final species = data[PetCareOnboarding.kSpecies] as String? ?? 'Dog';
  final ageBand = data[PetCareOnboarding.kAgeBand] as String? ?? 'adult';

  final speciesHint = switch (species.toLowerCase()) {
    'cat' => ageBand == 'senior'
        ? 'Senior cats need higher moisture content for kidney health.'
        : 'Cats need taurine-rich protein — check your food labels.',
    'bird' =>
      'Balance seed/pellet ratio with fresh fruits & vegetables daily.',
    'rabbit' =>
      'Hay should be 80% of diet. Limit pellets to ¼ cup per 5 lbs.',
    _ => null,
  };

  if (speciesHint != null) return speciesHint;

  return switch (diet) {
    'raw' => 'If feeding raw, keep bowls and surfaces clean between meals.',
    'home_cooked' =>
      "Balance home meals with your vet's guidance for micronutrients.",
    'prescription' =>
      'Stick to the prescribed schedule—consistency helps monitoring.',
    _ => 'Measure portions; adjust with your vet if weight changes.',
  };
}

/// Generates a personalized recommendation summary based on onboarding data.
String careRecommendationSummary(Map<String, dynamic> data) {
  final species = data[PetCareOnboarding.kSpecies] as String? ?? 'Dog';
  final ageBand = data[PetCareOnboarding.kAgeBand] as String? ?? 'adult';
  final activity = data[PetCareOnboarding.kActivity] as String? ?? 'moderate';
  final healthFocus =
      data[PetCareOnboarding.kHealthFocus] as String? ?? 'none';

  final exerciseMin = CareCalculator.dailyExerciseMinutes(
    species: species,
    ageBand: ageBand,
    activity: activity,
  );

  final healthTip = switch (healthFocus) {
    'weight' => ' Focus on portion control and regular weigh-ins.',
    'allergy' => ' Track ingredients carefully and watch for reactions.',
    'dental' => ' Prioritize dental care — brush or use dental chews daily.',
    'joint' => ' Keep exercise low-impact and consider joint supplements.',
    _ => '',
  };

  final ageTip = switch (ageBand) {
    'puppy_kitten' => 'Growing fast! More frequent meals and gentle exercise.',
    'senior' => 'Gentle care is key. Monitor weight and joint health closely.',
    _ => 'Keep a consistent routine for optimal health.',
  };

  return '$ageTip Aim for ~$exerciseMin minutes of daily activity.$healthTip';
}
