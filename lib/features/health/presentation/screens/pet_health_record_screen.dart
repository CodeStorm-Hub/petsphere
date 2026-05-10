import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:petsphere/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petsphere/features/health/presentation/controllers/vitals_controller.dart';
import 'package:petsphere/features/health/presentation/controllers/appointment_controller.dart';
import 'package:petsphere/features/health/presentation/controllers/vaccination_controller.dart';
import 'package:petsphere/features/health/presentation/controllers/medication_controller.dart';
import 'package:petsphere/features/health/data/models/pet_health_extended_models.dart';

class PetHealthRecordScreen extends ConsumerStatefulWidget {
  const PetHealthRecordScreen({super.key});

  @override
  ConsumerState<PetHealthRecordScreen> createState() =>
      _PetHealthRecordScreenState();
}

class _PetHealthRecordScreenState extends ConsumerState<PetHealthRecordScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activePet = ref.watch(activePetProvider);
    final vitalsState = ref.watch(vitalsProvider);
    
    if (activePet == null) {
      return const Scaffold(
        body: Center(child: Text('No pet selected')),
      );
    }

    

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar.large(
            title: const Text(
              'Health Records',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.share_rounded),
              ),
              const SizedBox(width: 8),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HealthStatusHeader(
                    petName: activePet.name,
                    status: 'Active', // Can be dynamic based on overdue tasks
                    lastCheckup: 'Not recorded', // Could fetch from last appointment
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Vitals Summary',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _VitalsGrid(vitalsState: vitalsState),
                  const SizedBox(height: 32),
                  TabBar(
                    controller: _tabController,
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    unselectedLabelStyle: const TextStyle(
                      fontWeight: FontWeight.normal,
                    ),
                    tabs: const [
                      Tab(text: 'History'),
                      Tab(text: 'Vaccines'),
                      Tab(text: 'Meds'),
                      Tab(text: 'Labs'),
                    ],
                    onTap: (index) => setState(() {}),
                  ),
                  const SizedBox(height: 24),
                  _buildTabContent(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add_a_photo_rounded),
        label: const Text('Scan Document'),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_tabController.index) {
      case 0:
        return const _MedicalTimeline();
      case 1:
        return const _VaccineList();
      case 2:
        return const _MedicationList();
      default:
        return const _EmptyState(
          text: 'No specific records in this category yet.',
        );
    }
  }
}

class _HealthStatusHeader extends StatelessWidget {
  final String petName;
  final String status;
  final String lastCheckup;

  const _HealthStatusHeader({
    required this.petName,
    required this.status,
    required this.lastCheckup,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer,
            colorScheme.primaryContainer.withAlpha(150),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: colorScheme.primaryContainer),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withAlpha(100),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$petName is $status',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Profile Status: Updated',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer.withAlpha(180),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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

class _VitalsGrid extends StatelessWidget {
  final VitalsState vitalsState;

  const _VitalsGrid({required this.vitalsState});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final latestWeight = vitalsState.latestWeight;
    final avgActivity = vitalsState.averageActivityDuration;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.4,
      children: [
        _VitalCard(
          label: 'Weight',
          value: latestWeight != null
              ? '${latestWeight.weightLbs.toStringAsFixed(1)} ${latestWeight.unit}'
              : '— lbs',
          icon: Icons.monitor_weight_outlined,
          trend: latestWeight != null ? 'Recorded' : 'Missing',
          color: colorScheme.primary,
        ),
        _VitalCard(
          label: 'Activity',
          value: avgActivity > 0
              ? '${avgActivity.toStringAsFixed(0)} min/avg'
              : '— min',
          icon: Icons.directions_run_rounded,
          trend: avgActivity > 0 ? 'Active' : 'Missing',
          color: colorScheme.tertiary,
        ),
        _VitalCard(
          label: 'Heart Rate',
          value: '— bpm',
          icon: Icons.favorite_outline_rounded,
          trend: 'TBD',
          color: colorScheme.error,
        ),
        _VitalCard(
          label: 'Temperature',
          value: '— °C',
          icon: Icons.thermostat_rounded,
          trend: 'TBD',
          color: colorScheme.secondary,
        ),
      ],
    );
  }
}

class _VitalCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String trend;
  final Color color;

  const _VitalCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.trend,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(30),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  trend,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _MedicalTimeline extends ConsumerWidget {
  const _MedicalTimeline();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appointments = ref.watch(appointmentProvider).pastAppointments;
    
    if (appointments.isEmpty) {
      return const _EmptyState(text: 'No past medical events recorded.');
    }

    return Column(
      children: appointments.map((appt) => _TimelineItem(
        date: DateFormat('MMM d, yyyy').format(appt.scheduledAt),
        title: appt.title,
        doctor: appt.doctor ?? 'Unknown Veterinarian',
        type: appt.appointmentTypeLabel,
      )).toList(),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  final String date;
  final String title;
  final String doctor;
  final String type;

  const _TimelineItem({
    required this.date,
    required this.title,
    required this.doctor,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.surface, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withAlpha(100),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(width: 2, color: colorScheme.outlineVariant),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        date,
                        style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w900,
                          fontSize: 12,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          type,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Attended by $doctor',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VaccineList extends ConsumerWidget {
  const _VaccineList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vaccinations = ref.watch(vaccinationProvider).vaccinations;
    
    if (vaccinations.isEmpty) {
      return const _EmptyState(text: 'No vaccination records found.');
    }

    return Column(
      children: vaccinations.map((vax) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _VaccineCard(
          name: vax.vaccineName,
          date: vax.completedOn != null 
              ? DateFormat('MMM d, yyyy').format(vax.completedOn!)
              : 'Scheduled',
          nextDue: vax.nextDueDate != null 
              ? DateFormat('MMM d, yyyy').format(vax.nextDueDate!)
              : 'N/A',
          status: vax.isCompleted ? 'Up to date' : (vax.isDueSoon ? 'Due Soon' : 'Upcoming'),
        ),
      )).toList(),
    );
  }
}

class _VaccineCard extends StatelessWidget {
  final String name;
  final String date;
  final String nextDue;
  final String status;

  const _VaccineCard({
    required this.name,
    required this.date,
    required this.nextDue,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDueSoon = status == 'Due Soon';
    final isUpToDate = status == 'Up to date';

    return Container(
      padding: const EdgeInsets.all(20),
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
              color: isDueSoon
                  ? colorScheme.errorContainer.withAlpha(100)
                  : (isUpToDate ? colorScheme.tertiary.withAlpha(30) : colorScheme.secondary.withAlpha(30)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isDueSoon
                  ? Icons.priority_high_rounded
                  : (isUpToDate ? Icons.verified_user_rounded : Icons.schedule_rounded),
              color: isDueSoon 
                  ? colorScheme.error 
                  : (isUpToDate ? colorScheme.tertiary : colorScheme.secondary),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Administered: $date',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'Next Due',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                nextDue,
                style: TextStyle(
                  color: isDueSoon
                      ? colorScheme.error
                      : colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MedicationList extends ConsumerWidget {
  const _MedicationList();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medications = ref.watch(medicationProvider).activeMedications;
    
    if (medications.isEmpty) {
      return const _EmptyState(text: 'No active medications.');
    }

    return Column(
      children: medications.map((med) => _MedicationCard(med: med)).toList(),
    );
  }
}

class _MedicationCard extends StatelessWidget {
  final PetMedication med;

  const _MedicationCard({required this.med});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.medication_rounded, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  med.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withAlpha(30),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  med.statusLabel,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.primary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${med.dose ?? "Standard Dose"} · ${med.frequencyLabel}',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 13),
          ),
          if (med.purpose != null) ...[
            const SizedBox(height: 4),
            Text(
              'Purpose: ${med.purpose}',
              style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String text;
  const _EmptyState({required this.text});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          children: [
            Icon(
              Icons.folder_open_rounded,
              size: 64,
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              text,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
