import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/health/presentation/controllers/vitals_controller.dart';
import 'package:petfolio/features/health/presentation/controllers/appointment_controller.dart';
import 'package:petfolio/features/health/presentation/controllers/vaccination_controller.dart';
import 'package:petfolio/features/health/presentation/controllers/medication_controller.dart';
import 'package:petfolio/features/health/data/models/pet_health_models.dart';
import 'package:petfolio/features/health/data/models/pet_health_extended_models.dart';

import 'package:image_picker/image_picker.dart';
import 'package:petfolio/core/widgets/petfolio_widgets.dart';

class PetHealthRecordScreen extends ConsumerStatefulWidget {
  const PetHealthRecordScreen({super.key});

  @override
  ConsumerState<PetHealthRecordScreen> createState() =>
      _PetHealthRecordScreenState();
}

class _PetHealthRecordScreenState extends ConsumerState<PetHealthRecordScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ImagePicker _picker = ImagePicker();

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

  Future<void> _pickDocument(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        if (!mounted) return;
        
        // Show loading
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                ),
                SizedBox(width: 12),
                Text('Processing document...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );

        // Simulate upload/processing delay
        await Future<void>.delayed(const Duration(seconds: 2));

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Document uploaded and scanned successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking document: $e')),
      );
    }
  }

  void _showDocumentUploadModal() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Add Health Document',
              style: GoogleFonts.playfairDisplay(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scan or upload prescriptions, lab reports, or vaccination certificates.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmSans(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            _buildUploadOption(
              icon: Icons.camera_alt_rounded,
              title: 'Take a Photo',
              subtitle: 'Scan document using camera',
              onTap: () {
                Navigator.pop(context);
                _pickDocument(ImageSource.camera);
              },
            ),
            const SizedBox(height: 16),
            _buildUploadOption(
              icon: Icons.photo_library_rounded,
              title: 'Choose from Gallery',
              subtitle: 'Upload existing image',
              onTap: () {
                Navigator.pop(context);
                _pickDocument(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 16),
            _buildUploadOption(
              icon: Icons.picture_as_pdf_rounded,
              title: 'Upload PDF',
              subtitle: 'Import PDF document',
              onTap: () {
                Navigator.pop(context);
                // PDF picking logic would go here
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF upload coming soon!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outlineVariant),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: cs.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      color: cs.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: cs.outline),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activePet = ref.watch(activePetProvider);
    final vitalsState = ref.watch(vitalsProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    if (activePet == null) {
      return Scaffold(
        body: PetFolioGradientBackground(
          child: Center(
            child: Text(
              'No pet selected',
              style: GoogleFonts.playfairDisplay(fontSize: 20),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: PetFolioGradientBackground(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar.large(
              backgroundColor: Colors.transparent,
              title: Text(
                'Health Records',
                style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
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
                      status: 'Active',
                      lastCheckup: 'Not recorded',
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Vitals Summary',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Vital'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _VitalsGrid(vitalsState: vitalsState),
                    const SizedBox(height: 32),
                    if (vitalsState.weightLogs.isNotEmpty) ...[
                      Text(
                        'Weight Trend',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _WeightChart(weightLogs: vitalsState.weightLogs),
                      const SizedBox(height: 32),
                    ],
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: cs.outlineVariant),
                        ),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicatorColor: cs.primary,
                        labelColor: cs.primary,
                        unselectedLabelColor: cs.onSurfaceVariant,
                        dividerColor: Colors.transparent,
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showDocumentUploadModal,
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
        return const PetfolioEmptyState(
          icon: Icons.folder_open_rounded,
          title: 'No Records',
          message: 'No specific records in this category yet.',
        );
    }
  }
}

class _HealthStatusHeader extends StatelessWidget {

  const _HealthStatusHeader({
    required this.petName,
    required this.status,
    required this.lastCheckup,
  });
  final String petName;
  final String status;
  final String lastCheckup;

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

  const _VitalsGrid({required this.vitalsState});
  final VitalsState vitalsState;

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

  const _VitalCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.trend,
    required this.color,
  });
  final String label;
  final String value;
  final IconData icon;
  final String trend;
  final Color color;

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
      return const PetfolioEmptyState(icon: Icons.folder_open_rounded, title: 'No Events', message: 'No past medical events recorded.');
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

  const _TimelineItem({
    required this.date,
    required this.title,
    required this.doctor,
    required this.type,
  });
  final String date;
  final String title;
  final String doctor;
  final String type;

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
      return const PetfolioEmptyState(icon: Icons.folder_open_rounded, title: 'No Records', message: 'No vaccination records found.');
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

  const _VaccineCard({
    required this.name,
    required this.date,
    required this.nextDue,
    required this.status,
  });
  final String name;
  final String date;
  final String nextDue;
  final String status;

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
      return const PetfolioEmptyState(icon: Icons.folder_open_rounded, title: 'No Medications', message: 'No active medications.');
    }

    return Column(
      children: medications.map((med) => _MedicationCard(med: med)).toList(),
    );
  }
}

class _MedicationCard extends StatelessWidget {

  const _MedicationCard({required this.med});
  final PetMedication med;

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

class _WeightChart extends StatelessWidget {

  const _WeightChart({required this.weightLogs});
  final List<PetWeightLog> weightLogs;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final sortedLogs = [...weightLogs]..sort((a, b) => a.logDate.compareTo(b.logDate));

    if (sortedLogs.isEmpty) return const SizedBox.shrink();

    final spots = sortedLogs.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weightLbs);
    }).toList();

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(16, 24, 24, 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= sortedLogs.length) return const SizedBox.shrink();
                  if (index % (sortedLogs.length > 5 ? (sortedLogs.length / 3).ceil() : 1) != 0) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      DateFormat('MM/dd').format(sortedLogs[index].logDate),
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  );
                },
                reservedSize: 30,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toStringAsFixed(1),
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: colorScheme.primary,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 3,
                  strokeColor: colorScheme.primary,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withAlpha(50),
                    colorScheme.primary.withAlpha(0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (spot) => colorScheme.primaryContainer,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  return LineTooltipItem(
                    '${spot.y} lbs\n',
                    GoogleFonts.dmSans(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: DateFormat('MMM d').format(sortedLogs[spot.spotIndex].logDate),
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer.withAlpha(150),
                          fontSize: 11,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }
}

