import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../utils/pet_navigation.dart';
import '../controllers/pet_controller.dart';
import '../controllers/follow_controller.dart';

enum FollowListType { petFollowers, ownerFollowers, following }

String _loadErrorMessage(FollowListType type) {
  switch (type) {
    case FollowListType.petFollowers:
      return 'Could not load pet followers';
    case FollowListType.ownerFollowers:
      return 'Could not load followers';
    case FollowListType.following:
      return 'Could not load following';
  }
}

class PetFollowersScreen extends ConsumerWidget {
  final String? petId;
  final String? userId;
  final FollowListType type;

  PetFollowersScreen({
    super.key,
    this.petId,
    this.userId,
    required this.type,
  }) : assert(
          type == FollowListType.petFollowers
              ? (petId != null && petId.isNotEmpty)
              : (userId != null && userId.isNotEmpty),
          'PetFollowersScreen: use petId for petFollowers and userId for ownerFollowers/following.',
        );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    AsyncValue<List<Map<String, dynamic>>> listAsync;
    String title = 'Followers';
    String? subtitle;

    switch (type) {
      case FollowListType.petFollowers:
        listAsync = ref.watch(petFollowersListProvider(petId!));
        title = 'Pet Followers';
        final petState = ref.watch(petProvider);
        if (petState.myPets.any((p) => p.id == petId)) {
          subtitle = petState.myPets.firstWhere((p) => p.id == petId).name;
        }
        break;
      case FollowListType.ownerFollowers:
        listAsync = ref.watch(ownerFollowersListProvider(userId!));
        title = 'Followers';
        break;
      case FollowListType.following:
        listAsync = ref.watch(followingListProvider(userId!));
        title = 'Following';
        break;
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: colorScheme.onSurface,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: listAsync.when(
        loading: () => _buildShimmer(colorScheme),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(
                _loadErrorMessage(type),
                textAlign: TextAlign.center,
                style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  switch (type) {
                    case FollowListType.petFollowers:
                      ref.invalidate(petFollowersListProvider(petId!));
                      break;
                    case FollowListType.ownerFollowers:
                      ref.invalidate(ownerFollowersListProvider(userId!));
                      break;
                    case FollowListType.following:
                      ref.invalidate(followingListProvider(userId!));
                      break;
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (list) => list.isEmpty
            ? _buildEmpty(context, colorScheme)
            : RefreshIndicator(
                onRefresh: () async {
                  switch (type) {
                    case FollowListType.petFollowers:
                      ref.invalidate(petFollowersListProvider(petId!));
                      break;
                    case FollowListType.ownerFollowers:
                      ref.invalidate(ownerFollowersListProvider(userId!));
                      break;
                    case FollowListType.following:
                      ref.invalidate(followingListProvider(userId!));
                      break;
                  }
                },
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: colorScheme.outlineVariant.withAlpha(60),
                  ),
                  itemBuilder: (context, index) {
                    final item = list[index];
                    // The following list and follower list have slightly different structures
                    final String name = item['name'] ?? 'Unknown';
                    final String imageUrl =
                        (item['profile_image_url'] ?? item['image_url']) ?? '';
                    final String? date = item['created_at'] as String?;
                    final String? typeLabel = item['type'] as String?;

                    final String targetId =
                        (item['user_id'] ?? item['id']) as String;
                    final bool isPet = typeLabel == 'pet';

                    return _FollowTile(
                      name: name,
                      imageUrl: imageUrl,
                      date: date,
                      typeLabel: typeLabel,
                      colorScheme: colorScheme,
                      onTap: () {
                        if (isPet) {
                          openPetProfile(context, ref, petId: targetId);
                        } else {
                          openUserProfile(context, ref, userId: targetId);
                        }
                      },
                    );
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context, ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withAlpha(80),
              shape: BoxShape.circle,
            ),
            child: Icon(
              type == FollowListType.following
                  ? Icons.person_add_outlined
                  : Icons.people_outline_rounded,
              size: 36,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            type == FollowListType.following
                ? 'Not following anyone yet'
                : 'No followers yet',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            type == FollowListType.following
                ? 'Follow pets and owners to see them here!'
                : 'Share profile to attract followers!',
            style: TextStyle(color: colorScheme.onSurfaceVariant, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer(ColorScheme colorScheme) {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (_, _) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 13,
                    width: 130,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    height: 11,
                    width: 80,
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest.withAlpha(150),
                      borderRadius: BorderRadius.circular(6),
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
}

class _FollowTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String? date;
  final String? typeLabel;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;

  const _FollowTile({
    required this.name,
    required this.imageUrl,
    required this.date,
    this.typeLabel,
    required this.colorScheme,
    this.onTap,
  });

  String _formatDate(String? isoString) {
    if (isoString == null) return '';
    try {
      final dt = DateTime.parse(isoString).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays < 1) return 'Today';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
      return DateFormat('MMM d, yyyy').format(dt);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatDate(date);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 23,
        backgroundColor: colorScheme.primaryContainer,
        backgroundImage: imageUrl.isNotEmpty
            ? CachedNetworkImageProvider(imageUrl)
            : null,
        child: imageUrl.isEmpty
            ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(
                  color: colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        name,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: colorScheme.onSurface,
        ),
      ),
      subtitle: Row(
        children: [
          if (typeLabel != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                typeLabel!.toUpperCase(),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (dateLabel.isNotEmpty)
            Text(
              'Since $dateLabel',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      trailing: Icon(
        typeLabel == 'pet' ? Icons.pets_rounded : Icons.person_outline_rounded,
        color: colorScheme.onSurfaceVariant,
        size: 20,
      ),
    );
  }
}