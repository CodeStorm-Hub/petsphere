import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../controllers/pet_controller.dart';
import '../models/care_badge_model.dart';
import '../repositories/pet_care_repository.dart';
import '../utils/care_personalization.dart';

class PetCareOnboardingScreen extends ConsumerStatefulWidget {
  const PetCareOnboardingScreen({super.key, required this.petId});
  final String petId;

  @override
  ConsumerState<PetCareOnboardingScreen> createState() =>
      _PetCareOnboardingScreenState();
}

class _PetCareOnboardingScreenState
    extends ConsumerState<PetCareOnboardingScreen> {
  int _step = 0;
  static const _totalSteps = 4;

  // Step 1 — Basics
  String _species = 'Dog';
  String _ageBand = 'adult';
  String _gender = 'unknown';
  bool _isNeutered = false;

  // Step 2 — Personality & Lifestyle
  String _personality = 'moderate';
  String _activity = 'moderate';
  String _livingSituation = 'house_yard';
  bool _multiPet = false;

  // Step 3 — Health & Diet
  String _diet = 'mixed';
  String _healthFocus = 'none';
  final Set<String> _knownConditions = {};
  String _groomingFrequency = 'weekly';

  // Step 4 — Goals & Checklist
  String _primaryGoal = 'longevity';
  bool _useCustomChecklist = false;
  bool _saving = false;

  final _custom0T = TextEditingController();
  final _custom0S = TextEditingController();
  final _custom1T = TextEditingController();
  final _custom1S = TextEditingController();
  final _custom2T = TextEditingController();
  final _custom2S = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _custom0T.dispose();
    _custom0S.dispose();
    _custom1T.dispose();
    _custom1S.dispose();
    _custom2T.dispose();
    _custom2S.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final o = await petCareRepository.fetchOnboarding(widget.petId);
    if (!mounted) return;
    if (o == null) {
      setState(() => _fillCustomFields(const {}));
      return;
    }
    setState(() {
      _species = o.data[PetCareOnboarding.kSpecies] as String? ?? 'Dog';
      _ageBand = o.data[PetCareOnboarding.kAgeBand] as String? ?? 'adult';
      _activity = o.data[PetCareOnboarding.kActivity] as String? ?? 'moderate';
      _diet = o.data[PetCareOnboarding.kDiet] as String? ?? 'mixed';
      _healthFocus =
          o.data[PetCareOnboarding.kHealthFocus] as String? ?? 'none';
      _multiPet = o.data[PetCareOnboarding.kMultiPet] as bool? ?? false;
      _useCustomChecklist =
          o.data[PetCareOnboarding.kUseCustomChecklist] as bool? ?? false;
      _personality =
          o.data[PetCareOnboarding.kPersonality] as String? ?? 'moderate';
      _livingSituation =
          o.data[PetCareOnboarding.kLivingSituation] as String? ?? 'house_yard';
      _gender = o.data[PetCareOnboarding.kGender] as String? ?? 'unknown';
      _isNeutered = o.data[PetCareOnboarding.kIsNeutered] as bool? ?? false;
      _primaryGoal =
          o.data[PetCareOnboarding.kPrimaryGoal] as String? ?? 'longevity';
      _groomingFrequency =
          o.data[PetCareOnboarding.kGroomingFrequency] as String? ?? 'weekly';
      final conds = o.data[PetCareOnboarding.kKnownConditions];
      if (conds is List) {
        _knownConditions
          ..clear()
          ..addAll(conds.cast<String>());
      }
      _fillCustomFields(o.data);
    });
  }

  void _fillCustomFields(Map<String, dynamic> data) {
    final raw = data[PetCareOnboarding.kCustomTasks];
    final defaultsT = ['Morning walk', 'Medication / vitamins', 'Brush / play'];
    final defaultsS = ['Outdoors or indoor play', 'As vet directed', 'A few min counts'];
    if (raw is! List) {
      for (var i = 0; i < 3; i++) {
        [_custom0T, _custom1T, _custom2T][i].text = defaultsT[i];
        [_custom0S, _custom1S, _custom2S][i].text = defaultsS[i];
      }
      return;
    }
    for (var i = 0; i < 3; i++) {
      String? title, sub;
      if (i < raw.length && raw[i] is Map) {
        final m = Map<String, dynamic>.from(raw[i] as Map);
        title = m['title'] as String? ?? '';
        sub = m['subtitle'] as String? ?? '';
      }
      [_custom0T, _custom1T, _custom2T][i].text =
          title != null && title.isNotEmpty ? title : defaultsT[i];
      [_custom0S, _custom1S, _custom2S][i].text =
          sub != null && sub.isNotEmpty ? sub : defaultsS[i];
    }
  }

  List<Map<String, dynamic>>? _buildCustomTasksPayload() {
    if (!_useCustomChecklist) return null;
    final t = [_custom0T.text.trim(), _custom1T.text.trim(), _custom2T.text.trim()];
    final s = [_custom0S.text.trim(), _custom1S.text.trim(), _custom2S.text.trim()];
    if (t.every((e) => e.isEmpty)) return null;
    return [
      for (var i = 0; i < 3; i++)
        if (t[i].isNotEmpty)
          {'key': 'custom_$i', 'title': t[i], 'subtitle': s[i].isEmpty ? '—' : s[i], 'icon': 'pets'},
    ];
  }

  Map<String, dynamic> _toJson() {
    final custom = _buildCustomTasksPayload();
    return {
      PetCareOnboarding.kSpecies: _species,
      PetCareOnboarding.kAgeBand: _ageBand,
      PetCareOnboarding.kActivity: _activity,
      PetCareOnboarding.kDiet: _diet,
      PetCareOnboarding.kHealthFocus: _healthFocus,
      PetCareOnboarding.kMultiPet: _multiPet,
      PetCareOnboarding.kPersonality: _personality,
      PetCareOnboarding.kLivingSituation: _livingSituation,
      PetCareOnboarding.kGender: _gender,
      PetCareOnboarding.kIsNeutered: _isNeutered,
      PetCareOnboarding.kPrimaryGoal: _primaryGoal,
      PetCareOnboarding.kGroomingFrequency: _groomingFrequency,
      PetCareOnboarding.kKnownConditions: _knownConditions.toList(),
      PetCareOnboarding.kUseCustomChecklist:
          _useCustomChecklist && (custom != null && custom.isNotEmpty),
      if (custom != null && custom.isNotEmpty)
        PetCareOnboarding.kCustomTasks: custom,
    };
  }

  Future<void> _save({required bool done}) async {
    if (done && _useCustomChecklist) {
      final c = _buildCustomTasksPayload();
      if (c == null || c.isEmpty) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Add at least one custom task or turn off the switch.')),
        );
        return;
      }
    }
    setState(() => _saving = true);
    try {
      await petCareRepository.saveOnboarding(widget.petId, _toJson(), markComplete: done);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _next() {
    if (_step < _totalSteps - 1) setState(() => _step++);
  }

  void _prev() {
    if (_step > 0) setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);
    final stepTitles = [
      'About Your Pet',
      'Personality & Lifestyle',
      'Health & Diet',
      'Goals & Checklist',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(stepTitles[_step]),
        leading: _step > 0
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _prev)
            : null,
      ),
      body: Column(
        children: [
          // Progress indicator
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: List.generate(_totalSteps, (i) {
                final isActive = i <= _step;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < _totalSteps - 1 ? 4 : 0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: isActive ? colorScheme.primary : colorScheme.outlineVariant,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          Text(
            'Step ${_step + 1} of $_totalSteps',
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: ListView(
                key: ValueKey(_step),
                padding: const EdgeInsets.all(20),
                children: switch (_step) {
                  0 => _buildStep1(),
                  1 => _buildStep2(),
                  2 => _buildStep3(),
                  _ => _buildStep4(),
                },
              ),
            ),
          ),
          // Bottom navigation
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_step > 0)
                    OutlinedButton(onPressed: _prev, child: const Text('Back')),
                  const Spacer(),
                  if (_step < _totalSteps - 1)
                    FilledButton(onPressed: _next, child: const Text('Next')),
                  if (_step == _totalSteps - 1)
                    FilledButton(
                      onPressed: _saving ? null : () => _save(done: true),
                      child: _saving
                          ? const SizedBox(
                              width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Save & Finish'),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Basics ──────────────────────────────────────────────────────
  List<Widget> _buildStep1() {
    return [
      const _StepDescription('Tell us about your pet so we can personalize their care plan.'),
      const SizedBox(height: 16),
      const _Labeled('Species'),
      Wrap(
        spacing: 8,
        children: ['Dog', 'Cat', 'Bird', 'Rabbit', 'Other']
            .map((s) => ChoiceChip(
                  label: Text(s),
                  selected: _species == s,
                  onSelected: (_) => setState(() => _species = s),
                ))
            .toList(),
      ),
      const SizedBox(height: 16),
      const _Labeled('Life stage'),
      Wrap(
        spacing: 8,
        children: ['puppy_kitten', 'adult', 'senior']
            .map((s) => ChoiceChip(
                  label: Text(_label(s)),
                  selected: _ageBand == s,
                  onSelected: (_) => setState(() => _ageBand = s),
                ))
            .toList(),
      ),
      const SizedBox(height: 16),
      const _Labeled('Gender'),
      Wrap(
        spacing: 8,
        children: ['male', 'female', 'unknown']
            .map((s) => ChoiceChip(
                  label: Text(_label(s)),
                  selected: _gender == s,
                  onSelected: (_) => setState(() => _gender = s),
                ))
            .toList(),
      ),
      const SizedBox(height: 8),
      SwitchListTile(
        title: const Text('Spayed / Neutered'),
        subtitle: const Text('Affects calorie recommendations'),
        value: _isNeutered,
        onChanged: (v) => setState(() => _isNeutered = v),
      ),
    ];
  }

  // ── Step 2: Personality & Lifestyle ─────────────────────────────────────
  List<Widget> _buildStep2() {
    return [
      const _StepDescription('Understanding your pet\'s personality helps us suggest the right activities and routines.'),
      const SizedBox(height: 16),
      const _Labeled('Personality type'),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: ['high_energy', 'moderate', 'couch_potato', 'anxious', 'social', 'independent']
            .map((s) => ChoiceChip(
                  label: Text(_label(s)),
                  selected: _personality == s,
                  onSelected: (_) => setState(() => _personality = s),
                ))
            .toList(),
      ),
      const SizedBox(height: 16),
      const _Labeled('Activity level'),
      Wrap(
        spacing: 8,
        children: ['low', 'moderate', 'high']
            .map((s) => ChoiceChip(
                  label: Text(_label(s)),
                  selected: _activity == s,
                  onSelected: (_) => setState(() => _activity = s),
                ))
            .toList(),
      ),
      const SizedBox(height: 16),
      const _Labeled('Living situation'),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: ['apartment', 'house_yard', 'farm']
            .map((s) => ChoiceChip(
                  label: Text(_label(s)),
                  selected: _livingSituation == s,
                  onSelected: (_) => setState(() => _livingSituation = s),
                ))
            .toList(),
      ),
      const SizedBox(height: 8),
      SwitchListTile(
        title: const Text('Multiple pets in the home'),
        value: _multiPet,
        onChanged: (v) => setState(() => _multiPet = v),
      ),
    ];
  }

  // ── Step 3: Health & Diet ───────────────────────────────────────────────
  List<Widget> _buildStep3() {
    final conditionOptions = ['allergies', 'joints', 'dental', 'weight', 'heart', 'kidney', 'diabetes', 'anxiety'];
    return [
      const _StepDescription('Health details help us tailor feeding, medication reminders, and activity suggestions.'),
      const SizedBox(height: 16),
      const _Labeled('Diet style'),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: ['kibble', 'mixed', 'raw', 'home_cooked', 'prescription']
            .map((s) => ChoiceChip(
                  label: Text(_label(s)),
                  selected: _diet == s,
                  onSelected: (_) => setState(() => _diet = s),
                ))
            .toList(),
      ),
      const SizedBox(height: 16),
      const _Labeled('Health focus'),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: ['none', 'weight', 'allergy', 'dental', 'joint']
            .map((s) => ChoiceChip(
                  label: Text(_label(s)),
                  selected: _healthFocus == s,
                  onSelected: (_) => setState(() => _healthFocus = s),
                ))
            .toList(),
      ),
      const SizedBox(height: 16),
      const _Labeled('Known conditions (select all that apply)'),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: conditionOptions
            .map((c) => FilterChip(
                  label: Text(_label(c)),
                  selected: _knownConditions.contains(c),
                  onSelected: (sel) => setState(() {
                    sel ? _knownConditions.add(c) : _knownConditions.remove(c);
                  }),
                ))
            .toList(),
      ),
      const SizedBox(height: 16),
      const _Labeled('Grooming frequency'),
      Wrap(
        spacing: 8,
        children: ['daily', 'weekly', 'monthly']
            .map((s) => ChoiceChip(
                  label: Text(_label(s)),
                  selected: _groomingFrequency == s,
                  onSelected: (_) => setState(() => _groomingFrequency = s),
                ))
            .toList(),
      ),
    ];
  }

  // ── Step 4: Goals & Checklist ───────────────────────────────────────────
  List<Widget> _buildStep4() {
    final recSummary = careRecommendationSummary(_toJson());
    return [
      const _StepDescription('Set your primary care goal and customize your daily checklist.'),
      const SizedBox(height: 16),
      const _Labeled('Primary care goal'),
      Wrap(
        spacing: 8,
        runSpacing: 4,
        children: ['longevity', 'weight_mgmt', 'training', 'socialization']
            .map((s) => ChoiceChip(
                  label: Text(_label(s)),
                  selected: _primaryGoal == s,
                  onSelected: (_) => setState(() => _primaryGoal = s),
                ))
            .toList(),
      ),
      const SizedBox(height: 16),
      // Recommendation preview
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome, color: Theme.of(context).colorScheme.primary, size: 18),
                SizedBox(width: 8),
                Text('Your Personalized Plan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Text(recSummary, style: const TextStyle(fontSize: 13, height: 1.4)),
          ],
        ),
      ),
      const SizedBox(height: 16),
      SwitchListTile(
        title: const Text('Use my own daily checklist tasks'),
        subtitle: const Text('Override species defaults with custom tasks.'),
        value: _useCustomChecklist,
        onChanged: (v) => setState(() => _useCustomChecklist = v),
      ),
      if (_useCustomChecklist) ...[
        const SizedBox(height: 8),
        const _Labeled('Custom tasks'),
        for (var i = 0; i < 3; i++) ...[
          _CustomTaskRow(
            title: [_custom0T, _custom1T, _custom2T][i],
            subtitle: [_custom0S, _custom1S, _custom2S][i],
            index: i + 1,
          ),
          const SizedBox(height: 8),
        ],
      ],
    ];
  }

  String _label(String k) => switch (k) {
        'puppy_kitten' => 'Puppy / kitten / junior',
        'adult' => 'Adult',
        'senior' => 'Senior',
        'low' => 'Low (mostly indoor)',
        'moderate' => 'Moderate',
        'high' => 'High (working / very active)',
        'kibble' => 'Primarily kibble / dry',
        'mixed' => 'Mixed / wet + dry',
        'raw' => 'Raw (vet-guided)',
        'home_cooked' => 'Home-cooked / fresh',
        'prescription' => 'Prescription / therapeutic',
        'allergy' => 'Skin / allergies',
        'dental' => 'Dental / oral',
        'joint' => 'Joints / mobility',
        'weight' => 'Weight management',
        'none' => 'No specific focus',
        'high_energy' => '⚡ High energy',
        'couch_potato' => '😴 Couch potato',
        'anxious' => '😟 Anxious',
        'social' => '🤝 Social butterfly',
        'independent' => '🐱 Independent',
        'apartment' => '🏢 Apartment',
        'house_yard' => '🏡 House with yard',
        'farm' => '🌾 Farm / rural',
        'male' => 'Male',
        'female' => 'Female',
        'unknown' => 'Unknown',
        'daily' => 'Daily',
        'weekly' => 'Weekly',
        'monthly' => 'Monthly',
        'longevity' => '💚 Longevity & wellness',
        'weight_mgmt' => '⚖️ Weight management',
        'training' => '🎓 Training & behavior',
        'socialization' => '🐾 Socialization',
        'allergies' => 'Allergies',
        'joints' => 'Joint issues',
        'heart' => 'Heart',
        'kidney' => 'Kidney',
        'diabetes' => 'Diabetes',
        'anxiety' => 'Anxiety',
        _ => k,
      };
}

class _StepDescription extends StatelessWidget {
  const _StepDescription(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant),
      );
}

class _Labeled extends StatelessWidget {
  const _Labeled(this.t);
  final String t;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.onSurface)),
      );
}

class _CustomTaskRow extends StatelessWidget {
  const _CustomTaskRow({required this.title, required this.subtitle, required this.index});
  final TextEditingController title;
  final TextEditingController subtitle;
  final int index;
  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Text('$index.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Column(children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Task', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              TextField(controller: subtitle, decoration: const InputDecoration(labelText: 'Note (optional)', border: OutlineInputBorder())),
            ]),
          ),
        ],
      );
}

/// Opens onboarding for [activePet] if the route is used from a button.
void openCareOnboardingForActivePet(BuildContext context, WidgetRef ref) {
  final pet = ref.read(activePetProvider);
  if (pet == null) return;
  context.push('/pet_care_onboarding?petId=${pet.id}');
}
