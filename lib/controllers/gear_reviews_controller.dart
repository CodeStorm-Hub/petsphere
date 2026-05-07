import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/gear_review_models.dart';
import '../repositories/feature_repositories.dart';

final gearReviewsRepositoryProvider = Provider<GearReviewsRepository>((ref) {
  return GearReviewsRepository();
});

final gearReviewsProvider = FutureProvider.family<List<GearReview>, String?>((ref, category) async {
  final repository = ref.watch(gearReviewsRepositoryProvider);
  return repository.fetchReviews(category: category);
});

class SelectedGearCategoryNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? category) => state = category;
}

final selectedGearCategoryProvider =
    NotifierProvider<SelectedGearCategoryNotifier, String?>(() {
  return SelectedGearCategoryNotifier();
});

final filteredGearReviewsProvider = FutureProvider<List<GearReview>>((ref) async {
  final category = ref.watch(selectedGearCategoryProvider);
  return ref.watch(gearReviewsProvider(category).future);
});
