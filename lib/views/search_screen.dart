import 'package:flutter/material.dart';
import '../widgets/brand_logo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/search_controller.dart';
import 'components/post_card.dart';
import 'components/product_card.dart';
import '../controllers/pet_controller.dart';
import '../controllers/cart_controller.dart';
import '../controllers/feed_controller.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    ref.read(searchProvider.notifier).search(query);
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(searchProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16),
          child: SearchBar(
            controller: _searchController,
            hintText: 'Search pets, posts, products...',
            onChanged: _onSearch,
            onSubmitted: _onSearch,
            leading: const Icon(Icons.search),
            trailing: [
              if (_searchController.text.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchProvider.notifier).clear();
                    setState(() {});
                  },
                ),
            ],
            elevation: WidgetStateProperty.all(0),
            backgroundColor: WidgetStateProperty.all(colorScheme.surfaceContainerHighest.withAlpha(150)),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'Posts'),
            Tab(text: 'Pets'),
            Tab(text: 'Market'),
          ],
        ),
      ),
      body: searchState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _PostsResultTab(searchState: searchState),
                _PetsResultTab(searchState: searchState),
                _ProductsResultTab(searchState: searchState),
              ],
            ),
    );
  }
}

class _PostsResultTab extends ConsumerWidget {
  final SearchState searchState;
  const _PostsResultTab({required this.searchState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (searchState.query.isEmpty) return const _SearchPlaceholder(icon: Icons.explore_outlined, label: 'Discover new stories');
    if (searchState.posts.isEmpty) return const _NoResults();

    final activePet = ref.watch(petProvider).activePet;
    final currentPetId = activePet?.id ?? '';

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: searchState.posts.length,
      itemBuilder: (context, index) {
        final post = searchState.posts[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: PostCard(
            post: post,
            currentPetId: currentPetId,
            onLikeToggle: () => ref.read(feedProvider.notifier).toggleLike(post.id, currentPetId),
            onCommentIconTap: () => context.push('/post/${post.id}'), // Or show comment sheet
            onShareIconTap: () {}, // Implement share
          ),
        );
      },
    );
  }
}

class _PetsResultTab extends StatelessWidget {
  final SearchState searchState;
  const _PetsResultTab({required this.searchState});

  @override
  Widget build(BuildContext context) {
    if (searchState.query.isEmpty) return const _SearchPlaceholder(useBrandIcon: true, label: 'Find furry friends');
    if (searchState.pets.isEmpty) return const _NoResults();

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: searchState.pets.length,
      itemBuilder: (context, index) {
        final pet = searchState.pets[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundImage: pet.profileImageUrl.isNotEmpty ? NetworkImage(pet.profileImageUrl) : null,
            child: pet.profileImageUrl.isEmpty ? const BrandLogo(size: BrandLogoSize.small) : null,
          ),
          title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${pet.animalType} • ${pet.breed}'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => context.push('/pet/${pet.id}'),
        );
      },
    );
  }
}

class _ProductsResultTab extends ConsumerWidget {
  final SearchState searchState;
  const _ProductsResultTab({required this.searchState});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (searchState.query.isEmpty) return const _SearchPlaceholder(icon: Icons.shopping_bag_outlined, label: 'Shop for essentials');
    if (searchState.products.isEmpty) return const _NoResults();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: searchState.products.length,
      itemBuilder: (context, index) {
        final product = searchState.products[index];
        return ProductCard(
          product: product,
          onTap: () => context.push('/product/${product.id}'),
          onAdd: () {
            ref.read(cartProvider.notifier).addProduct(product);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${product.name} added to cart'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }
}

class _SearchPlaceholder extends StatelessWidget {
  final IconData? icon;
  final bool useBrandIcon;
  final String label;
  const _SearchPlaceholder({this.icon, this.useBrandIcon = false, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          useBrandIcon
              ? BrandLogo(customSize: 64, color: colorScheme.outlineVariant)
              : Icon(icon!, size: 64, color: colorScheme.outlineVariant),
          const SizedBox(height: 16),
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16)),
        ],
      ),
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: colorScheme.error.withAlpha(100)),
          const SizedBox(height: 16),
          Text('No matches found', style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 16)),
        ],
      ),
    );
  }
}
