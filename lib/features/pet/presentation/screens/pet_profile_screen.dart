import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/features/social/presentation/controllers/follow_controller.dart';
import 'package:petfolio/core/widgets/petfolio_widgets.dart';
import 'package:petfolio/core/constants/app_routes.dart';
import 'package:petfolio/core/utils/format_utils.dart';

class PetProfileScreen extends ConsumerStatefulWidget {
  const PetProfileScreen({super.key, required this.petId});
  final String petId;

  @override
  ConsumerState<PetProfileScreen> createState() => _PetProfileScreenState();
}

class _PetProfileScreenState extends ConsumerState<PetProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petProvider);
    // Find the pet by ID from myPets
    final pet = petState.myPets.where((p) => p.id == widget.petId).firstOrNull;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final followerCountAsync = ref.watch(petFollowerCountProvider(widget.petId));

    if (pet == null) {
      return _buildEmptyState(context, cs);
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, pet, cs),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildProfileHeader(context, pet, cs, followerCountAsync),
                    _buildActionButtons(context, pet, cs),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: cs.primary,
                    labelColor: cs.primary,
                    unselectedLabelColor: cs.onSurfaceVariant,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on_rounded), text: 'Photos'),
                      Tab(icon: Icon(Icons.emoji_events_outlined), text: 'Awards'),
                      Tab(
                        icon: Icon(Icons.health_and_safety_outlined),
                        text: 'Health',
                      ),
                    ],
                  ),
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPhotosGrid(pet),
                    _buildAchievementsTab(cs),
                    _buildHealthSummaryTab(pet, cs),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

  }

  Widget _buildSliverAppBar(BuildContext context, PetModel pet, ColorScheme cs) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      stretch: true,
      backgroundColor: cs.surface,
      actions: [
        IconButton(
          onPressed: () async {
            await SharePlus.instance.share(
              ShareParams(
                text: 'Check out ${pet.name} on PetFolio! ${pet.breed} looking for friends.',
              ),
            );
          },
          icon: const Icon(Icons.share_outlined),
        ),
        IconButton(
          key: const ValueKey('pet_profile_settings_button'),
          onPressed: () => context.push(AppRoutes.settings),
          icon: const Icon(Icons.settings_outlined),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (pet.profileImageUrl.isNotEmpty)
              CachedNetworkImage(
                imageUrl: pet.profileImageUrl,
                fit: BoxFit.cover,
              )
            else
              Container(
                color: cs.primaryContainer,
                child: Icon(Icons.pets, size: 80, color: cs.primary),
              ),
            // Gradient Overlay
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.7),
                  ],
                  stops: const [0.0, 0.2, 0.7, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    PetModel pet,
    ColorScheme cs,
    AsyncValue<int> followerCountAsync,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          pet.name,
                          style: GoogleFonts.playfairDisplay(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: cs.onSurface,
                          ),
                        ),
                        if (pet.isVerified) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.verified, size: 24, color: cs.primary),
                        ],
                      ],
                    ),
                    Text(
                      '${pet.animalType} • ${pet.breed.isEmpty ? 'Unknown Breed' : pet.breed}',
                      style: GoogleFonts.dmSans(
                        fontSize: 16,
                        color: cs.onSurfaceVariant,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              followerCountAsync.when(
                data: (count) => _buildStatItem(
                  context,
                  FormatUtils.formatCount(count),
                  'Fans',
                  cs,
                ),
                loading: () => _buildStatItem(context, '…', 'Fans', cs),
                error: (error, stack) => _buildStatItem(context, '0', 'Fans', cs),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (pet.bio.isNotEmpty)
            Text(
              pet.bio,
              style: GoogleFonts.dmSans(
                fontSize: 15,
                height: 1.5,
                color: cs.onSurface,
              ),
            ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildInfoChip(
                context,
                Icons.cake_outlined,
                '${pet.age} years old',
                cs,
              ),
              const SizedBox(width: 8),
              if (pet.isVaccinated)
                _buildInfoChip(
                  context,
                  Icons.health_and_safety_outlined,
                  'Vaccinated',
                  cs,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String value,
    String label,
    ColorScheme cs,
  ) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.dmSans(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: cs.onSurface,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.dmSans(fontSize: 12, color: cs.onSurfaceVariant),
        ),
      ],
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String label,
    ColorScheme cs,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: cs.secondaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cs.secondaryContainer),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: cs.onSecondaryContainer),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: cs.onSecondaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    PetModel pet,
    ColorScheme cs,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              key: const ValueKey('pet_profile_edit_button'),
              onPressed: () => context.push(AppRoutes.addPet, extra: pet),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.edit_outlined, size: 20),
              label: const Text('Edit Profile'),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              key: const ValueKey('pet_profile_new_post_button'),
              onPressed: () => context.push('${AppRoutes.createPost}?petId=${pet.id}'),
              icon: Icon(Icons.add_a_photo_outlined, color: cs.primary),
              tooltip: 'New Post',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotosGrid(PetModel pet) {
    // Placeholder grid
    return GridView.builder(
      padding: const EdgeInsets.all(1),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,
      ),
      itemCount: 15,
      itemBuilder: (context, index) {
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          child: Icon(
            Icons.image_outlined,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(
              alpha: 0.2,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAchievementsTab(ColorScheme cs) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.emoji_events)),
            title: Text('Alpha Barker ${index + 1}'),
            subtitle: const Text('Unlocked for 50+ social interactions'),
            trailing: Icon(Icons.chevron_right, color: cs.primary),
          ),
        );
      },
    );
  }

  Widget _buildHealthSummaryTab(PetModel pet, ColorScheme cs) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildHealthCard(
          'Daily Activity',
          '85%',
          Icons.directions_run,
          Colors.orange,
          cs,
        ),
        _buildHealthCard(
          'Nutrition',
          '${pet.dailyCalorieGoal ?? 800} kcal',
          Icons.restaurant,
          Colors.green,
          cs,
        ),
        _buildHealthCard(
          'Hydration',
          '${pet.dailyWaterGoalCups ?? 4} cups',
          Icons.water_drop,
          Colors.blue,
          cs,
        ),
        const SizedBox(height: 16),
        OutlinedButton(
          onPressed: () => context.push(AppRoutes.petMedicalRecordsById(pet.id)),
          child: const Text('View Full Health Report'),
        ),
      ],
    );
  }

  Widget _buildHealthCard(
    String title,
    String value,
    IconData icon,
    Color color,
    ColorScheme cs,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    value,
                    style: GoogleFonts.dmSans(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ColorScheme cs) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: PetfolioEmptyState(
        icon: Icons.pets_rounded,
        title: 'No active pet selected',
        message: 'Add a pet to start building your PetFolio and connect with other pet lovers.',
        buttonText: 'Add Your First Pet',
        onButtonPressed: () => context.push(AppRoutes.addPet),
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

