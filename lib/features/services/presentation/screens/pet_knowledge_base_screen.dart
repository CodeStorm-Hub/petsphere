import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petfolio/core/constants/app_routes.dart';
import 'package:petfolio/features/services/presentation/controllers/knowledge_base_controller.dart';
import 'package:petfolio/features/services/data/models/knowledge_base_models.dart';
import 'package:petfolio/core/widgets/async_value_widget.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:petfolio/core/widgets/petfolio_widgets.dart';

class PetKnowledgeBaseScreen extends ConsumerWidget {
  const PetKnowledgeBaseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final category = ref.watch(knowledgeBaseCategoryProvider);
    final featuredAsync = ref.watch(featuredArticlesProvider);
    final articlesAsync = ref.watch(knowledgeBaseArticlesProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: PetFolioGradientBackground(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              title: Text(
                'Pet Knowledge Base',
                style: GoogleFonts.playfairDisplay(fontWeight: FontWeight.bold),
              ),
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.bookmarks_outlined),
                  onPressed: () {
                    // TODO: Implement saved articles
                  },
                ),
              ],
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _SearchBar(ref: ref),
            ),
          ),
          SliverToBoxAdapter(
            child: _CategorySelector(ref: ref, selectedCategory: category),
          ),
          if (category == 'All Topics') ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                child: Text(
                  'Featured Articles',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SizedBox(
                height: 220,
                child: AsyncValueWidget<List<KnowledgeArticle>>(
                  value: featuredAsync,
                  data: (List<KnowledgeArticle> articles) => ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: articles.length,
                    itemBuilder: (context, index) => _FeaturedArticleCard(
                      article: articles[index],
                    ),
                  ),
                ),
              ),
            ),
          ],
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                category == 'All Topics' ? 'Recent Articles' : '$category Articles',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          AsyncValueSliverWidget<List<KnowledgeArticle>>(
            value: articlesAsync,
            data: (articles) {
              if (articles.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No articles found matching your criteria.')),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _ArticleListItem(article: articles[index]),
                    childCount: articles.length,
                  ),
                ),
              );
            },
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    ),
    );
  }
}

class _SearchBar extends StatelessWidget {

  const _SearchBar({required this.ref});
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: (val) => ref.read(knowledgeBaseSearchQueryProvider.notifier).set(val),
      decoration: InputDecoration(
        hintText: 'Search for advice, tips, or health...',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CategorySelector extends StatelessWidget {

  const _CategorySelector({required this.ref, required this.selectedCategory});
  final WidgetRef ref;
  final String selectedCategory;

  static const categories = [
    'All Topics',
    'Health',
    'Nutrition',
    'Training',
    'Behavior',
    'Safety',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: categories.map((cat) {
          final isSelected = cat == selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              onSelected: (_) =>
                  ref.read(knowledgeBaseCategoryProvider.notifier).set(cat),
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              labelStyle: GoogleFonts.dmSans(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimaryContainer
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FeaturedArticleCard extends StatelessWidget {

  const _FeaturedArticleCard({required this.article});
  final KnowledgeArticle article;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        child: InkWell(
          onTap: () => context.push(AppRoutes.articleDetail, extra: article),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (article.imageUrl != null)
                CachedNetworkImage(
                  imageUrl: article.imageUrl!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              else
                Container(
                  height: 120,
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  child: Center(
                    child: Icon(
                      Icons.article_outlined,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            article.category.toUpperCase(),
                            style: GoogleFonts.dmSans(
                              fontSize: 10,
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (article.isExpertVerified) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.dmSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn().slideX(begin: 0.2);
  }
}

class _ArticleListItem extends StatelessWidget {

  const _ArticleListItem({required this.article});
  final KnowledgeArticle article;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: InkWell(
          onTap: () => context.push(AppRoutes.articleDetail, extra: article),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                  ),
                  child: article.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: article.imageUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.menu_book,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        article.category,
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.dmSans(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${article.readTime ?? '5 min'} read • ${article.isExpertVerified ? "Verified" : "Community"}',
                        style: GoogleFonts.dmSans(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn().slideY(begin: 0.1);
  }
}

class AsyncValueSliverWidget<T> extends StatelessWidget {

  const AsyncValueSliverWidget({
    super.key,
    required this.value,
    required this.data,
  });
  final AsyncValue<T> value;
  final Widget Function(T) data;

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      error: (e, st) => SliverToBoxAdapter(
        child: Center(child: Text('Error: $e')),
      ),
      loading: () => const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
