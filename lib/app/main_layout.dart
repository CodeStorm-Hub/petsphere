import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:petfolio/features/pet/presentation/controllers/pet_controller.dart';
import 'package:petfolio/features/auth/presentation/controllers/auth_controller.dart';
import 'package:petfolio/app/widgets/adaptive_navigation.dart';
import 'package:petfolio/core/constants/app_routes.dart';
import 'package:petfolio/core/theme/app_breakpoints.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MainLayout
// ─────────────────────────────────────────────────────────────────────────────
class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainLayout> createState() => MainLayoutState();
}

class MainLayoutState extends ConsumerState<MainLayout> {
  int _calculateNavBarIndex(int shellIndex) {
    if (shellIndex == 0) return 0;
    if (shellIndex == 1) return 1;
    if (shellIndex == 2) return 3;
    if (shellIndex == 3) return 4;
    return 0;
  }

  void _onTap(int navBarIndex) {
    if (navBarIndex == 2) {
      final activePet = ref.read(activePetProvider);
      if (activePet != null) {
        context.push(AppRoutes.petCareById(activePet.id));
      } else {
        context.push(AppRoutes.managePets);
      }
      return;
    }

    int shellIndex;
    if (navBarIndex == 0) {
      shellIndex = 0;
    } else if (navBarIndex == 1) {
      shellIndex = 1;
    } else if (navBarIndex == 3) {
      shellIndex = 2;
    } else if (navBarIndex == 4) {
      shellIndex = 3;
    } else {
      return;
    }

    widget.navigationShell.goBranch(
      shellIndex,
      initialLocation: shellIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Navigate to profile tab when a pet is tapped from another screen
    ref.listen<String?>(profilePetNavigationProvider, (prev, next) {
      if (next != null) {
        widget.navigationShell.goBranch(3);
      }
    });

    ref.listen<int?>(mainLayoutTabRequestProvider, (prev, next) {
      if (next == null) return;
      if (next != 2) {
        int shellIndex;
        if (next == 0) {
          shellIndex = 0;
        } else if (next == 1) {
          shellIndex = 1;
        } else if (next == 3) {
          shellIndex = 2;
        } else if (next == 4) {
          shellIndex = 3;
        } else {
          return;
        }
        widget.navigationShell.goBranch(shellIndex);
      }
      ref.read(mainLayoutTabRequestProvider.notifier).clear();
    });

    final authState = ref.watch(authProvider);
    final user = authState.user;
    final activePet = ref.watch(activePetProvider);
    final displayImageUrl =
        activePet?.profileImageUrl ?? user?.profileImageUrl ?? '';

    final width = MediaQuery.sizeOf(context).width;
    final isTablet = AppBreakpoints.isExpanded(width);

    return Scaffold(
      extendBody: true,
      body: Row(
        children: [
          if (isTablet)
            PetFolioNavRail(
              currentIndex: _calculateNavBarIndex(
                widget.navigationShell.currentIndex,
              ),
              profileImageUrl: displayImageUrl,
              onTap: _onTap,
              isExtended: width >= AppBreakpoints.expanded,
            ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: widget.navigationShell,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isTablet
          ? null
          : RepaintBoundary(
              child: PetFolioNavBar(
                currentIndex: _calculateNavBarIndex(
                  widget.navigationShell.currentIndex,
                ),
                profileImageUrl: displayImageUrl,
                onTap: _onTap,
              ),
            ),
    );
  }
}
