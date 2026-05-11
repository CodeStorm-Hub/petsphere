import 'package:flutter/material.dart';
import 'package:petfolio/core/theme/app_border_radius.dart';

class VitalsBar extends StatefulWidget {
  const VitalsBar({
    super.key,
    required this.value,
    this.color,
    this.height = 8,
  });

  final double value;
  final Color? color;
  final double height;

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
      duration: const Duration(milliseconds: 800),
    );
    animation = Tween<double>(
      begin: 0,
      end: widget.value.clamp(0, 1),
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutBack));
    
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
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
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
    final theme = Theme.of(context);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return ClipRRect(
          borderRadius: AppBorderRadius.circularSm,
          child: LinearProgressIndicator(
            value: animation.value,
            minHeight: widget.height,
            backgroundColor: theme.colorScheme.surfaceContainerHigh,
            valueColor: AlwaysStoppedAnimation<Color>(
              widget.color ?? theme.colorScheme.primary,
            ),
          ),
        );
      },
    );
  }
}
