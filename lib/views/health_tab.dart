import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../controllers/health_controller.dart';
import '../controllers/pet_care_controller.dart';
import '../controllers/pet_controller.dart';
import '../models/pet_health_extended_models.dart';
import '../models/pet_health_models.dart';
import '../theme/app_theme.dart';

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
    final activePet   = ref.watch(activePetProvider);
    final careState   = ref.watch(petCareProvider);
    final healthState = ref.watch(healthProvider);

    if (activePet == null) {
      return const Center(
        child: Text('No pet selected.',
            style: TextStyle(color: AppTheme.textSecondary)),
      );
    }

    if (healthState.isLoading && healthState.medications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        _HealthOverviewCard(
          petName:    activePet.name,
          careState:  careState,
          healthState:healthState,
        ),
        const SizedBox(height: 16),
        _VitalsSection(careState: careState),
        const SizedBox(height: 12),
        _MedicationsSection(
          medications: healthState.activeMedications,
          petId:       activePet.id,
        ),
        const SizedBox(height: 12),
        _AppointmentsSection(
          appointments: careState.upcomingAppointments,
          petId:        activePet.id,
        ),
        const SizedBox(height: 12),
        _VaccinationsSection(
          vaccinations: careState.vaccinations,
          petId:        activePet.id,
        ),
        const SizedBox(height: 12),
        _ParasiteSection(
          entries: healthState.latestPerType,
          petId:   activePet.id,
        ),
        const SizedBox(height: 12),
        _DentalSection(
          logs:  healthState.dentalLogs,
          petId: activePet.id,
        ),
        const SizedBox(height: 12),
        _AllergySection(
          allergies: healthState.allergies,
          petId:     activePet.id,
        ),
        const SizedBox(height: 12),
        _SymptomsSection(
          active:   careState.activeSymptoms,
          resolved: careState.resolvedSymptoms,
          petId:    activePet.id,
        ),
        const SizedBox(height: 32),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Health Overview Card
// ─────────────────────────────────────────────────────────────────────────────

class _HealthOverviewCard extends StatelessWidget {
  final String petName;
  final PetCareState careState;
  final HealthState healthState;

  const _HealthOverviewCard({
    required this.petName,
    required this.careState,
    required this.healthState,
  });

  @override
  Widget build(BuildContext context) {
    final dueMeds     = healthState.todayDoses.where((d) => d.isOverdue).length;
    final nextAppt    = careState.upcomingAppointments.isNotEmpty
        ? careState.upcomingAppointments.first
        : null;
    final overdueP    = healthState.overdueParasite;
    final activeSymps = careState.activeSymptoms.length;

    final chips = <_AlertChip>[];
    if (dueMeds > 0) {
      chips.add(_AlertChip(
        label: '$dueMeds med${dueMeds > 1 ? 's' : ''} due today',
        color: AppTheme.primaryAccent,
      ));
    }
    if (nextAppt != null) {
      final days = nextAppt.daysUntil;
      chips.add(_AlertChip(
        label: 'Vet in ${days < 1 ? 'today' : '$days day${days == 1 ? '' : 's'}'}',
        color: AppTheme.secondaryAccent,
      ));
    }
    if (overdueP.isNotEmpty) {
      chips.add(const _AlertChip(label: 'Parasite overdue', color: Colors.red));
    }
    if (activeSymps > 0) {
      chips.add(_AlertChip(
        label: '$activeSymps active symptom${activeSymps > 1 ? 's' : ''}',
        color: AppTheme.primaryAccent,
      ));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border(
          left: BorderSide(color: AppTheme.primaryAccent, width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "$petName's Health",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              if (chips.isEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryAccent.withAlpha(30),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle,
                          size: 14, color: AppTheme.secondaryAccent),
                      SizedBox(width: 4),
                      Text('All clear',
                          style: TextStyle(
                              fontSize: 12, color: AppTheme.secondaryAccent)),
                    ],
                  ),
                ),
            ],
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: chips,
            ),
          ],
        ],
      ),
    );
  }
}

class _AlertChip extends StatelessWidget {
  final String label;
  final Color color;

  const _AlertChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section card wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onAdd;
  final String? addTooltip;
  final List<Widget> children;
  final Widget? emptyState;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    this.onAdd,
    this.addTooltip,
    this.emptyState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Icon(icon, size: 18, color: AppTheme.primaryAccent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
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
                        color: AppTheme.primaryAccent.withAlpha(20),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.primaryAccent.withAlpha(60)),
                      ),
                      child: const Icon(Icons.add,
                          size: 16, color: AppTheme.primaryAccent),
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
  final String text;
  final IconData icon;

  const _EmptyHint({required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.border, size: 28),
            const SizedBox(height: 6),
            Text(text,
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 13),
                textAlign: TextAlign.center),
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
  final PetCareState careState;
  const _VitalsSection({required this.careState});

  @override
  ConsumerState<_VitalsSection> createState() => _VitalsSectionState();
}

class _VitalsSectionState extends ConsumerState<_VitalsSection> {
  int _rangeDays = 7;

  @override
  Widget build(BuildContext context) {
    final weights = widget.careState.recentWeights;
    final latest  = weights.isNotEmpty ? weights.last : null;
    final prior   = weights.length >= 2 ? weights[weights.length - 2] : null;
    final delta   = (latest != null && prior != null)
        ? latest.weightLbs - prior.weightLbs
        : null;
    final maxW    = weights.isEmpty
        ? 1.0
        : weights.map((w) => w.weightLbs).reduce(max);

    return _SectionCard(
      title: 'Vitals & Weight',
      icon:  Icons.monitor_weight_outlined,
      onAdd: () => _showLogWeightSheet(context),
      addTooltip: 'Log weight',
      emptyState: const _EmptyHint(
          text: 'No weight logs yet', icon: Icons.monitor_weight_outlined),
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
                    style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary),
                  ),
                  if (delta != null)
                    Row(
                      children: [
                        Icon(
                          delta >= 0
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down,
                          size: 16,
                          color: delta > 0 ? Colors.red : AppTheme.secondaryAccent,
                        ),
                        Text(
                          '${delta.abs().toStringAsFixed(1)} ${latest!.unit} vs prior',
                          style: const TextStyle(
                              color: AppTheme.textSecondary, fontSize: 12),
                        ),
                      ],
                    )
                  else
                    const Text('Tap + to log first weight',
                        style: TextStyle(
                            color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            if (latest?.bcsScore != null) ...[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.amber.withAlpha(30),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withAlpha(80)),
                ),
                child: Text(
                  'BCS ${latest!.bcsScore}/9 · ${latest.bcsLabel}',
                  style: const TextStyle(color: Colors.amber, fontSize: 11),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: selected
                      ? AppTheme.primaryAccent
                      : AppTheme.primaryAccent.withAlpha(15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text('${d}d',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: selected
                            ? Colors.white
                            : AppTheme.textSecondary)),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 12),
        if (weights.isEmpty)
          const _EmptyHint(
              text: 'Log your first weight to see trends',
              icon: Icons.show_chart)
        else
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weights.map((w) {
                final ratio = maxW > 0 ? w.weightLbs / maxW : 0.5;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Flexible(
                          child: FractionallySizedBox(
                            heightFactor: ratio.clamp(0.05, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: w == latest
                                    ? AppTheme.primaryAccent
                                    : AppTheme.primaryAccent.withAlpha(100),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('E').format(w.logDate),
                          style: const TextStyle(
                              fontSize: 9,
                              color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }

  void _showLogWeightSheet(BuildContext context) {
    final weightCtrl = TextEditingController();
    final notesCtrl  = TextEditingController();
    int? selectedBcs;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setS) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20, right: 20, top: 20,
              bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Log Weight',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                TextField(
                  controller: weightCtrl,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Weight (lbs)',
                    labelStyle:
                        const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Body Condition Score (optional)',
                    style: TextStyle(
                        color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  children: List.generate(9, (i) {
                    final score = i + 1;
                    final sel   = selectedBcs == score;
                    return GestureDetector(
                      onTap: () => setS(() => selectedBcs = score),
                      child: Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: sel
                              ? AppTheme.primaryAccent
                              : AppTheme.cardColor,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: sel
                                  ? AppTheme.primaryAccent
                                  : AppTheme.border),
                        ),
                        child: Text('$score',
                            style: TextStyle(
                                color: sel
                                    ? Colors.white
                                    : AppTheme.textSecondary,
                                fontWeight: sel
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesCtrl,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Notes (optional)',
                    labelStyle:
                        const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      final w = double.tryParse(weightCtrl.text);
                      if (w == null) return;
                      Navigator.pop(ctx);
                      ref.read(petCareProvider.notifier).logWeight(
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
        });
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. Medications
// ─────────────────────────────────────────────────────────────────────────────

class _MedicationsSection extends ConsumerWidget {
  final List<PetMedication> medications;
  final String petId;

  const _MedicationsSection({
    required this.medications,
    required this.petId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthState = ref.watch(healthProvider);

    return _SectionCard(
      title:      'Medications',
      icon:       Icons.medication_outlined,
      onAdd:      () => _showAddMedSheet(context, ref),
      addTooltip: 'Add medication',
      emptyState: const _EmptyHint(
          text: 'No active medications', icon: Icons.medication_outlined),
      children: medications.map((med) {
        final dose = healthState.todayDoseFor(med.id);
        return _MedicationRow(
          med:   med,
          dose:  dose,
          onGive: dose != null && !dose.isGiven
              ? () => ref.read(healthProvider.notifier).markDoseGiven(dose)
              : null,
          onSkip: dose != null && !dose.skipped
              ? () => ref.read(healthProvider.notifier).skipDose(dose)
              : null,
        );
      }).toList(),
    );
  }

  void _showAddMedSheet(BuildContext context, WidgetRef ref) {
    final nameCtrl    = TextEditingController();
    final doseCtrl    = TextEditingController();
    final purposeCtrl = TextEditingController();
    String freq       = 'once_daily';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Medication',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              _sheetTextField(nameCtrl, 'Medication name'),
              const SizedBox(height: 10),
              _sheetTextField(doseCtrl, 'Dose (e.g. 16mg, 1 pill)'),
              const SizedBox(height: 10),
              _sheetTextField(purposeCtrl, 'Purpose (optional)'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: freq,
                dropdownColor: AppTheme.cardColor,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Frequency',
                  labelStyle:
                      const TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.cardColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'once_daily', child: Text('Once daily')),
                  DropdownMenuItem(
                      value: 'twice_daily', child: Text('Twice daily')),
                  DropdownMenuItem(
                      value: 'three_times_daily',
                      child: Text('3× daily')),
                  DropdownMenuItem(
                      value: 'weekly', child: Text('Weekly')),
                  DropdownMenuItem(
                      value: 'monthly', child: Text('Monthly')),
                  DropdownMenuItem(
                      value: 'as_needed', child: Text('As needed')),
                ],
                onChanged: (v) => setS(() => freq = v ?? freq),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.isEmpty) return;
                    Navigator.pop(ctx);
                    ref.read(healthProvider.notifier).addMedication(
                          PetMedication(
                            id:        '',
                            petId:     petId,
                            name:      nameCtrl.text.trim(),
                            dose:      doseCtrl.text.isEmpty
                                ? null
                                : doseCtrl.text.trim(),
                            frequency: freq,
                            startDate: DateTime.now(),
                            purpose:   purposeCtrl.text.isEmpty
                                ? null
                                : purposeCtrl.text.trim(),
                            status:    'active',
                          ),
                        );
                  },
                  child: const Text('Add Medication'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _MedicationRow extends StatelessWidget {
  final PetMedication med;
  final MedicationDose? dose;
  final VoidCallback? onGive;
  final VoidCallback? onSkip;

  const _MedicationRow({
    required this.med,
    this.dose,
    this.onGive,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.medication,
                    size: 16, color: AppTheme.textSecondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${med.name}${med.dose != null ? ' · ${med.dose}' : ''}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: med.statusColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(med.statusLabel,
                      style:
                          TextStyle(fontSize: 11, color: med.statusColor)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(med.frequencyLabel,
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
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
  final MedicationDose dose;
  final VoidCallback? onGive;
  final VoidCallback? onSkip;

  const _DoseStatusRow(
      {required this.dose, this.onGive, this.onSkip});

  @override
  Widget build(BuildContext context) {
    if (dose.isGiven) {
      return Row(
        children: [
          const Icon(Icons.check_circle,
              size: 14, color: AppTheme.secondaryAccent),
          const SizedBox(width: 4),
          Text(
            'Given ${dose.givenAt != null ? DateFormat('h:mm a').format(dose.givenAt!) : ''}',
            style: const TextStyle(
                fontSize: 12, color: AppTheme.secondaryAccent),
          ),
        ],
      );
    }
    if (dose.skipped) {
      return const Row(
        children: [
          Icon(Icons.cancel, size: 14, color: AppTheme.textSecondary),
          SizedBox(width: 4),
          Text('Skipped',
              style: TextStyle(
                  fontSize: 12, color: AppTheme.textSecondary)),
        ],
      );
    }
    return Row(
      children: [
        Icon(dose.isOverdue ? Icons.warning : Icons.schedule,
            size: 14,
            color: dose.isOverdue
                ? AppTheme.primaryAccent
                : AppTheme.textSecondary),
        const SizedBox(width: 4),
        Text(
          dose.isOverdue ? 'Overdue' : 'Due today',
          style: TextStyle(
              fontSize: 12,
              color: dose.isOverdue
                  ? AppTheme.primaryAccent
                  : AppTheme.textSecondary),
        ),
        const Spacer(),
        if (onGive != null)
          TextButton(
            onPressed: onGive,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.secondaryAccent,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Given', style: TextStyle(fontSize: 12)),
          ),
        if (onSkip != null)
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.textSecondary,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
  final List<PetVetAppointment> appointments;
  final String petId;

  const _AppointmentsSection(
      {required this.appointments, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SectionCard(
      title:      'Vet Appointments',
      icon:       Icons.calendar_today_outlined,
      onAdd:      () => _showAddApptSheet(context, ref),
      addTooltip: 'Add appointment',
      emptyState: const _EmptyHint(
          text: 'No upcoming appointments', icon: Icons.calendar_today_outlined),
      children: appointments
          .map((a) => _AppointmentCard(appt: a, ref: ref))
          .toList(),
    );
  }

  void _showAddApptSheet(BuildContext context, WidgetRef ref) {
    final titleCtrl  = TextEditingController();
    final doctorCtrl = TextEditingController();
    final locCtrl    = TextEditingController();
    final notesCtrl  = TextEditingController();
    DateTime date    = DateTime.now().add(const Duration(days: 7));
    String type      = 'routine';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add Appointment',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                _sheetTextField(titleCtrl, 'Title (e.g. Annual Checkup)'),
                const SizedBox(height: 10),
                _sheetTextField(doctorCtrl, 'Doctor (optional)'),
                const SizedBox(height: 10),
                _sheetTextField(locCtrl, 'Location (optional)'),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  dropdownColor: AppTheme.cardColor,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle:
                        const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'routine', child: Text('Routine')),
                    DropdownMenuItem(
                        value: 'emergency', child: Text('Emergency')),
                    DropdownMenuItem(
                        value: 'specialist', child: Text('Specialist')),
                    DropdownMenuItem(
                        value: 'dental', child: Text('Dental')),
                    DropdownMenuItem(
                        value: 'surgery', child: Text('Surgery')),
                    DropdownMenuItem(
                        value: 'follow_up', child: Text('Follow-up')),
                  ],
                  onChanged: (v) => setS(() => type = v ?? type),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    'Date: ${DateFormat('MMM d, yyyy').format(date)}',
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  trailing: const Icon(Icons.edit_calendar,
                      color: AppTheme.primaryAccent),
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
                _sheetTextField(notesCtrl, 'Notes (optional)'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (titleCtrl.text.isEmpty) return;
                      Navigator.pop(ctx);
                      ref.read(healthProvider.notifier).upsertAppointment(
                            PetVetAppointment(
                              id:              '',
                              petId:           petId,
                              title:           titleCtrl.text.trim(),
                              doctor:          doctorCtrl.text.isEmpty
                                  ? null
                                  : doctorCtrl.text.trim(),
                              scheduledAt:     date,
                              notes:           notesCtrl.text.isEmpty
                                  ? null
                                  : notesCtrl.text.trim(),
                              status:          'scheduled',
                              appointmentType: type,
                              location:        locCtrl.text.isEmpty
                                  ? null
                                  : locCtrl.text.trim(),
                            ),
                          );
                      // Refresh care state to pick up new appointment.
                      ref.read(petCareProvider.notifier).refresh();
                    },
                    child: const Text('Save Appointment'),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final PetVetAppointment appt;
  final WidgetRef ref;

  const _AppointmentCard({required this.appt, required this.ref});

  @override
  Widget build(BuildContext context) {
    final days    = appt.daysUntil;
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
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(appt.title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.secondaryAccent.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(appt.appointmentTypeLabel,
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.secondaryAccent)),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 12, color: AppTheme.textSecondary),
                const SizedBox(width: 4),
                Text(
                  '${DateFormat('MMM d, yyyy').format(appt.scheduledAt)} · $daysStr',
                  style: const TextStyle(
                      fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            ),
            if (appt.doctor != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.person, size: 12, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(appt.doctor!,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ),
            ],
            if (appt.location != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.location_on,
                      size: 12, color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(appt.location!,
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
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
  final List<PetVaccination> vaccinations;
  final String petId;

  const _VaccinationsSection(
      {required this.vaccinations, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SectionCard(
      title:      'Vaccinations',
      icon:       Icons.vaccines_outlined,
      onAdd:      () => _showAddVaxSheet(context, ref),
      addTooltip: 'Add vaccination',
      emptyState: const _EmptyHint(
          text: 'No vaccination records', icon: Icons.vaccines_outlined),
      children: vaccinations.map((v) {
        final completed = v.isCompleted;
        final dueDate   = v.nextDueDate ?? v.scheduledFor;
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Icon(
                completed ? Icons.check_circle : Icons.circle,
                size: 14,
                color: completed
                    ? AppTheme.secondaryAccent
                    : (v.isDueSoon ? AppTheme.primaryAccent : AppTheme.textSecondary),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  v.vaccineName,
                  style: const TextStyle(
                      color: AppTheme.textPrimary, fontSize: 14),
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
                          ? AppTheme.textSecondary
                          : (v.isDueSoon
                              ? AppTheme.primaryAccent
                              : AppTheme.textSecondary)),
                ),
              if (!completed) ...[
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () async {
                    await ref
                        .read(healthProvider.notifier)
                        .markVaccinationComplete(v.id);
                    ref.read(petCareProvider.notifier).refresh();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryAccent.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Done',
                        style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.secondaryAccent)),
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
    final nameCtrl  = TextEditingController();
    final notesCtrl = TextEditingController();
    DateTime? dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Vaccination',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              _sheetTextField(nameCtrl, 'Vaccine name'),
              const SizedBox(height: 10),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  dueDate == null
                      ? 'Due date (optional)'
                      : 'Due: ${DateFormat('MMM d, yyyy').format(dueDate!)}',
                  style: TextStyle(
                      color: dueDate == null
                          ? AppTheme.textSecondary
                          : AppTheme.textPrimary),
                ),
                trailing: const Icon(Icons.edit_calendar,
                    color: AppTheme.primaryAccent),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: ctx,
                    initialDate: DateTime.now().add(const Duration(days: 30)),
                    firstDate: DateTime.now().subtract(const Duration(days: 365)),
                    lastDate: DateTime.now().add(const Duration(days: 1825)),
                  );
                  if (picked != null) setS(() => dueDate = picked);
                },
              ),
              _sheetTextField(notesCtrl, 'Notes (optional)'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (nameCtrl.text.isEmpty) return;
                    Navigator.pop(ctx);
                    ref.read(healthProvider.notifier).upsertVaccination(
                          PetVaccination(
                            id:          '',
                            petId:       petId,
                            vaccineName: nameCtrl.text.trim(),
                            status:      'scheduled',
                            scheduledFor:dueDate,
                            nextDueDate: dueDate,
                            notes:       notesCtrl.text.isEmpty
                                ? null
                                : notesCtrl.text.trim(),
                          ),
                        );
                    ref.read(petCareProvider.notifier).refresh();
                  },
                  child: const Text('Add Vaccination'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. Parasite Prevention
// ─────────────────────────────────────────────────────────────────────────────

class _ParasiteSection extends ConsumerWidget {
  final List<ParasitePrevention> entries;
  final String petId;

  const _ParasiteSection({required this.entries, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _SectionCard(
      title:      'Parasite Prevention',
      icon:       Icons.bug_report_outlined,
      onAdd:      () => _showLogSheet(context, ref),
      addTooltip: 'Log treatment',
      emptyState: const _EmptyHint(
          text: 'No parasite prevention logs', icon: Icons.bug_report_outlined),
      children: entries.map((e) {
        final daysUntil = e.daysUntilDue;
        final label     = e.isOverdue
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
                    Text(e.productName,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary)),
                    Text(
                        '${e.productTypeLabel} · ${_relativeTime(e.administeredOn)}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: e.urgencyColor.withAlpha(30),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: e.urgencyColor.withAlpha(80)),
                ),
                child: Text(label,
                    style:
                        TextStyle(fontSize: 11, color: e.urgencyColor)),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showLogSheet(BuildContext context, WidgetRef ref) {
    final productCtrl = TextEditingController();
    final notesCtrl   = TextEditingController();
    String type       = 'flea_tick';
    DateTime administered = DateTime.now();
    DateTime? nextDue;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Log Treatment',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 16),
                _sheetTextField(productCtrl, 'Product name (e.g. NexGard)'),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  initialValue: type,
                  dropdownColor: AppTheme.cardColor,
                  style: const TextStyle(color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Type',
                    labelStyle: const TextStyle(color: AppTheme.textSecondary),
                    filled: true,
                    fillColor: AppTheme.cardColor,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'flea', child: Text('Flea')),
                    DropdownMenuItem(value: 'tick', child: Text('Tick')),
                    DropdownMenuItem(
                        value: 'flea_tick', child: Text('Flea & Tick')),
                    DropdownMenuItem(
                        value: 'heartworm', child: Text('Heartworm')),
                    DropdownMenuItem(
                        value: 'dewormer', child: Text('Dewormer')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setS(() => type = v ?? type),
                ),
                const SizedBox(height: 10),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                      'Administered: ${DateFormat('MMM d, yyyy').format(administered)}',
                      style: const TextStyle(color: AppTheme.textPrimary)),
                  trailing: const Icon(Icons.edit_calendar,
                      color: AppTheme.primaryAccent),
                  onTap: () async {
                    final p = await showDatePicker(
                      context: ctx,
                      initialDate: administered,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 365)),
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
                              ? AppTheme.textSecondary
                              : AppTheme.textPrimary)),
                  trailing: const Icon(Icons.edit_calendar,
                      color: AppTheme.primaryAccent),
                  onTap: () async {
                    final p = await showDatePicker(
                      context: ctx,
                      initialDate:
                          administered.add(const Duration(days: 30)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (p != null) setS(() => nextDue = p);
                  },
                ),
                _sheetTextField(notesCtrl, 'Notes (optional)'),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () {
                      if (productCtrl.text.isEmpty) return;
                      Navigator.pop(ctx);
                      ref.read(healthProvider.notifier).logParasiteTreatment(
                            ParasitePrevention(
                              id:             '',
                              petId:          petId,
                              productName:    productCtrl.text.trim(),
                              productType:    type,
                              administeredOn: administered,
                              nextDueDate:    nextDue,
                              notes:          notesCtrl.text.isEmpty
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
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 6. Dental Health
// ─────────────────────────────────────────────────────────────────────────────

class _DentalSection extends ConsumerWidget {
  final List<DentalLog> logs;
  final String petId;

  const _DentalSection({required this.logs, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lastBrush = logs
        .where((l) => l.cleaningType == 'home_brushing')
        .map((l) => l.logDate)
        .fold<DateTime?>(null, (best, d) => best == null || d.isAfter(best) ? d : best);

    final lastProf = logs
        .where((l) => l.cleaningType == 'professional_cleaning')
        .map((l) => l.logDate)
        .fold<DateTime?>(null, (best, d) => best == null || d.isAfter(best) ? d : best);

    String ago(DateTime? d) {
      if (d == null) return 'Never';
      final days = DateTime.now().difference(d).inDays;
      if (days == 0) return 'Today';
      if (days == 1) return 'Yesterday';
      return '$days days ago';
    }

    return _SectionCard(
      title:      'Dental Health',
      icon:       Icons.sentiment_satisfied_alt,
      onAdd:      () => _showLogSheet(context, ref),
      addTooltip: 'Log dental care',
      emptyState: const _EmptyHint(
          text: 'No dental logs yet', icon: Icons.sentiment_satisfied_alt),
      children: [
        _DentalRow(
            label: 'Last home brushing',
            value: ago(lastBrush),
            icon: Icons.brush),
        const SizedBox(height: 6),
        _DentalRow(
            label: 'Last professional cleaning',
            value: ago(lastProf),
            icon: Icons.medical_services),
        if (logs.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...logs.take(3).map((l) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(l.cleaningIcon,
                        size: 12, color: AppTheme.textSecondary),
                    const SizedBox(width: 6),
                    Text(l.cleaningTypeLabel,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                    const Spacer(),
                    Text(DateFormat('MMM d').format(l.logDate),
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
              )),
        ],
      ],
    );
  }

  void _showLogSheet(BuildContext context, WidgetRef ref) {
    String type      = 'home_brushing';
    final notesCtrl  = TextEditingController();
    DateTime logDate = DateTime.now();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Log Dental Care',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: type,
                dropdownColor: AppTheme.cardColor,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Type',
                  labelStyle:
                      const TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.cardColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'home_brushing',
                      child: Text('Home Brushing')),
                  DropdownMenuItem(
                      value: 'dental_chew', child: Text('Dental Chew')),
                  DropdownMenuItem(
                      value: 'professional_cleaning',
                      child: Text('Professional Cleaning')),
                  DropdownMenuItem(
                      value: 'water_additive',
                      child: Text('Water Additive')),
                ],
                onChanged: (v) => setS(() => type = v ?? type),
              ),
              const SizedBox(height: 10),
              _sheetTextField(notesCtrl, 'Notes (optional)'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ref.read(healthProvider.notifier).logDental(
                          DentalLog(
                            id:           '',
                            petId:        petId,
                            logDate:      logDate,
                            cleaningType: type,
                            notes:        notesCtrl.text.isEmpty
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
      }),
    );
  }
}

class _DentalRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _DentalRow(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppTheme.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppTheme.textSecondary)),
        ),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 7. Allergies
// ─────────────────────────────────────────────────────────────────────────────

class _AllergySection extends ConsumerWidget {
  final List<PetAllergy> allergies;
  final String petId;

  const _AllergySection({required this.allergies, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeAllergies = allergies.where((a) => a.isActive).toList();

    return _SectionCard(
      title:      'Allergies',
      icon:       Icons.warning_amber_outlined,
      onAdd:      () => _showAddSheet(context, ref),
      addTooltip: 'Add allergy',
      emptyState: const _EmptyHint(
          text: 'No known allergies recorded', icon: Icons.warning_amber_outlined),
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
                      horizontal: 10, vertical: 5),
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
                        style: TextStyle(
                            fontSize: 12, color: a.severityColor),
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

  void _confirmDelete(
      BuildContext context, WidgetRef ref, PetAllergy allergy) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.cardColor,
        title: const Text('Remove Allergy',
            style: TextStyle(color: AppTheme.textPrimary)),
        content: Text('Remove "${allergy.allergen}" from the allergy list?',
            style: const TextStyle(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(healthProvider.notifier).removeAllergy(allergy.id);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final allergenCtrl  = TextEditingController();
    final reactionCtrl  = TextEditingController();
    String allergenType = 'food';
    String severity     = 'mild';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Add Allergy',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 16),
              _sheetTextField(allergenCtrl, 'Allergen (e.g. Chicken, Grass)'),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: allergenType,
                dropdownColor: AppTheme.cardColor,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Type',
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.cardColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(value: 'food', child: Text('Food')),
                  DropdownMenuItem(
                      value: 'environmental',
                      child: Text('Environmental')),
                  DropdownMenuItem(value: 'drug', child: Text('Drug')),
                  DropdownMenuItem(value: 'insect', child: Text('Insect')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (v) => setS(() => allergenType = v ?? allergenType),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: severity,
                dropdownColor: AppTheme.cardColor,
                style: const TextStyle(color: AppTheme.textPrimary),
                decoration: InputDecoration(
                  labelText: 'Severity',
                  labelStyle: const TextStyle(color: AppTheme.textSecondary),
                  filled: true,
                  fillColor: AppTheme.cardColor,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
                items: const [
                  DropdownMenuItem(value: 'mild', child: Text('Mild')),
                  DropdownMenuItem(
                      value: 'moderate', child: Text('Moderate')),
                  DropdownMenuItem(value: 'severe', child: Text('Severe')),
                  DropdownMenuItem(
                      value: 'life_threatening',
                      child: Text('Life-threatening')),
                ],
                onChanged: (v) => setS(() => severity = v ?? severity),
              ),
              const SizedBox(height: 10),
              _sheetTextField(reactionCtrl, 'Reaction notes (optional)'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (allergenCtrl.text.isEmpty) return;
                    Navigator.pop(ctx);
                    ref.read(healthProvider.notifier).addAllergy(
                          PetAllergy(
                            id:           '',
                            petId:        petId,
                            allergen:     allergenCtrl.text.trim(),
                            allergenType: allergenType,
                            severity:     severity,
                            reaction:     reactionCtrl.text.isEmpty
                                ? null
                                : reactionCtrl.text.trim(),
                            isActive:     true,
                          ),
                        );
                  },
                  child: const Text('Add Allergy'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 8. Symptoms
// ─────────────────────────────────────────────────────────────────────────────

class _SymptomsSection extends ConsumerStatefulWidget {
  final List<PetSymptom> active;
  final List<PetSymptom> resolved;
  final String petId;

  const _SymptomsSection({
    required this.active,
    required this.resolved,
    required this.petId,
  });

  @override
  ConsumerState<_SymptomsSection> createState() => _SymptomsSectionState();
}

class _SymptomsSectionState extends ConsumerState<_SymptomsSection> {
  bool _showResolved = false;

  static const _kTypes = [
    'Lethargy', 'Vomiting', 'Diarrhea', 'Loss of Appetite',
    'Itching', 'Sneezing', 'Limping', 'Coughing', 'Scratching',
    'Eye Discharge', 'Ear Scratching', 'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title:      'Symptoms',
      icon:       Icons.medical_services_outlined,
      onAdd:      () => _showLogSheet(context),
      addTooltip: 'Log symptom',
      emptyState: const _EmptyHint(
          text: 'No symptoms logged', icon: Icons.medical_services_outlined),
      children: [
        ...widget.active.map((s) => _SymptomRow(
              symptom:   s,
              onResolve: () => ref
                  .read(petCareProvider.notifier)
                  .resolveSymptom(s.id),
            )),
        if (widget.resolved.isNotEmpty) ...[
          GestureDetector(
            onTap: () => setState(() => _showResolved = !_showResolved),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Text(
                    '${widget.resolved.length} resolved',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _showResolved
                        ? Icons.expand_less
                        : Icons.expand_more,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
            ),
          ),
          if (_showResolved)
            ...widget.resolved.map((s) => _SymptomRow(
                  symptom:   s,
                  onResolve: null,
                )),
        ],
      ],
    );
  }

  void _showLogSheet(BuildContext context) {
    String? selectedType;
    String severity     = 'mild';
    final notesCtrl     = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Log Symptom',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
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
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppTheme.primaryAccent
                            : AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel
                                ? AppTheme.primaryAccent
                                : AppTheme.border),
                      ),
                      child: Text(t,
                          style: TextStyle(
                              fontSize: 13,
                              color: sel
                                  ? Colors.white
                                  : AppTheme.textSecondary)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              const Text('Severity',
                  style: TextStyle(
                      color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              Row(
                children: ['mild', 'moderate', 'severe'].map((s) {
                  final sel = severity == s;
                  return GestureDetector(
                    onTap: () => setS(() => severity = s),
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel
                            ? AppTheme.primaryAccent
                            : AppTheme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel
                                ? AppTheme.primaryAccent
                                : AppTheme.border),
                      ),
                      child: Text(
                          s[0].toUpperCase() + s.substring(1),
                          style: TextStyle(
                              fontSize: 13,
                              color: sel
                                  ? Colors.white
                                  : AppTheme.textSecondary)),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              _sheetTextField(notesCtrl, 'Notes (optional)'),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryAccent,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    if (selectedType == null) return;
                    Navigator.pop(ctx);
                    ref.read(petCareProvider.notifier).logSymptom(
                          symptomType: selectedType!,
                          severity:    severity,
                          notes:       notesCtrl.text.isEmpty
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
      }),
    );
  }
}

class _SymptomRow extends StatelessWidget {
  final PetSymptom symptom;
  final VoidCallback? onResolve;

  const _SymptomRow({required this.symptom, this.onResolve});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: symptom.isResolved
                  ? AppTheme.textSecondary
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
                        ? AppTheme.textSecondary
                        : AppTheme.textPrimary,
                    decoration: symptom.isResolved
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                Text(
                  '${symptom.severityLabel} · ${DateFormat('MMM d').format(symptom.observedAt)}',
                  style: const TextStyle(
                      fontSize: 11, color: AppTheme.textSecondary),
                ),
              ],
            ),
          ),
          if (onResolve != null)
            GestureDetector(
              onTap: onResolve,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryAccent.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('Resolved',
                    style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.secondaryAccent)),
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

Widget _sheetTextField(TextEditingController ctrl, String label) {
  return TextField(
    controller: ctrl,
    style: const TextStyle(color: AppTheme.textPrimary),
    decoration: InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppTheme.textSecondary),
      filled: true,
      fillColor: AppTheme.cardColor,
      border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none),
    ),
  );
}
