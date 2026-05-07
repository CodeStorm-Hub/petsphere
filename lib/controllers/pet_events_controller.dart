import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_event_models.dart';
import '../repositories/pet_events_repository.dart';
import '../utils/supabase_config.dart';

final petEventsRepositoryProvider = Provider<PetEventsRepository>((ref) {
  return PetEventsRepository(supabase);
});

class PetEventTypeFilterNotifier extends Notifier<String> {
  @override
  String build() => 'All';
  void set(String type) => state = type;
}

final petEventTypeFilterProvider =
    NotifierProvider<PetEventTypeFilterNotifier, String>(() {
  return PetEventTypeFilterNotifier();
});

final petEventsProvider = FutureProvider<List<PetEvent>>((ref) async {
  final repository = ref.watch(petEventsRepositoryProvider);
  final filter = ref.watch(petEventTypeFilterProvider);
  return repository.getEvents(type: filter);
});

final petEventProvider = FutureProvider.family<PetEvent, String>((ref, id) async {
  final repository = ref.watch(petEventsRepositoryProvider);
  return repository.getEventById(id);
});
