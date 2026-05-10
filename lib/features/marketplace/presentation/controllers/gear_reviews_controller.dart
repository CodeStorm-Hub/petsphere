import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:petfolio/features/marketplace/data/gear_reviews_repository.dart';
import 'package:petfolio/features/marketplace/data/models/gear_review_models.dart';

class SelectedGearCategory extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? next) => state = next;
}

/// Selected gear review category filter (null = all).
final selectedGearCategoryProvider =
    NotifierProvider<SelectedGearCategory, String?>(SelectedGearCategory.new);

/// Fetch gear reviews, optionally filtered by category.
final filteredGearReviewsProvider = FutureProvider<List<GearReview>>((ref) async {
  final category = ref.watch(selectedGearCategoryProvider);
  return gearReviewsRepository.fetchReviews(category: category);
});

