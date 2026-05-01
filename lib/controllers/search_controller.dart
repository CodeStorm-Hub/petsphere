import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../models/pet_model.dart';
import '../models/product_model.dart';
import '../repositories/search_repository.dart';

class SearchState {
  final List<PostModel> posts;
  final List<PetModel> pets;
  final List<ProductModel> products;
  final bool isLoading;
  final String? error;
  final String query;

  SearchState({
    this.posts = const [],
    this.pets = const [],
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.query = '',
  });

  SearchState copyWith({
    List<PostModel>? posts,
    List<PetModel>? pets,
    List<ProductModel>? products,
    bool? isLoading,
    String? error,
    String? query,
  }) {
    return SearchState(
      posts: posts ?? this.posts,
      pets: pets ?? this.pets,
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() {
    return SearchState();
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = SearchState(query: query);
      return;
    }

    state = state.copyWith(isLoading: true, query: query, error: null);

    try {
      final results = await Future.wait([
        searchRepository.searchPosts(query),
        searchRepository.searchPets(query),
        searchRepository.searchProducts(query),
      ]);

      state = state.copyWith(
        posts: results[0] as List<PostModel>,
        pets: results[1] as List<PetModel>,
        products: results[2] as List<ProductModel>,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void clear() {
    state = SearchState();
  }
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(() {
  return SearchNotifier();
});
