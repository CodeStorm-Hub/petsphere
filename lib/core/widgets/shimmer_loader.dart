import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:petfolio/core/theme/app_border_radius.dart';

class ShimmerLoader extends StatefulWidget {
  const ShimmerLoader({
    super.key,
    required this.height,
    this.width,
    this.borderRadius,
    this.shouldAnimate = true,
  });

  final double height;
  final double? width;
  final BorderRadiusGeometry? borderRadius;
  final bool shouldAnimate;

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
      duration: const Duration(milliseconds: 1500),
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
    final effectiveBorderRadius = widget.borderRadius ?? AppBorderRadius.cardRadius;

    if (!widget.shouldAnimate) {
      return Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: effectiveBorderRadius,
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
            borderRadius: effectiveBorderRadius,
            gradient: LinearGradient(
              begin: Alignment(-2 + controller.value * 4, 0),
              end: Alignment(controller.value * 4, 0),
              colors: [
                theme.colorScheme.surfaceContainerHigh,
                theme.colorScheme.surfaceContainerHighest,
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
  const ShimmerGroup({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return child
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1500.ms,
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        );
  }
}
