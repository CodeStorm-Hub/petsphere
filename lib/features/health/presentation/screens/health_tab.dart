


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:petfolio/features/health/presentation/controllers/allergy_controller.dart';
import 'package:petfolio/features/health/presentation/controllers/appointment_controller.dart';
import 'package:petfolio/features/health/presentation/controllers/dental_controller.dart';
import 'package:petfolio/features/health/presentation/controllers/medication_controller.dart';
import 'package:petfolio/features/health/presentation/controllers/parasite_controller.dart';
import 'package:petfolio/features/health/presentation/controllers/vaccination_controller.dart';
import 'package:petfolio/features/health/presentation/controllers/vitals_controller.dart';

import 'package:petfolio/core/theme/app_theme.dart';
import 'package:petfolio/core/widgets/petfolio_widgets.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:petfolio/features/health/presentation/controllers/symptom_controller.dart';
import 'package:petfolio/features/health/data/models/pet_health_extended_models.dart';
import 'package:petfolio/features/health/data/models/pet_health_models.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Helpers
// ─────────────────────────────────────────────────────────────────────────────

/// Returns a human-readable relative-time string for [date] (e.g. "38d ago").
String _relativeTime(DateTime date) {
  final days = DateTime.now().difference(date).inDays;
  if (days == 0) return 'today';
  if (days == 1) return '1d ago';
  if (days < 30) return '${days}d ago';
  final months = (days / 30.44).round();
  if (months < 12) return '${months}mo ago';
  final years = (days / 365.25).round();
  return '${years}yr ago';
}

class HealthTab extends ConsumerWidget {
  const HealthTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final activePet = ref.watch(activePetProvider);
    final symptomState = ref.watch(symptomProvider);

    if (activePet == null) {
      return Center(
        child: Text(
          'No pet selected.',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _HealthOverviewCard(
          petName: activePet.name,
        ),
        const SizedBox(height: 16),
        const _VitalsSection(),
        const SizedBox(height: 12),
        _MedicationsSection(petId: activePet.id),
        const SizedBox(height: 12),
        _AppointmentsSection(petId: activePet.id),
        const SizedBox(height: 12),
        _VaccinationsSection(petId: activePet.id),
        const SizedBox(height: 12),
        _ParasiteSection(petId: activePet.id),
        const SizedBox(height: 12),
        _DentalSection(petId: activePet.id),
        const SizedBox(height: 12),
        _AllergySection(petId: activePet.id),
        const SizedBox(height: 12),
        _SymptomsSection(
          active: symptomState.activeSymptoms,
          resolved: symptomState.resolvedSymptoms,
          petId: activePet.id,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Health Overview Card
// ─────────────────────────────────────────────────────────────────────────────

class _HealthOverviewCard extends ConsumerWidget {

  const _HealthOverviewCard({
    required this.petName,
  });
  final String petName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symptomState = ref.watch(symptomProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final dueMeds = ref.watch(medicationProvider).todayDoses.where((d) => d.isOverdue).length;
    final nextAppt = ref.watch(appointmentProvider).upcomingAppointments.isNotEmpty
        ? ref.watch(appointmentProvider).upcomingAppointments.first
        : null;
    final overdueP = ref.watch(parasiteProvider).overdue;
    final activeSymps = symptomState.activeSymptoms.length;

    final chips = <_AlertChip>[];
    if (dueMeds > 0) {
      chips.add(
        _AlertChip(
          label: '$dueMeds med${dueMeds > 1 ? 's' : ''} due today',
          color: colorScheme.primary,
        ),
      );
    }
    if (nextAppt != null) {
      final days = nextAppt.daysUntil;
      chips.add(
        _AlertChip(
          label:
              'Vet in ${days < 1 ? 'today' : '$days day${days == 1 ? '' : 's'}'}',
          color: colorScheme.secondary,
        ),
      );
    }
    if (overdueP.isNotEmpty) {
      chips.add(
        _AlertChip(label: 'Parasite overdue', color: colorScheme.error),
      );
    }
    if (activeSymps > 0) {
      chips.add(
        _AlertChip(
          label: '$activeSymps active symptom${activeSymps > 1 ? 's' : ''}',
          color: colorScheme.primary,
        ),
      );
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "$petName's Health",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (chips.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle,
                        size: 14,
                        color: colorScheme.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'All clear',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.secondary,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 6, children: chips),
          ],
        ],
      ),
    );
  }
}

class _AlertChip extends StatelessWidget {

  const _AlertChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    //     final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(AppTheme.pillRadius),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section card wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.onAdd,
    this.addTooltip,
    this.emptyState,
  });
  final String title;
  final IconData icon;
  final VoidCallback? onAdd;
  final String? addTooltip;
  final List<Widget> children;
  final Widget? emptyState;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (onAdd != null)
                Semantics(
                  label: addTooltip ?? 'Add',
                  button: true,
                  child: GestureDetector(
                    onTap: onAdd,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withAlpha(20),
                        borderRadius: BorderRadius.circular(
                          AppTheme.inputRadius,
                        ),
                        border: Border.all(
                          color: colorScheme.primary.withAlpha(60),
                        ),
                      ),
                      child: Icon(
                        Icons.add,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          if (children.isEmpty && emptyState != null) ...[
            const SizedBox(height: 16),
            emptyState!,
          ] else ...[
            const SizedBox(height: 12),
            ...children,
          ],
        ],
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {

  const _EmptyHint({required this.text, required this.icon});
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: colorScheme.outlineVariant, size: 28),
            const SizedBox(height: 6),
            Text(
              text,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontSize: 13,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. Vitals & Weight
// ─────────────────────────────────────────────────────────────────────────────

class _VitalsSection extends ConsumerStatefulWidget {
  const _VitalsSection();

  @override
  ConsumerState<_VitalsSection> createState() => _VitalsSectionState();
}

class _VitalsSectionState extends ConsumerState<_VitalsSection> {
  int _rangeDays = 7;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final vitalsState = ref.watch(vitalsProvider);
    final cutoff = DateTime.now().subtract(Duration(days: _rangeDays));
    final weights = vitalsState.weightLogs
        .where((w) => w.logDate.isAfter(cutoff))
        .toList();
    final latest = weights.isNotEmpty ? weights.last : null;
    final prior = weights.length >= 2 ? weights[weights.length - 2] : null;
    final delta = (latest != null && prior != null)
        ? latest.weightLbs - prior.weightLbs
        : null;

    return _SectionCard(
      title: 'Vitals & Weight',
      icon: Icons.monitor_weight_outlined,
      onAdd: () => _showLogWeightSheet(context),
      addTooltip: 'Log weight',
      emptyState: const _EmptyHint(
        text: 'No weight logs yet',
        icon: Icons.monitor_weight_outlined,
      ),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    latest == null
                        ? '— lbs'
                        : '${latest.weightLbs.toStringAsFixed(1)} ${latest.unit}',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  if (delta != null)
                    Row(
                      children: [
                        Icon(
                          delta >= 0
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 16,
                          color: delta > 0
                              ? colorScheme.error
                              : colorScheme.secondary,
                        ),
                        Text(
                          '${delta.abs().toStringAsFixed(1)} ${latest!.unit} vs prior',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      'Tap + to log first weight',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (latest?.bcsScore != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withAlpha(30),
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                  border: Border.all(
                    color: colorScheme.secondary.withAlpha(80),
                  ),
                ),
                child: Text(
                  'BCS ${latest!.bcsScore}/9 · ${latest.bcsLabel}',
                  style: TextStyle(color: colorScheme.secondary, fontSize: 11),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [7, 30, 90].map((d) {
            final selected = d == _rangeDays;
            return GestureDetector(
              onTap: () => setState(() => _rangeDays = d),
              child: Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.primary.withAlpha(15),
                  borderRadius: BorderRadius.circular(AppTheme.pillRadius),
                ),
                child: Text(
                  '${d}d',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                    color: selected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        if (weights.isEmpty)
          const _EmptyHint(
            text: 'Log your first weight to see trends',
            icon: Icons.show_chart,
          )
        else
          Semantics(
            label: 'Weight history chart for the last $_rangeDays days',
            child: SizedBox(
              height: 140,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: weights.asMap().entries.map((e) {
                        return FlSpot(
                          e.key.toDouble(),
                          e.value.weightLbs,
                        );
                      }).toList(),
                      isCurved: true,
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primary.withValues(alpha: 0.5),
                        ],
                      ),
                      barWidth: 4,
                      isStrokeCapRound: true,
                      dotData: FlDotData(
                        getDotPainter: (spot, percent, barData, index) =>
                            FlDotCirclePainter(
                              radius: 4,
                              color: colorScheme.primary,
                              strokeWidth: 2,
                              strokeColor: colorScheme.surface,
                            ),
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colorScheme.primary.withValues(alpha: 0.2),
                            colorScheme.primary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipColor: (touchedSpot) => colorScheme.surface,
                      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                        return touchedBarSpots.map((barSpot) {
                          final date = weights[barSpot.x.toInt()].logDate;
                          return LineTooltipItem(
                            '${barSpot.y.toStringAsFixed(1)} lbs\n${DateFormat('MMM d').format(date)}',
                            TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showLogWeightSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final weightCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    int? selectedBcs;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setS) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log Weight',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: weightCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Weight (lbs)',
                      labelStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Body Condition Score (optional)',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    children: List.generate(9, (i) {
                      final score = i + 1;
                      final sel = selectedBcs == score;
                      return GestureDetector(
                        onTap: () => setS(() => selectedBcs = score),
                        child: Container(
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: sel
                                ? colorScheme.primary
                                : colorScheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: sel
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant,
                            ),
                          ),
                          child: Text(
                            '$score',
                            style: TextStyle(
                              color: sel
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurfaceVariant,
                              fontWeight: sel
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesCtrl,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Notes (optional)',
                      labelStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        final w = double.tryParse(weightCtrl.text);
                        if (w == null) return;
                        Navigator.pop(ctx);
                        ref
                            .read(vitalsProvider.notifier)
                            .logWeight(
                              weight: w,
                              notes: notesCtrl.text.isEmpty
                                  ? null
                                  : notesCtrl.text,
                              bcsScore: selectedBcs,
                            );
                      },
                      child: const Text('Save Weight'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Medications
// ─────────────────────────────────────────────────────────────────────────────

class _MedicationsSection extends ConsumerWidget {

  const _MedicationsSection({required this.petId});
  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medicationState = ref.watch(medicationProvider);
    final medications = medicationState.activeMedications;
    //     final colorScheme = Theme.of(context).colorScheme;
    

    return _SectionCard(
      title: 'Medications',
      icon: Icons.medication_outlined,
      onAdd: () => _showAddMedSheet(context, ref),
      addTooltip: 'Add medication',
      emptyState: const _EmptyHint(
        text: 'No active medications',
        icon: Icons.medication_outlined,
      ),
      children: medications.map((med) {
        final dose = medicationState.todayDoseFor(med.id);
        return _MedicationRow(
          med: med,
          dose: dose,
          onGive: dose != null && !dose.isGiven
              ? () => ref.read(medicationProvider.notifier).markDoseGiven(dose)
              : null,
          onSkip: dose != null && !dose.skipped
              ? () => ref.read(medicationProvider.notifier).skipDose(dose)
              : null,
        );
      }).toList(),
    );
  }

  void _showAddMedSheet(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final nameCtrl = TextEditingController();
    final doseCtrl = TextEditingController();
    final purposeCtrl = TextEditingController();
    var freq = 'once_daily';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Medication',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _sheetTextField(context, nameCtrl, 'Medication name'),
                const SizedBox(height: 10),
                _sheetTextField(context, doseCtrl, 'Dose (e.g. 16mg, 1 pill)'),
                const SizedBox(height: 10),
                _sheetTextField(context, purposeCtrl, 'Purpose (optional)'),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: freq,
                  dropdownColor: colorScheme.surfaceContainer,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Frequency',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: colorScheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'once_daily',
                      child: Text('Once daily'),
                    ),
                    DropdownMenuItem(
                      value: 'twice_daily',
                      child: Text('Twice daily'),
                    ),
                    DropdownMenuItem(
                      value: 'three_times_daily',
                      child: Text('3× daily'),
                    ),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly')),
                    DropdownMenuItem(value: 'monthly', child: Text('Monthly')),
                    DropdownMenuItem(
                      value: 'as_needed',
                      child: Text('As needed'),
                    ),
                  ],
                  onChanged: (v) => setS(() => freq = v ?? freq),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (nameCtrl.text.isEmpty) return;
                      Navigator.pop(ctx);
                      ref
                          .read(medicationProvider.notifier)
                          .addMedication(
                            PetMedication(
                              id: '',
                              petId: petId,
                              name: nameCtrl.text.trim(),
                              dose: doseCtrl.text.isEmpty
                                  ? null
                                  : doseCtrl.text.trim(),
                              frequency: freq,
                              startDate: DateTime.now(),
                              purpose: purposeCtrl.text.isEmpty
                                  ? null
                                  : purposeCtrl.text.trim(),
                              status: 'active',
                            ),
                          );
                    },
                    child: const Text('Add Medication'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MedicationRow extends StatelessWidget {

  const _MedicationRow({
    required this.med,
    this.dose,
    this.onGive,
    this.onSkip,
  });
  final PetMedication med;
  final MedicationDose? dose;
  final VoidCallback? onGive;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.medication,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${med.name}${med.dose != null ? ' · ${med.dose}' : ''}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: med.statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    med.statusLabel,
                    style: TextStyle(fontSize: 11, color: med.statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              med.frequencyLabel,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (dose != null) ...[
              const SizedBox(height: 8),
              _DoseStatusRow(dose: dose!, onGive: onGive, onSkip: onSkip),
            ],
          ],
        ),
      ),
    );
  }
}

class _DoseStatusRow extends StatelessWidget {

  const _DoseStatusRow({required this.dose, this.onGive, this.onSkip});
  final MedicationDose dose;
  final VoidCallback? onGive;
  final VoidCallback? onSkip;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (dose.isGiven) {
      return Row(
        children: [
          Icon(Icons.check_circle, size: 14, color: colorScheme.secondary),
          const SizedBox(width: 4),
          Text(
            'Given ${dose.givenAt != null ? DateFormat('h:mm a').format(dose.givenAt!) : ''}',
            style: TextStyle(fontSize: 12, color: colorScheme.secondary),
          ),
        ],
      );
    }
    if (dose.skipped) {
      return Row(
        children: [
          Icon(Icons.cancel, size: 14, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            'Skipped',
            style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
          ),
        ],
      );
    }
    return Row(
      children: [
        Icon(
          dose.isOverdue ? Icons.warning : Icons.schedule,
          size: 14,
          color: dose.isOverdue
              ? colorScheme.primary
              : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 4),
        Text(
          dose.isOverdue ? 'Overdue' : 'Due today',
          style: TextStyle(
            fontSize: 12,
            color: dose.isOverdue
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        if (onGive != null)
          TextButton(
            onPressed: onGive,
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.secondary,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Given', style: TextStyle(fontSize: 12)),
          ),
        if (onSkip != null)
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurfaceVariant,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Skip', style: TextStyle(fontSize: 12)),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. Vet Appointments
// ─────────────────────────────────────────────────────────────────────────────

class _AppointmentsSection extends ConsumerWidget {

  const _AppointmentsSection({required this.petId});
  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentProvider).upcomingAppointments;
    //     final colorScheme = Theme.of(context).colorScheme;
    return _SectionCard(
      title: 'Vet Appointments',
      icon: Icons.calendar_today_outlined,
      onAdd: () => _showAddApptSheet(context, ref),
      addTooltip: 'Add appointment',
      emptyState: const _EmptyHint(
        text: 'No upcoming appointments',
        icon: Icons.calendar_today_outlined,
      ),
      children: appointments
          .map((a) => _AppointmentCard(appt: a, ref: ref))
          .toList(),
    );
  }

  void _showAddApptSheet(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final titleCtrl = TextEditingController();
    final doctorCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    var date = DateTime.now().add(const Duration(days: 7));
    var type = 'routine';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Add Appointment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sheetTextField(
                    context,
                    titleCtrl,
                    'Title (e.g. Annual Checkup)',
                  ),
                  const SizedBox(height: 10),
                  _sheetTextField(context, doctorCtrl, 'Doctor (optional)'),
                  const SizedBox(height: 10),
                  _sheetTextField(context, locCtrl, 'Location (optional)'),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    dropdownColor: colorScheme.surfaceContainer,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Type',
                      labelStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'routine',
                        child: Text('Routine'),
                      ),
                      DropdownMenuItem(
                        value: 'emergency',
                        child: Text('Emergency'),
                      ),
                      DropdownMenuItem(
                        value: 'specialist',
                        child: Text('Specialist'),
                      ),
                      DropdownMenuItem(value: 'dental', child: Text('Dental')),
                      DropdownMenuItem(
                        value: 'surgery',
                        child: Text('Surgery'),
                      ),
                      DropdownMenuItem(
                        value: 'follow_up',
                        child: Text('Follow-up'),
                      ),
                    ],
                    onChanged: (v) => setS(() => type = v ?? type),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Date: ${DateFormat('MMM d, yyyy').format(date)}',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    trailing: Icon(
                      Icons.edit_calendar,
                      color: colorScheme.primary,
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: date,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 730)),
                      );
                      if (picked != null) setS(() => date = picked);
                    },
                  ),
                  _sheetTextField(context, notesCtrl, 'Notes (optional)'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (titleCtrl.text.isEmpty) return;
                        Navigator.pop(ctx);
                        ref
                            .read(appointmentProvider.notifier)
                            .upsertAppointment(
                              PetVetAppointment(
                                id: '',
                                petId: petId,
                                title: titleCtrl.text.trim(),
                                doctor: doctorCtrl.text.isEmpty
                                    ? null
                                    : doctorCtrl.text.trim(),
                                scheduledAt: date,
                                notes: notesCtrl.text.isEmpty
                                    ? null
                                    : notesCtrl.text.trim(),

                                appointmentType: type,
                                location: locCtrl.text.isEmpty
                                    ? null
                                    : locCtrl.text.trim(),
                              ),
                            );
                      },
                      child: const Text('Save Appointment'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {

  const _AppointmentCard({required this.appt, required this.ref});
  final PetVetAppointment appt;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final days = appt.daysUntil;
    final daysStr = days < 0
        ? 'past'
        : days == 0
        ? 'today'
        : 'in $days day${days == 1 ? '' : 's'}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    appt.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    appt.appointmentTypeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 12,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('MMM d, yyyy').format(appt.scheduledAt)} · $daysStr',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (appt.doctor != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.person,
                    size: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    appt.doctor!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
            if (appt.location != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    appt.location!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. Vaccinations
// ─────────────────────────────────────────────────────────────────────────────

class _VaccinationsSection extends ConsumerWidget {

  const _VaccinationsSection({required this.petId});
  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaccinations = ref.watch(vaccinationProvider).vaccinations;
    final colorScheme = Theme.of(context).colorScheme;
    return _SectionCard(
      title: 'Vaccinations',
      icon: Icons.vaccines_outlined,
      onAdd: () => _showAddVaxSheet(context, ref),
      addTooltip: 'Add vaccination',
      emptyState: const _EmptyHint(
        text: 'No vaccination records',
        icon: Icons.vaccines_outlined,
      ),
      children: vaccinations.map((v) {
        final completed = v.isCompleted;
        final dueDate = v.nextDueDate ?? v.scheduledFor;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                completed ? Icons.check_circle : Icons.circle,
                size: 14,
                color: completed
                    ? colorScheme.secondary
                    : (v.isDueSoon
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  v.vaccineName,
                  style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                ),
              ),
              if (dueDate != null)
                Text(
                  completed
                      ? 'Done ${DateFormat('MMM yyyy').format(v.completedOn ?? dueDate)}'
                      : 'Due ${DateFormat('MMM yyyy').format(dueDate)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: completed
                        ? colorScheme.onSurfaceVariant
                        : (v.isDueSoon
                              ? colorScheme.primary
                              : colorScheme.onSurfaceVariant),
                  ),
                ),
              if (!completed) ...[
                const SizedBox(width: 8),
                GestureDetector(
                    onTap: () async {
                    await ref
                        .read(vaccinationProvider.notifier)
                        .markComplete(v.id);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.secondary.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Done',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showAddVaxSheet(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final nameCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime? dueDate;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Vaccination',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _sheetTextField(context, nameCtrl, 'Vaccine name'),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    dueDate == null
                        ? 'Due date (optional)'
                        : 'Due: ${DateFormat('MMM d, yyyy').format(dueDate!)}',
                    style: TextStyle(
                      color: dueDate == null
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                    ),
                  ),
                  trailing: Icon(
                    Icons.edit_calendar,
                    color: colorScheme.primary,
                  ),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: ctx,
                      initialDate: DateTime.now().add(const Duration(days: 30)),
                      firstDate: DateTime.now().subtract(
                        const Duration(days: 365),
                      ),
                      lastDate: DateTime.now().add(const Duration(days: 1825)),
                    );
                    if (picked != null) setS(() => dueDate = picked);
                  },
                ),
                _sheetTextField(context, notesCtrl, 'Notes (optional)'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (nameCtrl.text.isEmpty) return;
                      Navigator.pop(ctx);
                      ref
                          .read(vaccinationProvider.notifier)
                          .upsertVaccination(
                            PetVaccination(
                              id: '',
                              petId: petId,
                              vaccineName: nameCtrl.text.trim(),
                              status: 'scheduled',
                              scheduledFor: dueDate,
                              nextDueDate: dueDate,
                              notes: notesCtrl.text.isEmpty
                                  ? null
                                  : notesCtrl.text.trim(),
                            ),
                          );
                    },
                    child: const Text('Add Vaccination'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Parasite Prevention
// ─────────────────────────────────────────────────────────────────────────────

class _ParasiteSection extends ConsumerWidget {

  const _ParasiteSection({required this.petId});
  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = ref.watch(parasiteProvider).latestPerType;
    final colorScheme = Theme.of(context).colorScheme;
    return _SectionCard(
      title: 'Parasite Prevention',
      icon: Icons.bug_report_outlined,
      onAdd: () => _showLogSheet(context, ref),
      addTooltip: 'Log treatment',
      emptyState: const _EmptyHint(
        text: 'No parasite prevention logs',
        icon: Icons.bug_report_outlined,
      ),
      children: entries.map((e) {
        final daysUntil = e.daysUntilDue;
        final label = e.isOverdue
            ? 'Overdue'
            : daysUntil != null
            ? 'Due in $daysUntil day${daysUntil == 1 ? '' : 's'}'
            : 'No next date';
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      e.productName,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${e.productTypeLabel} · ${_relativeTime(e.administeredOn)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: e.urgencyColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: e.urgencyColor.withAlpha(80)),
                ),
                child: Text(
                  label,
                  style: TextStyle(fontSize: 11, color: e.urgencyColor),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showLogSheet(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final productCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    var type = 'flea_tick';
    var administered = DateTime.now();
    DateTime? nextDue;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Log Treatment',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _sheetTextField(
                    context,
                    productCtrl,
                    'Product name (e.g. NexGard)',
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: type,
                    dropdownColor: colorScheme.surfaceContainer,
                    style: TextStyle(color: colorScheme.onSurface),
                    decoration: InputDecoration(
                      labelText: 'Type',
                      labelStyle: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: colorScheme.surfaceContainer,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'flea', child: Text('Flea')),
                      DropdownMenuItem(value: 'tick', child: Text('Tick')),
                      DropdownMenuItem(
                        value: 'flea_tick',
                        child: Text('Flea & Tick'),
                      ),
                      DropdownMenuItem(
                        value: 'heartworm',
                        child: Text('Heartworm'),
                      ),
                      DropdownMenuItem(
                        value: 'dewormer',
                        child: Text('Dewormer'),
                      ),
                      DropdownMenuItem(value: 'other', child: Text('Other')),
                    ],
                    onChanged: (v) => setS(() => type = v ?? type),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Administered: ${DateFormat('MMM d, yyyy').format(administered)}',
                      style: TextStyle(color: colorScheme.onSurface),
                    ),
                    trailing: Icon(
                      Icons.edit_calendar,
                      color: colorScheme.primary,
                    ),
                    onTap: () async {
                      final p = await showDatePicker(
                        context: ctx,
                        initialDate: administered,
                        firstDate: DateTime.now().subtract(
                          const Duration(days: 365),
                        ),
                        lastDate: DateTime.now(),
                      );
                      if (p != null) setS(() => administered = p);
                    },
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      nextDue == null
                          ? 'Next due date (optional)'
                          : 'Next due: ${DateFormat('MMM d, yyyy').format(nextDue!)}',
                      style: TextStyle(
                        color: nextDue == null
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                    ),
                    trailing: Icon(
                      Icons.edit_calendar,
                      color: colorScheme.primary,
                    ),
                    onTap: () async {
                      final p = await showDatePicker(
                        context: ctx,
                        initialDate: administered.add(const Duration(days: 30)),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (p != null) setS(() => nextDue = p);
                    },
                  ),
                  _sheetTextField(context, notesCtrl, 'Notes (optional)'),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        if (productCtrl.text.isEmpty) return;
                        Navigator.pop(ctx);
                        ref
                            .read(parasiteProvider.notifier)
                            .logTreatment(
                              ParasitePrevention(
                                id: '',
                                petId: petId,
                                productName: productCtrl.text.trim(),
                                productType: type,
                                administeredOn: administered,
                                nextDueDate: nextDue,
                                notes: notesCtrl.text.isEmpty
                                    ? null
                                    : notesCtrl.text.trim(),
                              ),
                            );
                      },
                      child: const Text('Log Treatment'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. Dental Health
// ─────────────────────────────────────────────────────────────────────────────

class _DentalSection extends ConsumerWidget {

  const _DentalSection({required this.petId});
  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final logs = ref.watch(dentalProvider).logs;
    final lastBrush = logs
        .where((l) => l.cleaningType == 'home_brushing')
        .map((l) => l.logDate)
        .fold<DateTime?>(
          null,
          (best, d) => best == null || d.isAfter(best) ? d : best,
        );

    final lastProf = logs
        .where((l) => l.cleaningType == 'professional_cleaning')
        .map((l) => l.logDate)
        .fold<DateTime?>(
          null,
          (best, d) => best == null || d.isAfter(best) ? d : best,
        );

    String ago(DateTime? d) {
      if (d == null) return 'Never';
      final days = DateTime.now().difference(d).inDays;
      if (days == 0) return 'Today';
      if (days == 1) return 'Yesterday';
      return '$days days ago';
    }

    return _SectionCard(
      title: 'Dental Health',
      icon: Icons.sentiment_satisfied_alt,
      onAdd: () => _showLogSheet(context, ref),
      addTooltip: 'Log dental care',
      emptyState: const _EmptyHint(
        text: 'No dental logs yet',
        icon: Icons.sentiment_satisfied_alt,
      ),
      children: [
        _DentalRow(
          label: 'Last home brushing',
          value: ago(lastBrush),
          icon: Icons.brush,
        ),
        const SizedBox(height: 6),
        _DentalRow(
          label: 'Last professional cleaning',
          value: ago(lastProf),
          icon: Icons.medical_services,
        ),
        if (logs.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...logs
              .take(3)
              .map(
                (l) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        l.cleaningIcon,
                        size: 12,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        l.cleaningTypeLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        DateFormat('MMM d').format(l.logDate),
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ],
    );
  }

  void _showLogSheet(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    var type = 'home_brushing';
    final notesCtrl = TextEditingController();
    final logDate = DateTime.now();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log Dental Care',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  dropdownColor: colorScheme.surfaceContainer,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: colorScheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'home_brushing',
                      child: Text('Home Brushing'),
                    ),
                    DropdownMenuItem(
                      value: 'dental_chew',
                      child: Text('Dental Chew'),
                    ),
                    DropdownMenuItem(
                      value: 'professional_cleaning',
                      child: Text('Professional Cleaning'),
                    ),
                    DropdownMenuItem(
                      value: 'water_additive',
                      child: Text('Water Additive'),
                    ),
                  ],
                  onChanged: (v) => setS(() => type = v ?? type),
                ),
                const SizedBox(height: 10),
                _sheetTextField(context, notesCtrl, 'Notes (optional)'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ref
                          .read(dentalProvider.notifier)
                          .logDental(
                            DentalLog(
                              id: '',
                              petId: petId,
                              logDate: logDate,
                              cleaningType: type,
                              notes: notesCtrl.text.isEmpty
                                  ? null
                                  : notesCtrl.text.trim(),
                            ),
                          );
                    },
                    child: const Text('Log Dental Care'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _DentalRow extends StatelessWidget {

  const _DentalRow({
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
    return Row(
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. Allergies
// ─────────────────────────────────────────────────────────────────────────────

class _AllergySection extends ConsumerWidget {

  const _AllergySection({required this.petId});
  final String petId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //     final colorScheme = Theme.of(context).colorScheme;
    final allergies = ref.watch(allergyProvider).allergies;
    final activeAllergies = allergies.where((a) => a.isActive).toList();

    return _SectionCard(
      title: 'Allergies',
      icon: Icons.warning_amber_outlined,
      onAdd: () => _showAddSheet(context, ref),
      addTooltip: 'Add allergy',
      emptyState: const _EmptyHint(
        text: 'No known allergies recorded',
        icon: Icons.warning_amber_outlined,
      ),
      children: [
        if (activeAllergies.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: activeAllergies.map((a) {
              return GestureDetector(
                onLongPress: () => _confirmDelete(context, ref, a),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: a.severityColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: a.severityColor.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 8, color: a.severityColor),
                      const SizedBox(width: 5),
                      Text(
                        '${a.allergen} · ${a.allergenTypeLabel}',
                        style: TextStyle(fontSize: 12, color: a.severityColor),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, PetAllergy allergy) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
        title: Text(
          'Remove Allergy',
          style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
        ),
        content: Text(
          'Remove "${allergy.allergen}" from the allergy list?',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(allergyProvider.notifier).removeAllergy(allergy.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final allergenCtrl = TextEditingController();
    final reactionCtrl = TextEditingController();
    var allergenType = 'food';
    var severity = 'mild';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add Allergy',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                _sheetTextField(
                  context,
                  allergenCtrl,
                  'Allergen (e.g. Chicken, Grass)',
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: allergenType,
                  dropdownColor: colorScheme.surfaceContainer,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: colorScheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'food', child: Text('Food')),
                    DropdownMenuItem(
                      value: 'environmental',
                      child: Text('Environmental'),
                    ),
                    DropdownMenuItem(value: 'drug', child: Text('Drug')),
                    DropdownMenuItem(value: 'insect', child: Text('Insect')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) =>
                      setS(() => allergenType = v ?? allergenType),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: severity,
                  dropdownColor: colorScheme.surfaceContainer,
                  style: TextStyle(color: colorScheme.onSurface),
                  decoration: InputDecoration(
                    labelText: 'Severity',
                    labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    filled: true,
                    fillColor: colorScheme.surfaceContainer,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'mild', child: Text('Mild')),
                    DropdownMenuItem(
                      value: 'moderate',
                      child: Text('Moderate'),
                    ),
                    DropdownMenuItem(value: 'severe', child: Text('Severe')),
                    DropdownMenuItem(
                      value: 'life_threatening',
                      child: Text('Life-threatening'),
                    ),
                  ],
                  onChanged: (v) => setS(() => severity = v ?? severity),
                ),
                const SizedBox(height: 10),
                _sheetTextField(
                  context,
                  reactionCtrl,
                  'Reaction notes (optional)',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (allergenCtrl.text.isEmpty) return;
                      Navigator.pop(ctx);
                      ref
                          .read(allergyProvider.notifier)
                          .addAllergy(
                            PetAllergy(
                              id: '',
                              petId: petId,
                              allergen: allergenCtrl.text.trim(),
                              allergenType: allergenType,
                              severity: severity,
                              reaction: reactionCtrl.text.isEmpty
                                  ? null
                                  : reactionCtrl.text.trim(),
                              isActive: true,
                            ),
                          );
                    },
                    child: const Text('Add Allergy'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. Symptoms
// ─────────────────────────────────────────────────────────────────────────────

class _SymptomsSection extends ConsumerStatefulWidget {

  const _SymptomsSection({
    required this.active,
    required this.resolved,
    required this.petId,
  });
  final List<PetSymptom> active;
  final List<PetSymptom> resolved;
  final String petId;

  @override
  ConsumerState<_SymptomsSection> createState() => _SymptomsSectionState();
}

class _SymptomsSectionState extends ConsumerState<_SymptomsSection> {
  bool _showResolved = false;

  static const _kTypes = [
    'Lethargy',
    'Vomiting',
    'Diarrhea',
    'Loss of Appetite',
    'Itching',
    'Sneezing',
    'Limping',
    'Coughing',
    'Scratching',
    'Eye Discharge',
    'Ear Scratching',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _SectionCard(
      title: 'Symptoms',
      icon: Icons.medical_services_outlined,
      onAdd: () => _showLogSheet(context),
      addTooltip: 'Log symptom',
      emptyState: const _EmptyHint(
        text: 'No symptoms logged',
        icon: Icons.medical_services_outlined,
      ),
      children: [
        ...widget.active.map(
          (s) => _SymptomRow(
            symptom: s,
            onResolve: () =>
                ref.read(symptomProvider.notifier).resolveSymptom(s.id),
          ),
        ),
        if (widget.resolved.isNotEmpty) ...[
          GestureDetector(
            onTap: () => setState(() => _showResolved = !_showResolved),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Text(
                    '${widget.resolved.length} resolved',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _showResolved ? Icons.expand_less : Icons.expand_more,
                    size: 16,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
          if (_showResolved)
            ...widget.resolved.map(
              (s) => _SymptomRow(symptom: s),
            ),
        ],
      ],
    );
  }

  void _showLogSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    String? selectedType;
    var severity = 'mild';
    final notesCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Log Symptom',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _kTypes.map((t) {
                    final sel = selectedType == t;
                    return GestureDetector(
                      onTap: () => setS(() => selectedType = t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: sel
                              ? colorScheme.primary
                              : colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                          ),
                        ),
                        child: Text(
                          t,
                          style: TextStyle(
                            fontSize: 13,
                            color: sel
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                Text(
                  'Severity',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: ['mild', 'moderate', 'severe'].map((s) {
                    final sel = severity == s;
                    return GestureDetector(
                      onTap: () => setS(() => severity = s),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: sel
                              ? colorScheme.primary
                              : colorScheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: sel
                                ? colorScheme.primary
                                : colorScheme.outlineVariant,
                          ),
                        ),
                        child: Text(
                          s[0].toUpperCase() + s.substring(1),
                          style: TextStyle(
                            fontSize: 13,
                            color: sel
                                ? colorScheme.onPrimary
                                : colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                _sheetTextField(context, notesCtrl, 'Notes (optional)'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (selectedType == null) return;
                      Navigator.pop(ctx);
                      ref
                          .read(symptomProvider.notifier)
                          .addSymptom(
                            type: selectedType!,
                            severity: severity,
                            notes: notesCtrl.text.isEmpty
                                ? null
                                : notesCtrl.text.trim(),
                          );
                    },
                    child: const Text('Log Symptom'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SymptomRow extends StatelessWidget {

  const _SymptomRow({required this.symptom, this.onResolve});
  final PetSymptom symptom;
  final VoidCallback? onResolve;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: symptom.isResolved
                  ? colorScheme.onSurfaceVariant
                  : symptom.severityColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symptom.symptomType,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: symptom.isResolved
                        ? colorScheme.onSurfaceVariant
                        : colorScheme.onSurface,
                    decoration: symptom.isResolved
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                Text(
                  '${symptom.severityLabel} · ${DateFormat('MMM d').format(symptom.observedAt)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (onResolve != null)
            GestureDetector(
              onTap: onResolve,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Resolved',
                  style: TextStyle(fontSize: 11, color: colorScheme.secondary),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helper: text field for bottom sheets
// ─────────────────────────────────────────────────────────────────────────────

Widget _sheetTextField(
  BuildContext context,
  TextEditingController ctrl,
  String label,
) {
  return TextField(
    controller: ctrl,
    style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}
