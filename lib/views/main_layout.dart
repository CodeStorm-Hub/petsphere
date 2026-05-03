import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/pet_controller.dart';
import '../theme/app_theme.dart';

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
  ConsumerState<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends ConsumerState<MainLayout> {
  int currentIndex = 0;

  static const List<Widget> screens = [
    HomeScreen(),
    DiscoveryScreen(),
    SizedBox.shrink(),
    MarketplaceScreen(),
    PetProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(profilePetNavigationProvider, (prev, next) {
      if (next != null) setState(() => currentIndex = 4);
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
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.md,
            0,
            AppTheme.md,
            AppTheme.md,
          ),
          child: GlassNavBar(
            currentIndex: currentIndex,
            profileImageUrl: activePet?.profileImageUrl ?? '',
            onTap: (index) {
              if (index == 2) {
                context.push('/pet_care');
                return;
              }
              setState(() => currentIndex = index);
            },
          ),
        ),
      ),
    );
  }
}

class GlassNavBar extends StatelessWidget {
  final int currentIndex;
  final String profileImageUrl;
  final ValueChanged<int> onTap;

  const GlassNavBar({super.key, 
    required this.currentIndex,
    required this.profileImageUrl,
    required this.onTap,
  });

  static const items = [
    NavItem(Icons.home_outlined, Icons.home),
    NavItem(Icons.search, Icons.search),
    NavItem(Icons.add, Icons.add), // Center FAB
    NavItem(Icons.storefront_outlined, Icons.storefront),
    NavItem(Icons.person_outline, Icons.person),
  ];


  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTheme.pillRadius),
      child: Container(
        height: 64,
          decoration: BoxDecoration(
            color: theme.bottomNavigationBarTheme.backgroundColor,
            borderRadius: BorderRadius.circular(AppTheme.pillRadius),
            border: Border.all(color: colorScheme.outline, width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(items.length, (i) {
              final isActive = currentIndex == i;
              final isCenter = i == 2;
              final isProfile = i == 4;
              final iconColor = isActive
                  ? colorScheme.primary
                  : colorScheme.onSurfaceVariant;

              if (isCenter) {
                return GestureDetector(
                  onTap: () => onTap(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOut,
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: Theme.of(
                        context,
                      ).extension<PetfolioShadows>()?.button,
                    ),
                    child: Icon(
                      Icons.add,
                      color: colorScheme.onPrimary,
                      size: 28,
                    ),
                  ),
                );
              }

              final Widget child;
              if (isProfile) {
                child = ProfileTabAvatar(
                  imageUrl: profileImageUrl,
                  isActive: isActive,
                  ringColor: iconColor,
                );
              } else {
                child = Icon(
                  isActive ? items[i].active : items[i].inactive,
                  color: iconColor,
                  size: 26,
                );
              }

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Center(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOut,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: ShapeDecoration(
                        color: isActive
                            ? colorScheme.primary.withValues(alpha: 0.10)
                            : Colors.transparent,
                        shape: const StadiumBorder(),
                      ),
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

class ProfileTabAvatar extends StatelessWidget {
  final String imageUrl;
  final bool isActive;
  final Color ringColor;

  const ProfileTabAvatar({super.key, 
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
      backgroundImage: imageUrl.isNotEmpty
          ? CachedNetworkImageProvider(imageUrl)
          : null,
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

class NavItem {
  final IconData inactive;
  final IconData active;
  const NavItem(this.inactive, this.active);
}
