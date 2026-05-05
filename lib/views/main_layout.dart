import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/pet_controller.dart';
import '../utils/layout_utils.dart';

import 'home_screen.dart';
import 'pet_profile_screen.dart';
import 'discovery_screen.dart';
import 'marketplace_screen.dart';


// ─────────────────────────────────────────────────────────────────────────────
// MainLayout
// ─────────────────────────────────────────────────────────────────────────────
class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends ConsumerState<MainLayout> {
  int currentIndex = 0;

  static const List<Widget> screens = [
    HomeScreen(),
    DiscoveryScreen(),
    SizedBox.shrink(), // index 2 → /pet_care push, not a tab screen
    MarketplaceScreen(),
    PetProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Navigate to profile tab when a pet is tapped from another screen
    ref.listen<String?>(profilePetNavigationProvider, (prev, next) {
      if (next != null) setState(() => currentIndex = 4);
    });

    ref.listen<int?>(mainLayoutTabRequestProvider, (prev, next) {
      if (next == null) return;
      final idx = next.clamp(0, screens.length - 1);
      if (idx != 2) setState(() => currentIndex = idx);
      ref.read(mainLayoutTabRequestProvider.notifier).clear();
    });

    final activePet = ref.watch(activePetProvider);

    return Scaffold(
      extendBody: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: IndexedStack(
            index: currentIndex,
            children: screens,
          ),
        ),
      ),
      bottomNavigationBar: RepaintBoundary(
        child: PetfolioNavBar(
          currentIndex: currentIndex,
          profileImageUrl: activePet?.profileImageUrl ?? '',
          onTap: (index) {
            // Index 2 is the centre FAB — push a new route, don't switch tab
            if (index == 2) {
              context.push('/pet_care');
              return;
            }
            setState(() => currentIndex = index);
          },
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav item model
// ─────────────────────────────────────────────────────────────────────────────
class NavItem {
  final IconData inactive;
  final IconData active;
  final String label;
  const NavItem(this.inactive, this.active, this.label);
}

// ─────────────────────────────────────────────────────────────────────────────
// PetfolioNavBar — modern floating pill with labels + animations
// ─────────────────────────────────────────────────────────────────────────────
class PetfolioNavBar extends StatelessWidget {
  final int currentIndex;
  final String profileImageUrl;
  final ValueChanged<int> onTap;

  const PetfolioNavBar({
    super.key,
    required this.currentIndex,
    required this.profileImageUrl,
    required this.onTap,
  });

  static const List<NavItem> _items = [
    NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
    NavItem(Icons.search_rounded, Icons.search_rounded, 'Discover'),
    NavItem(Icons.add_rounded, Icons.add_rounded, ''), // centre FAB
    NavItem(Icons.storefront_outlined, Icons.storefront_rounded, 'Shop'),
    NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  /// TalkBack / VoiceOver labels (center index 2 uses [centerFabSemanticLabel]).
  static const List<String> tabSemanticLabels = [
    'Home',
    'Discover',
    '', // placeholder; never read — center slot is not an Expanded tab
    'Marketplace',
    'Profile',
  ];

  static const String centerFabSemanticLabel = 'Pet Care';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final barBg = isDark ? const Color(0xFF1C1C1C) : cs.surface;
    final barBorder =
        isDark ? const Color(0xFF2E2E2E) : cs.outline.withAlpha(55);

    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: kBottomNavBarHeight + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: barBg,
        border: Border(
          top: BorderSide(color: barBorder, width: 1),
        ),
      ),
      child: Row(
        children: List.generate(_items.length, (i) {
          final isActive = currentIndex == i;
          final isCenter = i == 2;
          final isProfile = i == 4;
          final iconColor =
              isActive ? cs.primary : cs.onSurfaceVariant;

          // ── Centre gradient FAB ───────────────────────────────────
          if (isCenter) {
            return Expanded(
              child: Semantics(
                button: true,
                label: centerFabSemanticLabel,
                hint: 'Opens pet care diary, goals, and daily checklist',
                onTap: () => onTap(i),
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [cs.primary, cs.primary.withAlpha(200)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: cs.primary.withAlpha(80),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(Icons.add_rounded,
                          color: cs.onPrimary, size: 28),
                    ),
                  ),
                ),
              ),
            );
          }

          // ── Regular / profile tabs ────────────────────────────────
          return Expanded(
            child: Semantics(
              button: true,
              selected: isActive,
              label: tabSemanticLabels[i],
              hint: i == 4 && profileImageUrl.isEmpty
                  ? 'Your profile and pets'
                  : null,
              onTap: () => onTap(i),
              excludeSemantics: true,
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 230),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.all(10),
                    child: Center(
                      child: AnimatedScale(
                        scale: isActive ? 1.12 : 1.0,
                        duration: const Duration(milliseconds: 230),
                        curve: Curves.easeOutBack,
                        child: isProfile
                            ? NavProfileAvatar(
                                imageUrl: profileImageUrl,
                                isActive: isActive,
                                ringColor: cs.primary,
                              )
                            : Icon(
                                isActive
                                    ? _items[i].active
                                    : _items[i].inactive,
                                color: iconColor,
                                size: 26,
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NavProfileAvatar — pet avatar with animated active ring
// ─────────────────────────────────────────────────────────────────────────────
class NavProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final bool isActive;
  final Color ringColor;

  const NavProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.isActive,
    required this.ringColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 230),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? ringColor : cs.outline.withAlpha(55),
          width: isActive ? 2.0 : 1.0,
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: CircleAvatar(
        radius: 11,
        backgroundColor: cs.surfaceContainerHighest,
        backgroundImage: imageUrl.isNotEmpty
            ? CachedNetworkImageProvider(imageUrl)
            : null,
        child: imageUrl.isEmpty
            ? Icon(Icons.person_rounded,
                size: 14, color: cs.onSurfaceVariant)
            : null,
      ),
    );
  }
}

// Keep old name as alias so nothing else breaks if referenced elsewhere
typedef GlassNavBar = PetfolioNavBar;
typedef ProfileTabAvatar = NavProfileAvatar;
