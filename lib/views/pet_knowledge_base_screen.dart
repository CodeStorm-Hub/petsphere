import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/knowledge_base_controller.dart';
import '../models/knowledge_base_models.dart';

class PetKnowledgeBaseScreen extends ConsumerStatefulWidget {
  const PetKnowledgeBaseScreen({super.key});

  @override
  ConsumerState<PetKnowledgeBaseScreen> createState() => _PetKnowledgeBaseScreenState();
}

class _PetKnowledgeBaseScreenState extends ConsumerState<PetKnowledgeBaseScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  final List<String> _tabs = [
    'All Topics',
    'Health',
    'Nutrition',
    'Behavior',
    'Expert Guides',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(knowledgeBaseCategoryProvider.notifier).set(_tabs[_tabController.index]);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featuredAsync = ref.watch(featuredArticlesProvider);
    final articlesAsync = ref.watch(knowledgeBaseArticlesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            title: const Text('Knowledge Hub'),
            actions: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.bookmark_outline_rounded)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.more_vert_rounded)),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _KnowledgeSearch(
                    controller: _searchController,
                    onChanged: (val) => ref.read(knowledgeBaseSearchQueryProvider.notifier).set(val),
                  ),
                  const SizedBox(height: 28),
                  _CategorySection(
                    onCategoryTap: (cat) {
                      final index = _tabs.indexOf(cat);
                      if (index != -1) _tabController.animateTo(index);
                    },
                  ),
                  const SizedBox(height: 36),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                dividerColor: Colors.transparent,
                tabs: _tabs.map((t) => Tab(text: t)).toList(),
              ),
            ),
          ),
          featuredAsync.when(
            data: (featured) => featured.isEmpty 
              ? const SliverToBoxAdapter(child: SizedBox.shrink())
              : SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  sliver: SliverToBoxAdapter(child: _FeaturedArticle(article: featured.first)),
                ),
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
          ),
          articlesAsync.when(
            data: (articles) => SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text('Recent Articles', 
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      );
                    }
                    final article = articles[index - 1];
                    return _ArticleTile(article: article);
                  },
                  childCount: articles.isEmpty ? 0 : articles.length + 1,
                ),
              ),
            ),
            loading: () => const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator())),
            error: (e, _) => SliverToBoxAdapter(child: Text('Error: $e')),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _KnowledgeSearch extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _KnowledgeSearch({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
      onChanged: onChanged,
      hintText: 'Search for tips, health advice...',
      leading: const Icon(Icons.search_rounded),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(Theme.of(context).colorScheme.surfaceContainerHigh),
      shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
    );
  }
}

class _CategorySection extends StatelessWidget {
  final ValueChanged<String> onCategoryTap;
  const _CategorySection({required this.onCategoryTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = [
      {'label': 'Health', 'icon': Icons.medical_services_rounded, 'color': colorScheme.primary},
      {'label': 'Nutrition', 'icon': Icons.restaurant_rounded, 'color': colorScheme.tertiary},
      {'label': 'Behavior', 'icon': Icons.psychology_rounded, 'color': colorScheme.secondary},
      {'label': 'First Aid', 'icon': Icons.healing_rounded, 'color': colorScheme.error},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((cat) => _CategoryItem(
        label: cat['label'] as String,
        icon: cat['icon'] as IconData,
        color: cat['color'] as Color,
        onTap: () => onCategoryTap(cat['label'] as String),
      )).toList(),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryItem({required this.label, required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: color.withAlpha(40)),
              boxShadow: [BoxShadow(color: color.withAlpha(10), blurRadius: 12, offset: const Offset(0, 4))],
            ),
            child: Icon(icon, color: color, size: 30),
          ),
          const SizedBox(height: 10),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: -0.2)),
        ],
      ),
    );
  }
}

class _FeaturedArticle extends StatelessWidget {
  final KnowledgeArticle article;
  const _FeaturedArticle({required this.article});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: DecorationImage(
          image: NetworkImage(article.imageUrl ?? 'https://images.unsplash.com/photo-1544568100-847a948585b9'),
          fit: BoxFit.cover,
        ),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          gradient: LinearGradient(
            colors: [Colors.black.withAlpha(200), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            stops: const [0.0, 0.7],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: colorScheme.primary, borderRadius: BorderRadius.circular(10)),
              child: const Text('NEW GUIDE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1)),
            ),
            const SizedBox(height: 12),
            Text(
              article.title,
              style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  final KnowledgeArticle article;

  const _ArticleTile({required this.article});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(24),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                article.imageUrl ?? 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b',
                width: 110,
                height: 110,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(article.category.toUpperCase(), style: TextStyle(color: colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                      if (article.isExpertVerified) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.verified_rounded, color: colorScheme.secondary, size: 14),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(article.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, height: 1.2, letterSpacing: -0.3)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: colorScheme.surfaceContainerHigh, shape: BoxShape.circle),
                        child: Icon(Icons.access_time_rounded, size: 12, color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 6),
                      Text('${article.readTime ?? '5 min'} read', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
