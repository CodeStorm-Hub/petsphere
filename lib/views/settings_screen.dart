import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart' as share_plus;
import 'package:url_launcher/url_launcher.dart';
import '../controllers/auth_controller.dart';
import '../controllers/notification_controller.dart';
import '../controllers/pet_care_controller.dart';
import '../controllers/pet_controller.dart';
import '../controllers/theme_controller.dart';
import '../models/care_badge_model.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    final unread = ref.watch(notificationProvider.select((s) => s.unreadCount));
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _SectionHeader(label: 'Appearance'),
          _ThemeToggleTile(),
          const Divider(),
          _SectionHeader(label: 'Account'),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primary.withAlpha(30),
              backgroundImage: user?.profileImageUrl != null &&
                      user!.profileImageUrl!.isNotEmpty
                  ? NetworkImage(user.profileImageUrl!)
                  : null,
              child: user?.profileImageUrl == null ||
                      user!.profileImageUrl!.isEmpty
                  ? Text(user?.initials ?? '?',
                      style: TextStyle(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.bold))
                  : null,
            ),
            title: Text(user?.name ?? 'Guest'),
            subtitle: Text(user?.email ?? ''),
          ),
          const Divider(),
          _SectionHeader(label: 'Preferences'),
          ListTile(
            leading: const Icon(Icons.notifications_active_outlined),
            title: const Text('Notifications'),
            subtitle: Text(unread > 0 ? '$unread unread' : 'All caught up'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/notifications'),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border),
            title: const Text('Liked pets'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/liked_pets'),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('Order history'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push('/orders'),
          ),
          const Divider(),
          _SectionHeader(label: 'Achievements & Badges'),
          const _AchievementsBadgesSection(),
          const Divider(),
          _SectionHeader(label: 'About'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => launchUrl(Uri.parse('https://petsphere.app/privacy')),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => launchUrl(Uri.parse('https://petsphere.app/terms')),
          ),
          ListTile(
            leading: const Icon(Icons.support_outlined),
            title: const Text('Help & Support'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => launchUrl(Uri.parse('mailto:support@petsphere.app')),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('App version'),
            subtitle: const Text('1.0.0'),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: FilledButton.icon(
              onPressed: () => _confirmLogout(context, ref),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign Out'),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: colorScheme.errorContainer,
                foregroundColor: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authProvider.notifier).logout();
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}

class _ThemeToggleTile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);
    final isDark = themeMode == ThemeMode.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
        color: colorScheme.primary,
      ),
      title: const Text('Theme'),
      subtitle: Text(isDark ? 'Dark' : 'Light'),
      trailing: Switch(
        value: isDark,
        onChanged: (_) => ref.read(themeProvider.notifier).toggle(),
        activeThumbColor: colorScheme.primary,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          color: colorScheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _AchievementsBadgesSection extends ConsumerWidget {
  const _AchievementsBadgesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final careState = ref.watch(petCareProvider);
    final myPets = ref.watch(petProvider).myPets;
    final defAsync = ref.watch(careBadgeDefinitionsProvider);

    return defAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => const SizedBox.shrink(),
      data: (defs) {
        final bySlug = {for (final d in defs) d.slug: d};
        final allUnlocks = careState.unlocks;

        if (allUnlocks.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    '🏆',
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Start your pet care journey to earn badges!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Log daily care, build streaks, hit milestones.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant.withAlpha(160),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final petUnlockMap = <String, List<PetCareBadgeUnlock>>{};
        for (final u in allUnlocks) {
          petUnlockMap.putIfAbsent(u.petId, () => []).add(u);
        }

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final pet in myPets)
                if (petUnlockMap.containsKey(pet.id)) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: colorScheme.surfaceContainerHighest,
                          backgroundImage: pet.profileImageUrl.isNotEmpty
                              ? NetworkImage(pet.profileImageUrl)
                              : null,
                          child: pet.profileImageUrl.isEmpty
                              ? Icon(Icons.pets,
                                  size: 14, color: colorScheme.primary)
                              : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          pet.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const Spacer(),
                        Text(
                          '${petUnlockMap[pet.id]!.length} badge${petUnlockMap[pet.id]!.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: petUnlockMap[pet.id]!.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) {
                        final unlock = petUnlockMap[pet.id]![i];
                        final def = bySlug[unlock.badgeSlug];
                        if (def == null) return const SizedBox.shrink();
                        return GestureDetector(
                          onTap: () => _showBadgeDialog(
                              context, def, unlock, colorScheme),
                          child: Container(
                            width: 80,
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                  color: colorScheme.primary.withAlpha(60)),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(def.iconEmoji,
                                    style: const TextStyle(fontSize: 28)),
                                const SizedBox(height: 4),
                                Text(
                                  def.title,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
            ],
          ),
        );
      },
    );
  }

  void _showBadgeDialog(
    BuildContext context,
    CareBadgeDefinition def,
    PetCareBadgeUnlock unlock,
    ColorScheme colorScheme,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(def.iconEmoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 12),
            Text(
              def.title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              def.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: colorScheme.onSurfaceVariant, fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              'Earned ${_fmtDate(unlock.unlockedAt)}',
              style: TextStyle(
                color: colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              share_plus.SharePlus.instance.share(
                share_plus.ShareParams(
                  text: 'I just earned the "${def.title}" badge on PetSphere! ${def.iconEmoji} ${def.description}',
                ),
              );
            },
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }
}
