import 'package:flutter/material.dart';
import 'package:petfolio/core/theme/app_border_radius.dart';
import 'package:petfolio/core/theme/spacing.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    super.key,
    this.hintText = 'Search...',
    this.onChanged,
    this.controller,
    this.onClear,
    this.padding,
  });

  final String hintText;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;
  final VoidCallback? onClear;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: padding ?? const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
          suffixIcon: (controller?.text.isNotEmpty == true)
              ? IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    controller?.clear();
                    onClear?.call();
                    if (onChanged != null) onChanged!('');
                  },
                )
              : null,
          filled: true,
          fillColor: cs.surfaceContainerHigh,
          border: const OutlineInputBorder(
            borderRadius: AppBorderRadius.inputRadius,
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xs,
            horizontal: AppSpacing.md,
          ),
        ),
      ),
    );
  }
}
