import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:petfolio/core/utils/pet_navigation.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/social/presentation/controllers/follow_controller.dart';

import 'package:petfolio/core/widgets/petfolio_empty_state.dart';

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

  PetFollowersScreen({super.key, this.petId, this.userId, required this.type})
    : assert(
        type == FollowListType.petFollowers
            ? (petId != null && petId.isNotEmpty)
            : (userId != null && userId.isNotEmpty),
        'PetFollowersScreen: use petId for petFollowers and userId for ownerFollowers/following.',
      );
  final String? petId;
  final String? userId;
  final FollowListType type;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;

    AsyncValue<List<Map<String, dynamic>>> listAsync;
    var title = 'Followers';
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
        error: (e, _) => PetfolioEmptyState(
          icon: Icons.error_outline_rounded,
          title: _loadErrorMessage(type),
          message: e.toString(),
          buttonText: 'Retry',
          onButtonPressed: () {
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
          buttonIcon: Icons.refresh_rounded,
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
                    final name = (item['name'] as String?) ?? 'Unknown';
                    final imageUrl =
                        ((item['profile_image_url'] as String?) ??
                            (item['image_url'] as String?)) ??
                        '';
                    final date = item['created_at'] as String?;
                    final typeLabel = item['type'] as String?;

                    final targetId =
                        (item['user_id'] ?? item['id']) as String;
                    final isPet = typeLabel == 'pet';

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
    return PetfolioEmptyState(
      icon: type == FollowListType.following
          ? Icons.person_add_outlined
          : Icons.people_outline_rounded,
      title: type == FollowListType.following
          ? 'Not following anyone yet'
          : 'No followers yet',
      message: type == FollowListType.following
          ? 'Follow pets and owners to see them here!'
          : 'Share profile to attract followers!',
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

  const _FollowTile({
    required this.name,
    required this.imageUrl,
    required this.date,
    this.typeLabel,
    required this.colorScheme,
    this.onTap,
  });
  final String name;
  final String imageUrl;
  final String? date;
  final String? typeLabel;
  final ColorScheme colorScheme;
  final VoidCallback? onTap;

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
