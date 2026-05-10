import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petfolio/core/utils/layout_utils.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Nav item model
// ─────────────────────────────────────────────────────────────────────────────
class NavItem {
  const NavItem(this.inactive, this.active, this.label);
  final IconData inactive;
  final IconData active;
  final String label;
}

const List<NavItem> _kNavItems = [
  NavItem(Icons.home_outlined, Icons.home_rounded, 'Home'),
  NavItem(Icons.search_rounded, Icons.search_rounded, 'Discover'),
  NavItem(Icons.add_rounded, Icons.add_rounded, 'Pet Care'), // center FAB / Middle item
  NavItem(Icons.storefront_outlined, Icons.storefront_rounded, 'Shop'),
  NavItem(Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
];

// ─────────────────────────────────────────────────────────────────────────────
// PetFolioNavBar — mobile bottom navigation
// ─────────────────────────────────────────────────────────────────────────────
class PetFolioNavBar extends StatelessWidget {

  const PetFolioNavBar({
    super.key,
    required this.currentIndex,
    required this.profileImageUrl,
    required this.onTap,
  });
  final int currentIndex;
  final String profileImageUrl;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final barBg = isDark ? const Color(0xFF1C1C1C) : cs.surface;
    final barBorder = isDark
        ? const Color(0xFF2E2E2E)
        : cs.outline.withAlpha(55);

    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Container(
      height: kBottomNavBarHeight + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: barBg,
        border: Border(top: BorderSide(color: barBorder)),
      ),
      child: Row(
        children: List.generate(_kNavItems.length, (i) {
          final isActive = currentIndex == i;
          final isCenter = i == 2;
          final isProfile = i == 4;
          final iconColor = isActive ? cs.primary : cs.onSurfaceVariant;

          if (isCenter) {
            return Expanded(
              child: Semantics(
                button: true,
                label: 'Pet Care',
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
                      child: Icon(
                        Icons.add_rounded,
                        color: cs.onPrimary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          return Expanded(
            child: Semantics(
              button: true,
              selected: isActive,
              label: _kNavItems[i].label,
              onTap: () => onTap(i),
              excludeSemantics: true,
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
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
                                ? _kNavItems[i].active
                                : _kNavItems[i].inactive,
                            color: iconColor,
                            size: 26,
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
// PetFolioNavRail — tablet/desktop side navigation
// ─────────────────────────────────────────────────────────────────────────────
class PetFolioNavRail extends StatelessWidget {

  const PetFolioNavRail({
    super.key,
    required this.currentIndex,
    required this.profileImageUrl,
    required this.onTap,
    this.isExtended = false,
  });
  final int currentIndex;
  final String profileImageUrl;
  final ValueChanged<int> onTap;
  final bool isExtended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final railBg = isDark ? const Color(0xFF1C1C1C) : cs.surface;
    final railBorder = isDark
        ? const Color(0xFF2E2E2E)
        : cs.outline.withAlpha(55);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isExtended ? 240 : 80,
      decoration: BoxDecoration(
        color: railBg,
        border: Border(right: BorderSide(color: railBorder)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            // App Logo
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isExtended ? 24 : 0),
              child: Row(
                mainAxisAlignment: isExtended
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.center,
                children: [
                  Icon(Icons.pets_rounded, color: cs.primary, size: 32),
                  if (isExtended) ...[
                    const SizedBox(width: 12),
                    Text(
                      'PetFolio',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 40),
            Expanded(
              child: ListView.builder(
                itemCount: _kNavItems.length,
                padding: EdgeInsets.symmetric(horizontal: isExtended ? 12 : 8),
                itemBuilder: (context, i) {
                  final isActive = currentIndex == i;
                  final isProfile = i == 4;
                  final iconColor = isActive ? cs.primary : cs.onSurfaceVariant;

                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: InkWell(
                      onTap: () => onTap(i),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isExtended ? 16 : 0,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? cs.primaryContainer.withAlpha(isDark ? 40 : 150)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          mainAxisAlignment: isExtended
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.center,
                          children: [
                            AnimatedScale(
                              scale: isActive ? 1.1 : 1.0,
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
                                          ? _kNavItems[i].active
                                          : _kNavItems[i].inactive,
                                      color: iconColor,
                                      size: 24,
                                    ),
                            ),
                            if (isExtended) ...[
                              const SizedBox(width: 16),
                              Text(
                                _kNavItems[i].label,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: isActive
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isActive
                                      ? cs.primary
                                      : cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NavProfileAvatar — pet avatar with animated active ring
// ─────────────────────────────────────────────────────────────────────────────
class NavProfileAvatar extends StatelessWidget {

  const NavProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.isActive,
    required this.ringColor,
  });
  final String imageUrl;
  final bool isActive;
  final Color ringColor;

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
        radius: 12,
        backgroundColor: cs.surfaceContainerHighest,
        backgroundImage: imageUrl.isNotEmpty
            ? CachedNetworkImageProvider(imageUrl)
            : null,
        child: imageUrl.isEmpty
            ? Icon(Icons.person_rounded, size: 14, color: cs.onSurfaceVariant)
            : null,
      ),
    );
  }
}
