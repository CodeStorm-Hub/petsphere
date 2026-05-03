import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../controllers/follow_controller.dart';
import '../controllers/pet_controller.dart';

class PetFollowersScreen extends ConsumerWidget {
  final String petId;

  const PetFollowersScreen({super.key, required this.petId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final followersAsync = ref.watch(petFollowersListProvider(petId));
    final petState = ref.watch(petProvider);
    final colorScheme = Theme.of(context).colorScheme;

    final petName = petState.myPets.any((p) => p.id == petId)
        ? petState.myPets.firstWhere((p) => p.id == petId).name
        : '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Followers',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
                color: colorScheme.onSurface,
              ),
            ),
            if (petName.isNotEmpty)
              Text(
                petName,
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
      body: followersAsync.when(
        loading: () => _buildShimmer(colorScheme),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 48, color: colorScheme.error),
              const SizedBox(height: 12),
              Text(
                'Could not load followers',
                style: TextStyle(color: colorScheme.onSurface, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => ref.invalidate(petFollowersListProvider(petId)),
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (followers) => followers.isEmpty
            ? _buildEmpty(context, colorScheme)
            : RefreshIndicator(
                onRefresh: () async =>
                    ref.invalidate(petFollowersListProvider(petId)),
                child: ListView.separated(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: followers.length,
                  separatorBuilder: (_, _) => Divider(
                    height: 1,
                    color: colorScheme.outlineVariant.withAlpha(60),
                  ),
                  itemBuilder: (context, index) {
                    final follower = followers[index];
                    return _FollowerTile(
                      name: follower['name'] as String,
                      imageUrl: follower['profile_image_url'] as String,
                      followedAt: follower['created_at'] as String?,
                      colorScheme: colorScheme,
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
              Icons.people_outline_rounded,
              size: 36,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No followers yet',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Share your pet profile to attract followers!',
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

class _FollowerTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final String? followedAt;
  final ColorScheme colorScheme;

  const _FollowerTile({
    required this.name,
    required this.imageUrl,
    required this.followedAt,
    required this.colorScheme,
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
    final dateLabel = _formatDate(followedAt);

    return ListTile(
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
      subtitle: dateLabel.isNotEmpty
          ? Text(
              'Followed $dateLabel',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : null,
      trailing: Icon(
        Icons.person_outline_rounded,
        color: colorScheme.onSurfaceVariant,
        size: 20,
      ),
    );
  }
}