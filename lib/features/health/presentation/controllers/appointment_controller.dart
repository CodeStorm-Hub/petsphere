import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petsphere/features/care/data/pet_care_repository.dart';
import 'package:petsphere/features/health/data/models/pet_health_models.dart';
import 'package:petsphere/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petsphere/core/constants/app_strings.dart';
import 'package:petsphere/core/utils/logger.dart';

@immutable
class AppointmentState {
  final List<PetVetAppointment> appointments;
  final bool isLoading;
  final String? error;
  final String? activePetId;

  const AppointmentState({
    this.appointments = const [],
    this.isLoading = false,
    this.error,
    this.activePetId,
  });

  List<PetVetAppointment> get upcomingAppointments =>
      appointments.where((a) => a.scheduledAt.isAfter(DateTime.now())).toList()
        ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));

  List<PetVetAppointment> get pastAppointments =>
      appointments.where((a) => a.scheduledAt.isBefore(DateTime.now())).toList()
        ..sort((a, b) => b.scheduledAt.compareTo(a.scheduledAt));

  AppointmentState copyWith({
    List<PetVetAppointment>? appointments,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? activePetId,
  }) => AppointmentState(
    appointments: appointments ?? this.appointments,
    isLoading: isLoading ?? this.isLoading,
    error: clearError ? null : (error ?? this.error),
    activePetId: activePetId ?? this.activePetId,
  );
}

class AppointmentNotifier extends Notifier<AppointmentState> {
  final _repo = petCareRepository;

  @override
  AppointmentState build() {
    ref.listen<String?>(activePetProvider.select((p) => p?.id), (prev, next) {
      if (next != null && next != prev) _load(next);
    });
    final petId = ref.read(activePetProvider)?.id;
    if (petId != null) {
      Future.microtask(() => _load(petId));
    }
    return AppointmentState(isLoading: petId != null);
  }

  Future<void> _load(String petId) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      activePetId: petId,
    );
    try {
      final appointments = await _repo.fetchAppointments(petId);
      if (!ref.mounted) return;
      state = state.copyWith(
        appointments: appointments,
        isLoading: false,
      );
    } catch (e) {
      if (!ref.mounted) return;
      AppLogger.error(
        AppStrings.healthLoadFailed,
        tag: 'AppointmentNotifier',
        error: e,
      );
      state = state.copyWith(isLoading: false, error: AppStrings.healthLoadFailed);
    }
  }

  Future<void> refresh() async {
    final id = state.activePetId;
    if (id != null) await _load(id);
  }

  Future<void> addAppointment(PetVetAppointment appointment) async {
    try {
      final saved = await _repo.upsertAppointment(appointment);
      state = state.copyWith(appointments: [saved, ...state.appointments]);
    } catch (e) {
      AppLogger.error(
        AppStrings.healthAppointmentFailed,
        tag: 'AppointmentNotifier',
        error: e,
      );
      state = state.copyWith(error: AppStrings.healthAppointmentFailed);
    }
  }

  Future<void> deleteAppointment(String id) async {
    state = state.copyWith(
      appointments: state.appointments.where((a) => a.id != id).toList(),
    );
    try {
      await _repo.deleteAppointment(id);
    } catch (e) {
      AppLogger.error(
        AppStrings.healthAppointmentCancelFailed,
        tag: 'AppointmentNotifier',
        error: e,
      );
      state = state.copyWith(error: AppStrings.healthAppointmentCancelFailed);
      await refresh();
    }
  }

  Future<void> upsertAppointment(PetVetAppointment appt) async {
    try {
      final saved = await _repo.upsertAppointment(appt);
      state = state.copyWith(
        appointments: [
          ...state.appointments.where((a) => a.id != saved.id),
          saved,
        ],
      );
    } catch (e) {
      AppLogger.error(
        AppStrings.healthAppointmentFailed,
        tag: 'AppointmentNotifier',
        error: e,
      );
      state = state.copyWith(error: AppStrings.healthAppointmentFailed);
    }
  }
}

final appointmentProvider =
    NotifierProvider<AppointmentNotifier, AppointmentState>(
      AppointmentNotifier.new,
    );
