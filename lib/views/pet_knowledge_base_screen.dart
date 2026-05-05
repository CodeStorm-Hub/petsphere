import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PetKnowledgeBaseScreen extends ConsumerStatefulWidget {
  const PetKnowledgeBaseScreen({super.key});

  @override
  ConsumerState<PetKnowledgeBaseScreen> createState() => _PetKnowledgeBaseScreenState();
}

class _PetKnowledgeBaseScreenState extends ConsumerState<PetKnowledgeBaseScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  _KnowledgeSearch(controller: _searchController),
                  const SizedBox(height: 28),
                  _CategorySection(),
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
                tabs: const [
                  Tab(text: 'All Topics'),
                  Tab(text: 'Health & Wellness'),
                  Tab(text: 'Behavioral Tips'),
                  Tab(text: 'Expert Guides'),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _FeaturedArticle(),
                const SizedBox(height: 24),
                Text('Popular This Week', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _ArticleTile(
                  title: 'Understanding Your Dog\'s Body Language',
                  readTime: '5 min',
                  category: 'Behavior',
                  image: 'https://images.unsplash.com/photo-1548199973-03cce0bbc87b',
                  isExpertVerified: true,
                ),
                _ArticleTile(
                  title: 'The Best Superfoods for Senior Cats',
                  readTime: '8 min',
                  category: 'Nutrition',
                  image: 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba',
                ),
                _ArticleTile(
                  title: 'How to Prepare for Your First Vet Visit',
                  readTime: '12 min',
                  category: 'Health',
                  image: 'https://images.unsplash.com/photo-1530281700549-e82e7bf110d6',
                  isExpertVerified: true,
                ),
                const SizedBox(height: 40),
              ]),
            ),
          ),
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
  const _KnowledgeSearch({required this.controller});

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
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
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categories = [
      {'label': 'Health', 'icon': Icons.medical_services_rounded, 'color': colorScheme.primary},
      {'label': 'Nutrition', 'icon': Icons.restaurant_rounded, 'color': colorScheme.tertiary},
      {'label': 'Training', 'icon': Icons.psychology_rounded, 'color': colorScheme.secondary},
      {'label': 'First Aid', 'icon': Icons.healing_rounded, 'color': colorScheme.error},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: categories.map((cat) => _CategoryItem(
        label: cat['label'] as String,
        icon: cat['icon'] as IconData,
        color: cat['color'] as Color,
      )).toList(),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _CategoryItem({required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
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
    );
  }
}

class _FeaturedArticle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        image: const DecorationImage(
          image: NetworkImage('https://images.unsplash.com/photo-1544568100-847a948585b9'),
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
            const Text(
              'Summer Pet Safety: Essential Tips for Hot Days',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, height: 1.1, letterSpacing: -0.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  final String title;
  final String readTime;
  final String category;
  final String image;
  final bool isExpertVerified;

  const _ArticleTile({
    required this.title,
    required this.readTime,
    required this.category,
    required this.image,
    this.isExpertVerified = false,
  });

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
              child: Image.network(image, width: 110, height: 110, fit: BoxFit.cover),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(category.toUpperCase(), style: TextStyle(color: colorScheme.primary, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                      if (isExpertVerified) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.verified_rounded, color: colorScheme.secondary, size: 14),
                      ],
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, height: 1.2, letterSpacing: -0.3)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(color: colorScheme.surfaceContainerHigh, shape: BoxShape.circle),
                        child: Icon(Icons.access_time_rounded, size: 12, color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: 6),
                      Text('$readTime read', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 12, fontWeight: FontWeight.w600)),
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
