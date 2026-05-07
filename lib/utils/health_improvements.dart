import 'package:pet_dating_app/models/pet_health_extended_models.dart';
import 'package:pet_dating_app/models/pet_health_models.dart';

/// Health tracking improvements for Issue #54.
///
/// Provides utilities for:
/// - Appointment reminders and scheduling
/// - Medication dose scheduling
/// - Overdue task detection
/// - Health metrics and trends

// ─────────────────────────────────────────────────────────────────────────────
// Appointment Reminders
// ─────────────────────────────────────────────────────────────────────────────

/// Check if appointment has a reminder due
bool isAppointmentReminderDue(PetVetAppointment appointment) {
  final now = DateTime.now();
  final appointmentTime = appointment.scheduledAt;

  // Reminder due 3 days before appointment
  final reminderTime = appointmentTime.subtract(const Duration(days: 3));

  return now.isAfter(reminderTime) && now.isBefore(appointmentTime);
}

/// Get appointments with upcoming reminders (within next N days)
List<PetVetAppointment> getAppointmentRemindersUpcoming(
  List<PetVetAppointment> appointments, {
  Duration lookAhead = const Duration(days: 7),
}) {
  final now = DateTime.now();
  final deadline = now.add(lookAhead);

  return appointments.where((apt) {
    if (apt.status != 'scheduled') return false;
    final reminderTime = apt.scheduledAt.subtract(const Duration(days: 3));
    return reminderTime.isBefore(deadline) && reminderTime.isAfter(now);
  }).toList();
}

/// Check if appointment is coming up soon (overdue or within N days)
bool isAppointmentImminent(
  PetVetAppointment appointment, {
  Duration threshold = const Duration(days: 1),
}) {
  if (appointment.status != 'scheduled') return false;
  final now = DateTime.now();
  final timeTill = appointment.scheduledAt.difference(now);
  return !timeTill.isNegative && timeTill <= threshold;
}

// ─────────────────────────────────────────────────────────────────────────────
// Medication Dose Scheduling
// ─────────────────────────────────────────────────────────────────────────────

/// Calculate how many doses per day based on frequency string
int calculateDosesPerDay(String frequency) {
  final lower = frequency.toLowerCase();
  if (lower.contains('twice') || lower.contains('2x') || lower.contains('bid')) return 2;
  if (lower.contains('thrice') || lower.contains('3x') || lower.contains('tid')) return 3;
  if (lower.contains('four') || lower.contains('4x') || lower.contains('qid')) return 4;
  // Default: once daily
  return 1;
}

/// Get ideal scheduled times for doses throughout the day
List<DateTime> getIdealDoseTimes(DateTime referenceDay, int dosesPerDay) {
  final times = <DateTime>[];

  switch (dosesPerDay) {
    case 1:
      times.add(referenceDay.copyWith(hour: 8, minute: 0));
      break;
    case 2:
      times.add(referenceDay.copyWith(hour: 8, minute: 0));
      times.add(referenceDay.copyWith(hour: 20, minute: 0));
      break;
    case 3:
      times.add(referenceDay.copyWith(hour: 8, minute: 0));
      times.add(referenceDay.copyWith(hour: 14, minute: 0));
      times.add(referenceDay.copyWith(hour: 20, minute: 0));
      break;
    case 4:
      times.add(referenceDay.copyWith(hour: 7, minute: 0));
      times.add(referenceDay.copyWith(hour: 11, minute: 0));
      times.add(referenceDay.copyWith(hour: 15, minute: 0));
      times.add(referenceDay.copyWith(hour: 21, minute: 0));
      break;
    default:
      // Distribute evenly
      for (int i = 0; i < dosesPerDay; i++) {
        final hour = (24 * i) ~/ dosesPerDay;
        times.add(referenceDay.copyWith(hour: hour, minute: 0));
      }
  }

  return times;
}

/// Check if medication doses are running low
bool areMedicationDosesLow(
  List<MedicationDose> doses, {
  int daysThreshold = 7,
}) {
  if (doses.isEmpty) return true;

  final now = DateTime.now();
  
  // Get all pending future doses
  final futureDoses = doses.where((d) => d.givenAt == null && d.scheduledFor.isAfter(now));
  
  // Count how many unique upcoming days have at least one dose scheduled
  final coveredDays = futureDoses
      .map((d) => DateTime(d.scheduledFor.year, d.scheduledFor.month, d.scheduledFor.day))
      .toSet();

  return coveredDays.length < daysThreshold;
}

/// Get overdue medication doses
List<MedicationDose> getOverdueDoses(
  List<MedicationDose> doses,
) {
  final now = DateTime.now();
  return doses.where((d) {
    return d.givenAt == null && d.scheduledFor.isBefore(now);
  }).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Health Task Alerts
// ─────────────────────────────────────────────────────────────────────────────

/// Detect overdue vaccinations
List<PetVaccination> getOverdueVaccinations(List<PetVaccination> vaccinations) {
  final now = DateTime.now();
  return vaccinations.where((v) {
    final nextDue = v.nextDueDate;
    return nextDue != null && nextDue.isBefore(now);
  }).toList();
}

/// Get vaccinations due soon
List<PetVaccination> getUpcomingVaccinations(
  List<PetVaccination> vaccinations, {
  Duration lookAhead = const Duration(days: 30),
}) {
  final now = DateTime.now();
  final deadline = now.add(lookAhead);

  return vaccinations.where((v) {
    final nextDue = v.nextDueDate;
    return nextDue != null &&
           !nextDue.isAfter(deadline) &&
           nextDue.isAfter(now);
  }).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// Health Metrics & Trends
// ─────────────────────────────────────────────────────────────────────────────

/// Calculate weight trend
/// Returns: ('increasing' | 'decreasing' | 'stable', percentageChange)
(String, double) calculateWeightTrend(List<PetWeightLog> logs) {
  if (logs.length < 2) return ('stable', 0.0);

  // Sort by date ascending (oldest to newest)
  final sorted = List<PetWeightLog>.from(logs)
    ..sort((a, b) => a.logDate.compareTo(b.logDate));

  final oldest = sorted.first.weightLbs;
  final newest = sorted.last.weightLbs;
  final change = newest - oldest;
  final percentChange = (change / oldest) * 100;

  String trend;
  if (percentChange > 2) {
    trend = 'increasing';
  } else if (percentChange < -2) {
    trend = 'decreasing';
  } else {
    trend = 'stable';
  }

  return (trend, percentChange);
}

/// Calculate medication compliance percentage
double calculateMedicationCompliance(List<MedicationDose> doses) {
  if (doses.isEmpty) return 0.0;

  final given = doses.where((d) => d.givenAt != null).length;
  return (given / doses.length) * 100;
}

/// Days since last weight log
int daysSinceLastWeightLog(List<PetWeightLog> logs) {
  if (logs.isEmpty) return 999;
  final lastLog = logs.reduce((a, b) => a.logDate.isAfter(b.logDate) ? a : b);
  return DateTime.now().difference(lastLog.logDate).inDays;
}

/// Check if weight check is overdue
bool isWeightCheckOverdue(
  List<PetWeightLog> logs, {
  Duration threshold = const Duration(days: 30),
}) {
  if (logs.isEmpty) return true;

  final lastLog = logs.reduce((a, b) => a.logDate.isAfter(b.logDate) ? a : b);
  final timeSinceLastCheck = DateTime.now().difference(lastLog.logDate);

  return timeSinceLastCheck > threshold;
}

/// Get health metrics summary for a pet
class HealthMetricsSummary {
  final String weightTrend; // 'increasing', 'decreasing', 'stable'
  final double weightChangePercent;
  final double medicationCompliancePercent;
  final int daysUntilNextVaccination;
  final int overdueVaccinationsCount;
  final int overdueMedicationDosesCount;
  final bool weightCheckOverdue;

  HealthMetricsSummary({
    required this.weightTrend,
    required this.weightChangePercent,
    required this.medicationCompliancePercent,
    required this.daysUntilNextVaccination,
    required this.overdueVaccinationsCount,
    required this.overdueMedicationDosesCount,
    required this.weightCheckOverdue,
  });
}

/// Calculate comprehensive health metrics
HealthMetricsSummary calculateHealthMetrics({
  required List<PetWeightLog> weights,
  required List<MedicationDose> doses,
  required List<PetVaccination> vaccinations,
}) {
  final (weightTrend, weightChange) = calculateWeightTrend(weights);
  final medicationCompliance = calculateMedicationCompliance(doses);
  final overdoseVaccinations = getOverdueVaccinations(vaccinations);
  final nextVaccination = getUpcomingVaccinations(vaccinations, lookAhead: const Duration(days: 365))
      .fold<DateTime?>(null, (earliest, current) {
    if (current.nextDueDate == null) return earliest;
    if (earliest == null) return current.nextDueDate;
    return current.nextDueDate!.isBefore(earliest) ? current.nextDueDate : earliest;
  });

  final daysUntilNextVax = nextVaccination == null
      ? 999
      : DateTime.now().difference(nextVaccination).inDays.abs();

  final overdueDoses = getOverdueDoses(doses);

  return HealthMetricsSummary(
    weightTrend: weightTrend,
    weightChangePercent: weightChange,
    medicationCompliancePercent: medicationCompliance,
    daysUntilNextVaccination: daysUntilNextVax,
    overdueVaccinationsCount: overdoseVaccinations.length,
    overdueMedicationDosesCount: overdueDoses.length,
    weightCheckOverdue: isWeightCheckOverdue(weights),
  );
}
