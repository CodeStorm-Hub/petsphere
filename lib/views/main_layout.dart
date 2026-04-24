import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../controllers/pet_controller.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';
import 'pet_profile_screen.dart';
import 'discovery_screen.dart';
import 'marketplace_screen.dart';

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

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _GlassmorphicNavBar(
        currentIndex: _currentIndex,
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

// ── Glassmorphic bottom nav matching "The Nurtured Atelier" Stitch spec ─────
class _GlassmorphicNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _GlassmorphicNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    _NavItem(Icons.home_outlined, Icons.home_rounded),
    _NavItem(Icons.explore_outlined, Icons.explore_rounded),
    _NavItem(Icons.add, Icons.add),
    _NavItem(Icons.storefront_outlined, Icons.storefront_rounded),
    _NavItem(Icons.person_outline_rounded, Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(48)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xCCFEF8F3),
            borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
            boxShadow: [
              BoxShadow(
                color: Color(0x1499472C),
                blurRadius: 24,
                offset: Offset(0, -8),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(24, 14, 24, 14 + bottomPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final isActive = currentIndex == i;
              final isCreate = i == 2;

              if (isCreate) {
                return GestureDetector(
                  onTap: () => onTap(i),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradientFAB,
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x4D99472C),
                          blurRadius: 16,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                );
              }

              return GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOutCubic,
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: isActive ? AppTheme.primaryGradientFAB : null,
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? const [
                            BoxShadow(
                              color: Color(0x3399472C),
                              blurRadius: 12,
                              offset: Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    isActive ? _items[i].active : _items[i].inactive,
                    color: isActive ? Colors.white : AppTheme.onSurfaceVariant,
                    size: 22,
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData inactive;
  final IconData active;
  const _NavItem(this.inactive, this.active);
}
