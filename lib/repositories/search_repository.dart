import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';
import '../models/pet_model.dart';
import '../models/post_model.dart';

class SearchRepository {
  final _client = Supabase.instance.client;

  Future<List<PostModel>> searchPosts(String query) async {
    if (query.isEmpty) return [];
    
    final response = await _client
        .from('posts')
        .select('*, pets(*), post_likes(pet_id), post_comments(*, pets(*))')
        .ilike('caption', '%$query%')
        .order('created_at', ascending: false)
        .limit(20);

    return (response as List).map((json) => PostModel.fromJson(json)).toList();
  }

  Future<List<PetModel>> searchPets(String query) async {
    if (query.isEmpty) return [];

    final response = await _client
        .from('pets')
        .select('*')
        .or('name.ilike.%$query%,breed.ilike.%$query%,animal_type.ilike.%$query%')
        .limit(20);

    return (response as List).map((json) => PetModel.fromJson(json)).toList();
  }

  Future<List<ProductModel>> searchProducts(String query) async {
    if (query.isEmpty) return [];

    final response = await _client
        .from('products')
        .select('*')
        .or('name.ilike.%$query%,description.ilike.%$query%,category.ilike.%$query%')
        .limit(20);

    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }
}

final searchRepository = SearchRepository();
