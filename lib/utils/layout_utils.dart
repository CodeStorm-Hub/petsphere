import 'package:flutter/material.dart';

// ── Bottom nav layout tokens ───────────────────────────────────────────────
/// Visual height of the bottom nav bar (excluding the system safe-area inset).
const double kBottomNavBarHeight = 60.0;

/// Extra breathing room between in-screen content and the nav bar top edge.
const double kBottomNavBarGap = 8.0;

/// Total bottom padding screens hosted in [MainLayout] should reserve so
/// scrollable content stays fully visible above the nav bar on every device.
double bottomNavSpaceFor(BuildContext context) {
  final inset = MediaQuery.viewPaddingOf(context).bottom;
  return kBottomNavBarHeight + kBottomNavBarGap + inset;
}
