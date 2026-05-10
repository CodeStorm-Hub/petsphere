import 'package:flutter/material.dart';

/// Material 3 canonical breakpoints.
///
/// - `compact`: < 600 dp — handset portrait
/// - `medium`: 600–1199 dp — tablet portrait / handset landscape
/// - `expanded`: ≥ 1200 dp — tablet landscape / desktop
enum ScreenSize { compact, medium, expanded }

/// Returns the [ScreenSize] bucket for the given [width].
ScreenSize screenSizeOf(double width) {
  if (width < 600) return ScreenSize.compact;
  if (width < 1200) return ScreenSize.medium;
  return ScreenSize.expanded;
}

/// A widget that rebuilds whenever the screen size category changes.
///
/// Usage:
/// ```dart
/// ResponsiveBuilder(
///   builder: (context, size) {
///     return size == ScreenSize.compact
///         ? const MobileLayout()
///         : const TabletLayout();
///   },
/// )
/// ```
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, ScreenSize size) builder;

  static ScreenSize of(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return screenSizeOf(width);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = screenSizeOf(constraints.maxWidth);
        return builder(context, size);
      },
    );
  }
}

/// Convenience extension for [BuildContext] to access screen size.
extension ResponsiveContext on BuildContext {
  ScreenSize get screenSize => ResponsiveBuilder.of(this);
  bool get isCompact => screenSize == ScreenSize.compact;
  bool get isMedium => screenSize == ScreenSize.medium;
  bool get isExpanded => screenSize == ScreenSize.expanded;
  bool get isDesktop => screenSize == ScreenSize.expanded;
  bool get isMobile => screenSize == ScreenSize.compact;
}
