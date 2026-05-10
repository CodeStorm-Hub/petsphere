import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/care_gamification_controller.dart';

/// Renders showcased care badges for a profile [userId] (owner tab / public profile).
class PublicCareBadgesRow extends ConsumerWidget {
  const PublicCareBadgesRow({super.key, required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final async = ref.watch(publicCareBadgeShowcaseProvider(userId));
    return async.when(
      data: (defs) {
        if (defs.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Care badges',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final d in defs)
                    Chip(
                      avatar: Text(
                        d.iconEmoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      label: Text(
                        d.title,
                        style: const TextStyle(fontSize: 13),
                      ),
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
