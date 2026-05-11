import 'package:flutter/material.dart';
import 'package:petfolio/core/theme/app_border_radius.dart';
import 'package:petfolio/core/theme/spacing.dart';

/// A standardized bottom sheet wrapper with a handle bar.
class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.child,
    this.title,
    this.actions,
    this.showHandle = true,
    this.padding,
    this.scrollable = true,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final bool showHandle;
  final EdgeInsetsGeometry? padding;
  final bool scrollable;

  /// Static helper to show the bottom sheet.
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    bool showHandle = true,
    EdgeInsetsGeometry? padding,
    bool scrollable = true,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? backgroundColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      builder: (context) => AppBottomSheet(
        title: title,
        actions: actions,
        showHandle: showHandle,
        padding: padding,
        scrollable: scrollable,
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.card),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showHandle) ...[
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
          if (title != null) ...[
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title!,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (actions != null) ...actions!,
                ],
              ),
            ),
            const Divider(height: 1),
          ],
          Flexible(
            child: scrollable
                ? SingleChildScrollView(
                    padding: padding ?? const EdgeInsets.all(AppSpacing.md),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomPadding + 20),
                      child: child,
                    ),
                  )
                : Padding(
                    padding: padding ?? const EdgeInsets.all(AppSpacing.md),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottomPadding + 20),
                      child: child,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
