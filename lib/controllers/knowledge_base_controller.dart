import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/knowledge_base_models.dart';
import '../repositories/feature_repositories.dart';

class KnowledgeBaseCategoryNotifier extends Notifier<String> {
  @override
  String build() => 'All Topics';
  void set(String category) => state = category;
}

final knowledgeBaseCategoryProvider =
    NotifierProvider<KnowledgeBaseCategoryNotifier, String>(() {
  return KnowledgeBaseCategoryNotifier();
});

class KnowledgeBaseSearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';
  void set(String query) => state = query;
}

final knowledgeBaseSearchQueryProvider =
    NotifierProvider<KnowledgeBaseSearchQueryNotifier, String>(() {
  return KnowledgeBaseSearchQueryNotifier();
});

final featuredArticlesProvider = FutureProvider<List<KnowledgeArticle>>((ref) async {
  return ref.watch(knowledgeBaseRepositoryProvider).fetchFeaturedArticles();
});

final knowledgeBaseArticlesProvider = FutureProvider<List<KnowledgeArticle>>((ref) async {
  final category = ref.watch(knowledgeBaseCategoryProvider);
  final query = ref.watch(knowledgeBaseSearchQueryProvider);
  return ref.watch(knowledgeBaseRepositoryProvider).fetchArticles(
    category: category,
    query: query,
  );
});

final knowledgeBaseRepositoryProvider = Provider((ref) => knowledgeBaseRepository);
