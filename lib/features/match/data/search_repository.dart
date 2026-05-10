import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petsphere/features/marketplace/data/models/product_model.dart';
import 'package:petsphere/features/pet/data/models/pet_model.dart';
import 'package:petsphere/features/social/data/models/post_model.dart';
import 'package:petsphere/core/utils/search_query_escape.dart';

class SearchRepository {
  final _client = Supabase.instance.client;

  /// Must match [FeedRepository.fetchPosts] / [PostModel.fromJson] (embed is `comments`, not `post_comments`).
  static const _postSelect =
      '*, pets!posts_pet_id_fkey(*), post_likes(pet_id), '
      'comments(*, pets!comments_pet_id_fkey(name, id, profile_image_url))';

  Future<List<PostModel>> searchPosts(String query) async {
    if (query.isEmpty) return [];
    final safe = escapeIlikePattern(query);
    if (safe.isEmpty) return [];

    final response = await _client
        .from('posts')
        .select(_postSelect)
        .ilike('caption', '%$safe%')
        .order('created_at', ascending: false)
        .limit(20);

    return (response as List)
        .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<PetModel>> searchPets(String query) async {
    if (query.isEmpty) return [];
    final safe = escapeIlikePattern(query);
    if (safe.isEmpty) return [];

    final response = await _client
        .from('pets')
        .select()
        .or('name.ilike.%$safe%,breed.ilike.%$safe%,animal_type.ilike.%$safe%')
        .limit(20);

    return (response as List)
        .map((json) => PetModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    final safe = escapeIlikePattern(query);
    if (safe.isEmpty) return [];

    final response = await _client
        .from('products')
        .select()
        .or(
          'name.ilike.%$safe%,description.ilike.%$safe%,category.ilike.%$safe%',
        )
        .limit(20);

    return (response as List)
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

final searchRepository = SearchRepository();
