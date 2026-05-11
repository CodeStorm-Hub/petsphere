import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petfolio/features/match/presentation/controllers/match_requests_controller.dart';
import 'package:petfolio/core/widgets/petfolio_empty_state.dart';
import 'package:petfolio/core/widgets/pet_avatar.dart';
import 'package:petfolio/core/widgets/brand_logo.dart';

class LikedPetsScreen extends ConsumerWidget {
  const LikedPetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sentRequests = ref.watch(
      matchRequestsProvider.select((state) => state.sentRequests),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Pets You Liked')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(matchRequestsProvider.notifier).refresh(),
        child: sentRequests.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 120),
                  PetfolioEmptyState(
                    icon: Icons.favorite_border,
                    title: 'No likes yet',
                    message: 'Pets you like will appear here.',
                  ),
                ],
              )
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: sentRequests.length,
                separatorBuilder: (_, _) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final req = sentRequests[index];
                  final pet = req.receiverPet;

                  if (pet == null) {
                    return ListTile(
                      leading: const CircleAvatar(
                        child: BrandLogo(size: BrandLogoSize.small),
                      ),
                      title: const Text('Unknown pet'),
                      subtitle: _statusLabel(context, req.status),
                    );
                  }

                  return RepaintBoundary(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      leading: PetAvatar(
                        imageUrl: pet.profileImageUrl,
                        radius: 24,
                      ),
                      title: Text(
                        pet.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${pet.breed} · ${pet.age} yrs'),
                          const SizedBox(height: 4),
                          _statusLabel(context, req.status),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/pet/${pet.id}'),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _statusLabel(BuildContext context, String status) {
    final colorScheme = Theme.of(context).colorScheme;
    final Color color;
    final String label;
    switch (status) {
      case 'matched':
        color = colorScheme.secondary;
        label = 'Matched';
      case 'rejected':
        color = colorScheme.error;
        label = 'Declined';
      case 'pending':
        color = colorScheme.tertiary;
        label = 'Pending';
      default:
        color = colorScheme.onSurfaceVariant;
        label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
