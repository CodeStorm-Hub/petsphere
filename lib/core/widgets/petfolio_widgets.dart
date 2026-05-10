import 'package:flutter/material.dart';

import 'package:petfolio/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppTheme.md),
    this.margin,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shadows = theme.extension<PetFolioShadows>()!;

    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: child,
    );

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        boxShadow: shadows.card,
      ),
      child: Material(
        color: Colors.transparent,
        child: onTap == null
            ? card
            : InkWell(
                borderRadius: BorderRadius.circular(AppTheme.cardRadius),
                onTap: onTap,
                child: card,
              ),
      ),
    );
  }
}

class PillButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final bool outlined;
  final IconData? icon;

  const PillButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.outlined = false,
    this.icon,
  });

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
    final shadows = Theme.of(context).extension<PetFolioShadows>()!;
    final button = widget.outlined
        ? widget.icon == null
              ? OutlinedButton(onPressed: widget.onPressed, child: widget.child)
              : OutlinedButton.icon(
                  onPressed: widget.onPressed,
                  icon: Icon(widget.icon),
                  label: widget.child,
                )
        : DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.pillRadius),
              boxShadow: widget.onPressed == null ? null : shadows.button,
            ),
            child: widget.icon == null
                ? ElevatedButton(
                    onPressed: widget.onPressed,
                    child: widget.child,
                  )
                : ElevatedButton.icon(
                    onPressed: widget.onPressed,
                    icon: Icon(widget.icon),
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

class SectionTag extends StatelessWidget {
  final String text;

  const SectionTag(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 24, height: 1.5, color: theme.colorScheme.primary),
        const SizedBox(width: AppTheme.sm),
        Text(text.toUpperCase(), style: theme.textTheme.labelSmall),
      ],
    );
  }
}

class AnimatedBadge extends StatefulWidget {
  final Widget child;

  const AnimatedBadge({super.key, required this.child});

  @override
  State<AnimatedBadge> createState() => AnimatedBadgeState();
}

class AnimatedBadgeState extends State<AnimatedBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late final Animation<double> scale;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    scale = Tween<double>(
      begin: 1,
      end: 1.4,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: ShapeDecoration(
        color: theme.colorScheme.surfaceContainerLowest.withValues(alpha: 0.80),
        shape: StadiumBorder(
          side: BorderSide(color: theme.colorScheme.outline),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ScaleTransition(
            scale: scale,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.sm),
          widget.child,
        ],
      ),
    );
  }
}

class VitalsBar extends StatefulWidget {
  final double value;

  const VitalsBar({super.key, required this.value});

  @override
  State<VitalsBar> createState() => VitalsBarState();
}

class VitalsBarState extends State<VitalsBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    animation = Tween<double>(
      begin: 0,
      end: widget.value.clamp(0, 1),
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) controller.forward();
    });
  }

  @override
  void didUpdateWidget(covariant VitalsBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      animation = Tween<double>(
        begin: animation.value,
        end: widget.value.clamp(0, 1),
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));
      controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: animation.value,
            minHeight: 8,
            backgroundColor: colorScheme.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
          ),
        );
      },
    );
  }
}

class ShimmerLoader extends StatefulWidget {
  final double height;
  final double? width;
  final BorderRadiusGeometry borderRadius;
  final bool shouldAnimate;

  const ShimmerLoader({
    super.key,
    required this.height,
    this.width,
    this.borderRadius = const BorderRadius.all(
      Radius.circular(AppTheme.cardRadius),
    ),
    this.shouldAnimate = true,
  });

  @override
  State<ShimmerLoader> createState() => ShimmerLoaderState();
}

class ShimmerLoaderState extends State<ShimmerLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    if (widget.shouldAnimate) {
      controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerLoader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldAnimate != oldWidget.shouldAnimate) {
      if (widget.shouldAnimate) {
        controller.repeat();
      } else {
        controller.stop();
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!widget.shouldAnimate) {
      return Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: widget.borderRadius,
        ),
      );
    }

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Container(
          height: widget.height,
          width: widget.width,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1 + controller.value * 2, 0),
              end: Alignment(controller.value * 2, 0),
              colors: [
                theme.colorScheme.surfaceContainerHigh,
                theme.colorScheme.surfaceContainer,
                theme.colorScheme.surfaceContainerHigh,
              ],
            ),
          ),
        );
      },
    );
  }
}

class ShimmerGroup extends StatelessWidget {
  final Widget child;

  const ShimmerGroup({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return child
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          color: theme.colorScheme.surfaceContainer,
        );
  }
}

class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const FadeSlideIn({super.key, required this.child, this.delayMs = 0});

  @override
  State<FadeSlideIn> createState() => FadeSlideInState();
}

class PetFolioGradientBackground extends StatefulWidget {
  final Widget child;

  const PetFolioGradientBackground({super.key, required this.child});

  @override
  State<PetFolioGradientBackground> createState() =>
      PetFolioGradientBackgroundState();
}

class PetFolioGradientBackgroundState
    extends State<PetFolioGradientBackground> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(-0.8, -0.6),
          radius: 1.5,
          colors: [
            theme.colorScheme.primary.withValues(alpha: isDark ? 0.15 : 0.08),
            theme.scaffoldBackgroundColor,
          ],
          stops: const [0.0, 1.0],
        ),
      ),
      child: widget.child,
    );
  }
}

class FadeSlideInState extends State<FadeSlideIn> {
  bool visible = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) setState(() => visible = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: visible ? 1 : 0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, 0.15),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
