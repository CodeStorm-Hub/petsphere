import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/pet_model.dart';
import '../models/post_model.dart';
import '../utils/search_query_escape.dart';

class SearchRepository {
  final _client = Supabase.instance.client;

  /// Must match [FeedRepository.fetchPosts] / [PostModel.fromJson] (embed is `comments`, not `post_comments`).
  static const _postSelect = '*, pets!posts_pet_id_fkey(*), post_likes(pet_id), '
      'comments(*, pets!comments_pet_id_fkey(name, id))';

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

    return (response as List).map((json) => PostModel.fromJson(json)).toList();
  }

  Future<List<PetModel>> searchPets(String query) async {
    if (query.isEmpty) return [];
    final safe = escapeIlikePattern(query);
    if (safe.isEmpty) return [];

    final response = await _client
        .from('pets')
        .select('*')
        .or(
          'name.ilike.%$safe%,breed.ilike.%$safe%,animal_type.ilike.%$safe%',
        )
        .limit(20);

    return (response as List).map((json) => PetModel.fromJson(json)).toList();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) return [];
    final safe = escapeIlikePattern(query);
    if (safe.isEmpty) return [];

    final response = await _client
        .from('products')
        .select('*')
        .or(
          'name.ilike.%$safe%,description.ilike.%$safe%,category.ilike.%$safe%',
        )
        .limit(20);

    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }
}

final searchRepository = SearchRepository();
