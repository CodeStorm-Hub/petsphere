import 'package:flutter/material.dart';
import 'package:petfolio/core/theme/app_border_radius.dart';

import 'package:petfolio/core/theme/app_theme.dart';

class PillButton extends StatefulWidget {
  const PillButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.outlined = false,
    this.icon,
  });

  final Widget child;
  final VoidCallback? onPressed;
  final bool outlined;
  final IconData? icon;

  @override
  State<PillButton> createState() => PillButtonState();
}

class PillButtonState extends State<PillButton> {
  bool pressed = false;

  void setPressed(bool value) {
    if (pressed != value) setState(() => pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shadows = theme.extension<PetFolioShadows>()!;
    
    final button = widget.outlined
        ? widget.icon == null
            ? OutlinedButton(
                onPressed: widget.onPressed,
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                ),
                child: widget.child,
              )
            : OutlinedButton.icon(
                onPressed: widget.onPressed,
                style: OutlinedButton.styleFrom(
                  shape: const StadiumBorder(),
                ),
                icon: Icon(widget.icon, size: 18),
                label: widget.child,
              )
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: AppBorderRadius.circularPill,
              boxShadow: widget.onPressed == null ? null : shadows.button,
            ),
            child: widget.icon == null
                ? ElevatedButton(
                    onPressed: widget.onPressed,
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    child: widget.child,
                  )
                : ElevatedButton.icon(
                    onPressed: widget.onPressed,
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    icon: Icon(widget.icon, size: 18),
                    label: widget.child,
                  ),
          );

    return GestureDetector(
      onTapDown: widget.onPressed == null ? null : (_) => setPressed(true),
      onTapCancel: widget.onPressed == null ? null : () => setPressed(false),
      onTapUp: widget.onPressed == null ? null : (_) => setPressed(false),
      child: AnimatedScale(
        scale: pressed ? 0.97 : 1,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: button,
      ),
    );
  }
}
