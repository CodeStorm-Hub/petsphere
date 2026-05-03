import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/match_controller.dart';
import 'components/pet_avatar.dart';

class LikedPetsScreen extends ConsumerWidget {
  const LikedPetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final sentRequests = ref.watch(matchProvider).sentRequests;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pets You Liked'),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(matchProvider.notifier).refresh(),
        child: sentRequests.isEmpty
            ? ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.favorite_border,
                            size: 64, color: colorScheme.onSurfaceVariant),
                        const SizedBox(height: 16),
                        Text(
                          'No likes yet',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Pets you like will appear here.',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
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
                      leading: const CircleAvatar(child: Icon(Icons.pets)),
                      title: const Text('Unknown pet'),
                      subtitle: _statusLabel(context, req.status),
                    );
                  }

                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    leading:
                        PetAvatar(imageUrl: pet.profileImageUrl, radius: 24),
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
