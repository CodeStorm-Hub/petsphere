import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:petfolio/core/widgets/brand_logo.dart';
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
  NavItem(
    Icons.add_rounded,
    Icons.add_rounded,
    'Pet Care',
  ), // center FAB / Middle item
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
    this.onLongTap,
  });
  final int currentIndex;
  final String profileImageUrl;
  final ValueChanged<int> onTap;
  final ValueChanged<int>? onLongTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final barBg = isDark
        ? cs.surface.withValues(alpha: 0.72)
        : cs.surface.withValues(alpha: 0.78);
    final barBorder = cs.outline.withAlpha(isDark ? 80 : 45);

    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: kBottomNavBarHeight,
            decoration: BoxDecoration(
              color: barBg,
              border: Border.all(color: barBorder),
              borderRadius: BorderRadius.circular(999),
              boxShadow: [
                BoxShadow(
                  color: cs.primary.withValues(alpha: isDark ? 0.18 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
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
                      onLongPress: onLongTap != null
                          ? () => onLongTap!(i)
                          : null,
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
          ),
        ),
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
    this.onLongTap,
    this.isExtended = false,
  });
  final int currentIndex;
  final String profileImageUrl;
  final ValueChanged<int> onTap;
  final ValueChanged<int>? onLongTap;
  final bool isExtended;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final railBg = isDark
        ? cs.surface.withValues(alpha: 0.72)
        : cs.surface.withValues(alpha: 0.82);
    final railBorder = cs.outline.withAlpha(isDark ? 80 : 45);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isExtended ? 240 : 80,
      decoration: BoxDecoration(
        color: railBg,
        border: Border(right: BorderSide(color: railBorder)),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 24),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isExtended ? 24 : 0,
                  ),
                  child: Row(
                    mainAxisAlignment: isExtended
                        ? MainAxisAlignment.start
                        : MainAxisAlignment.center,
                    children: [
                      BrandLogo(customSize: isExtended ? 30 : 32),
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isExtended ? 12 : 8,
                    ),
                    itemBuilder: (context, i) {
                      final isActive = currentIndex == i;
                      final isProfile = i == 4;
                      final iconColor = isActive
                          ? cs.primary
                          : cs.onSurfaceVariant;

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: InkWell(
                          onTap: () => onTap(i),
                          onLongPress: onLongTap != null
                              ? () => onLongTap!(i)
                              : null,
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: isExtended ? 16 : 0,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? cs.primaryContainer.withAlpha(
                                      isDark ? 40 : 150,
                                    )
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
