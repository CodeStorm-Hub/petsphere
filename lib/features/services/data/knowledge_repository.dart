import 'package:petfolio/core/constants/supabase_config.dart';
import 'package:petfolio/features/services/data/models/knowledge_base_models.dart';

class KnowledgeBaseRepository {
  final _db = supabase;

  Future<List<KnowledgeArticle>> fetchArticles({
    String? category,
    String? query,
  }) async {
    var request = _db.from('knowledge_base_articles').select();

    if (category != null && category != 'All Topics') {
      request = request.eq('category', category);
    }

    if (query != null && query.isNotEmpty) {
      request = request.ilike('title', '%$query%');
    }

    final rows = await request.order('created_at', ascending: false);
    return (rows as List)
        .map((e) => KnowledgeArticle.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<KnowledgeArticle>> fetchFeaturedArticles() async {
    final rows = await _db
        .from('knowledge_base_articles')
        .select()
        .eq('is_featured', true)
        .limit(5);
    return (rows as List)
        .map((e) => KnowledgeArticle.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final knowledgeBaseRepository = KnowledgeBaseRepository();
