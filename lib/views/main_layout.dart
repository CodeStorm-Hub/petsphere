import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/pet_controller.dart';
import 'home_screen.dart';
import 'pet_profile_screen.dart';
import 'discovery_screen.dart';
import 'marketplace_screen.dart';

// ── Instagram-style bottom nav layout tokens ───────────────────────────────
// The bar is a flat, opaque surface that sits at the bottom of the screen
// (like Instagram's app bar). Screens hosted in MainLayout still use
// extendBody: true so any safe-area inset is rendered behind the bar; they
// should call [bottomNavSpaceFor] to reserve enough space at the bottom of
// scrollable content so list items aren't hidden behind it.

/// Visual height of the Instagram-style bottom nav (excluding the system
/// safe-area inset). 28px icon + 14px top/bottom padding = 56dp tall.
const double kBottomNavBarHeight = 56.0;

/// Extra breathing room placed between the last piece of in-screen content
/// and the top edge of the nav bar.
const double kBottomNavBarGap = 8.0;

/// Total bottom padding screens hosted in [MainLayout] should reserve so
/// scrollable content is fully visible above the bottom navigation bar on
/// every device (with or without a home-indicator safe area).
double bottomNavSpaceFor(BuildContext context) {
  final inset = MediaQuery.viewPaddingOf(context).bottom;
  return kBottomNavBarHeight + kBottomNavBarGap + inset;
}

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key});

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  int _currentIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    DiscoveryScreen(),
    SizedBox.shrink(),
    MarketplaceScreen(),
    PetProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(profilePetNavigationProvider, (prev, next) {
      if (next != null) setState(() => _currentIndex = 4);
    });

    final activePet = ref.watch(activePetProvider);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _InstagramNavBar(
        currentIndex: _currentIndex,
        profileImageUrl: activePet?.profileImageUrl ?? '',
        onTap: (index) {
          if (index == 2) {
            context.push('/create_post');
            return;
          }
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}

// ── Instagram-style bottom nav (flat, opaque, hairline top divider) ────────
class _InstagramNavBar extends StatelessWidget {
  final int currentIndex;
  final String profileImageUrl;
  final ValueChanged<int> onTap;

  const _InstagramNavBar({
    required this.currentIndex,
    required this.profileImageUrl,
    required this.onTap,
  });

  static const _items = [
    _NavItem(Icons.home_outlined, Icons.home),
    _NavItem(Icons.search, Icons.search),
    _NavItem(Icons.add_box_outlined, Icons.add_box),
    _NavItem(Icons.storefront_outlined, Icons.storefront),
    // Profile slot uses an avatar instead of an icon — values here are unused.
    _NavItem(Icons.person_outline, Icons.person),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withAlpha(46),
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: SizedBox(
        height: kBottomNavBarHeight,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (i) {
            final isActive = currentIndex == i;
            final isProfile = i == 4;
            final iconColor = colorScheme.onSurface;

            final Widget child;
            if (isProfile) {
              child = _ProfileTabAvatar(
                imageUrl: profileImageUrl,
                isActive: isActive,
                ringColor: iconColor,
              );
            } else {
              child = Icon(
                isActive ? _items[i].active : _items[i].inactive,
                color: iconColor,
                size: 28,
              );
            }

            return Expanded(
              child: InkResponse(
                onTap: () => onTap(i),
                radius: 32,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: child,
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _ProfileTabAvatar extends StatelessWidget {
  final String imageUrl;
  final bool isActive;
  final Color ringColor;

  const _ProfileTabAvatar({
    required this.imageUrl,
    required this.isActive,
    required this.ringColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatar = CircleAvatar(
      radius: 12,
      backgroundColor: colorScheme.surfaceContainerHighest,
      backgroundImage:
          imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
      child: imageUrl.isEmpty
          ? Icon(Icons.person, size: 16, color: colorScheme.onSurfaceVariant)
          : null,
    );

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isActive ? ringColor : Colors.transparent,
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: avatar,
    );
  }
}

class _NavItem {
  final IconData inactive;
  final IconData active;
  const _NavItem(this.inactive, this.active);
}
