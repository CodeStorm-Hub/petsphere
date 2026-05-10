import 'package:petfolio/core/constants/supabase_config.dart';
import 'package:petfolio/features/marketplace/data/models/gear_review_models.dart';

class GearReviewsRepository {
  final _db = supabase;

  Future<List<GearReview>> fetchReviews({String? category}) async {
    var request = _db.from('gear_reviews').select();
    if (category != null && category != 'All') {
      request = request.eq('category', category);
    }
    final rows = await request.order('created_at', ascending: false);
    return (rows as List)
        .map((e) => GearReview.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<GearReview> submitReview(GearReview review) async {
    final json = review.toJson()..remove('id');
    final row = await _db
        .from('gear_reviews')
        .insert(json)
        .select()
        .single();
    return GearReview.fromJson(row);
  }
}

final gearReviewsRepository = GearReviewsRepository();
