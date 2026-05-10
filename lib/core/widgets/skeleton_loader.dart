import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:petfolio/core/widgets/petfolio_widgets.dart';

/// A collection of skeleton loading widgets used across the app for consistent shimmer effects.
class ProfileSkeletonLoader extends StatelessWidget {
  const ProfileSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerGroup(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                ShimmerLoader(
                  width: 88,
                  height: 88,
                  borderRadius: BorderRadius.all(Radius.circular(44)),
                  shouldAnimate: false,
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          ShimmerLoader(
                            width: 30,
                            height: 20,
                            shouldAnimate: false,
                          ),
                          SizedBox(height: 4),
                          ShimmerLoader(
                            width: 50,
                            height: 14,
                            shouldAnimate: false,
                          ),
                        ],
                      ),
                      Column(
                        children: [
                          ShimmerLoader(
                            width: 30,
                            height: 20,
                            shouldAnimate: false,
                          ),
                          SizedBox(height: 4),
                          ShimmerLoader(
                            width: 50,
                            height: 14,
                            shouldAnimate: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            const ShimmerLoader(width: 150, height: 24, shouldAnimate: false),
            const SizedBox(height: 8),
            const ShimmerLoader(width: 200, height: 16, shouldAnimate: false),
            const SizedBox(height: 16),
            const ShimmerLoader(
              width: double.infinity,
              height: 60,
              shouldAnimate: false,
            ),
            const SizedBox(height: 24),
            const Row(
              children: [
                ShimmerLoader(
                  width: 60,
                  height: 60,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  shouldAnimate: false,
                ),
                SizedBox(width: 16),
                ShimmerLoader(
                  width: 60,
                  height: 60,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  shouldAnimate: false,
                ),
                SizedBox(width: 16),
                ShimmerLoader(
                  width: 60,
                  height: 60,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  shouldAnimate: false,
                ),
              ],
            ),
            const SizedBox(height: 32),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: 6,
              itemBuilder: (_, index) => const ShimmerLoader(
                height: double.infinity,
                shouldAnimate: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DiscoverySkeletonLoader extends StatelessWidget {
  const DiscoverySkeletonLoader({super.key, required this.navSpace});
  final double navSpace;

  @override
  Widget build(BuildContext context) {
    return ShimmerGroup(
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, navSpace),
        child: Column(
          children: [
            const SizedBox(height: 12),
            SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      3,
                      (i) => const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: ShimmerLoader(
                          width: 100,
                          height: 40,
                          borderRadius: BorderRadius.all(Radius.circular(999)),
                          shouldAnimate: false,
                        ),
                      ),
                    ),
                  ),
                )
                .animate()
                .fade(duration: 400.ms)
                .slideY(
                  begin: 0.1,
                  end: 0,
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                ),
            const SizedBox(height: 16),
            Expanded(
              child:
                  const ShimmerLoader(
                        height: double.infinity,
                        shouldAnimate: false,
                      )
                      .animate()
                      .fade(duration: 400.ms, delay: 100.ms)
                      .scale(
                        begin: const Offset(0.95, 0.95),
                        end: const Offset(1, 1),
                        duration: 400.ms,
                        curve: Curves.easeOutCubic,
                      ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children:
                  [
                        const ShimmerLoader(
                          width: 60,
                          height: 60,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          shouldAnimate: false,
                        ),
                        const SizedBox(width: 16),
                        const ShimmerLoader(
                          width: 50,
                          height: 50,
                          borderRadius: BorderRadius.all(Radius.circular(25)),
                          shouldAnimate: false,
                        ),
                        const SizedBox(width: 16),
                        const ShimmerLoader(
                          width: 70,
                          height: 70,
                          borderRadius: BorderRadius.all(Radius.circular(35)),
                          shouldAnimate: false,
                        ),
                      ]
                      .animate(interval: 50.ms)
                      .fade(duration: 400.ms, delay: 200.ms)
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1, 1),
                        duration: 400.ms,
                        curve: Curves.easeOutCubic,
                      ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class FeedSkeletonLoader extends StatelessWidget {
  const FeedSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerGroup(
      child: Column(
        children: [
          // Stories Row Skeleton
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                  6,
                  (i) => const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Column(
                      children: [
                        ShimmerLoader(
                          width: 64,
                          height: 64,
                          borderRadius: BorderRadius.all(Radius.circular(32)),
                          shouldAnimate: false,
                        ),
                        SizedBox(height: 8),
                        ShimmerLoader(
                          width: 48,
                          height: 12,
                          shouldAnimate: false,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          // Post Skeleton
          Expanded(
            child: ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 2,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post Header
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            ShimmerLoader(
                              width: 36,
                              height: 36,
                              borderRadius: BorderRadius.all(
                                Radius.circular(18),
                              ),
                              shouldAnimate: false,
                            ),
                            SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ShimmerLoader(
                                  width: 100,
                                  height: 14,
                                  shouldAnimate: false,
                                ),
                                SizedBox(height: 4),
                                ShimmerLoader(
                                  width: 60,
                                  height: 10,
                                  shouldAnimate: false,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      // Post Image
                      ShimmerLoader(
                        width: double.infinity,
                        height: 360,
                        shouldAnimate: false,
                      ),
                      SizedBox(height: 12),
                      // Post Actions
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            ShimmerLoader(
                              width: 24,
                              height: 24,
                              shouldAnimate: false,
                            ),
                            SizedBox(width: 16),
                            ShimmerLoader(
                              width: 24,
                              height: 24,
                              shouldAnimate: false,
                            ),
                            SizedBox(width: 16),
                            ShimmerLoader(
                              width: 24,
                              height: 24,
                              shouldAnimate: false,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      // Post Caption
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ShimmerLoader(
                              width: 150,
                              height: 14,
                              shouldAnimate: false,
                            ),
                            SizedBox(height: 6),
                            ShimmerLoader(
                              width: double.infinity,
                              height: 12,
                              shouldAnimate: false,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MarketplaceSkeletonLoader extends StatelessWidget {
  const MarketplaceSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerGroup(
      child: Column(
        children: [
          // Categories Skeleton
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: List.generate(
                5,
                (i) => const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: ShimmerLoader(
                    width: 80,
                    height: 40,
                    borderRadius: BorderRadius.all(Radius.circular(20)),
                    shouldAnimate: false,
                  ),
                ),
              ),
            ),
          ),
          // Grid Skeleton
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
              ),
              itemBuilder: (context, index) => const ShimmerLoader(
                height: 200,
                borderRadius: BorderRadius.all(Radius.circular(16)),
                shouldAnimate: false,
              ),
              itemCount: 4,
            ),
          ),
        ],
      ),
    );
  }
}

class HealthSkeletonLoader extends StatelessWidget {
  const HealthSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerGroup(
      child: ListView(
        padding: const EdgeInsets.all(16),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          // Overview Card Skeleton
          const ShimmerLoader(
            height: 120,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            shouldAnimate: false,
          ),
          const SizedBox(height: 16),
          // Vitals Section Skeleton
          const ShimmerLoader(
            height: 180,
            borderRadius: BorderRadius.all(Radius.circular(20)),
            shouldAnimate: false,
          ),
          const SizedBox(height: 16),
          // Sections Skeleton
          ...List.generate(
            3,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: ShimmerLoader(
                height: 100,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                shouldAnimate: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatSkeletonLoader extends StatelessWidget {
  const ChatSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerGroup(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 8,
        itemBuilder: (context, index) {
          final isMe = index % 2 == 0;
          return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: isMe
                      ? MainAxisAlignment.end
                      : MainAxisAlignment.start,
                  children: [
                    if (!isMe) ...[
                      const ShimmerLoader(
                        width: 32,
                        height: 32,
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        shouldAnimate: false,
                      ),
                      const SizedBox(width: 8),
                    ],
                    ShimmerLoader(
                      width: 140 + (index * 10.0 % 60),
                      height: 44,
                      shouldAnimate: false,
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isMe ? 16 : 4),
                        bottomRight: Radius.circular(isMe ? 4 : 16),
                      ),
                    ),
                  ],
                ),
              )
              .animate()
              .fadeIn(delay: (index * 50).ms, duration: 400.ms)
              .slideY(begin: 0.1, end: 0);
        },
      ),
    );
  }
}

class MessagesListSkeletonLoader extends StatelessWidget {
  const MessagesListSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerGroup(
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return const Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: Row(
              children: [
                ShimmerLoader(
                  width: 60,
                  height: 60,
                  borderRadius: BorderRadius.all(Radius.circular(30)),
                  shouldAnimate: false,
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ShimmerLoader(
                            width: 120,
                            height: 16,
                            shouldAnimate: false,
                          ),
                          ShimmerLoader(
                            width: 40,
                            height: 12,
                            shouldAnimate: false,
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      ShimmerLoader(
                        width: 200,
                        height: 14,
                        shouldAnimate: false,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: (index * 30).ms, duration: 300.ms);
        },
      ),
    );
  }
}

class ExpenseSkeletonLoader extends StatelessWidget {
  const ExpenseSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerGroup(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Large Header (Dashboard)
            const ShimmerLoader(
              height: 200,
              borderRadius: BorderRadius.all(Radius.circular(32)),
              shouldAnimate: false,
            ),
            const SizedBox(height: 32),

            // Category Breakdown Title
            const ShimmerLoader(width: 180, height: 28, shouldAnimate: false),
            const SizedBox(height: 16),

            // Category Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.4,
              ),
              itemCount: 4,
              itemBuilder: (_, _) =>
                  const ShimmerLoader(height: 100, shouldAnimate: false),
            ),
            const SizedBox(height: 32),

            // Transaction List Title
            const ShimmerLoader(width: 200, height: 28, shouldAnimate: false),
            const SizedBox(height: 16),

            // Transaction Cards
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, _) =>
                  const ShimmerLoader(height: 80, shouldAnimate: false),
            ),
          ],
        ),
      ),
    );
  }
}

class TrainingSkeletonLoader extends StatelessWidget {
  const TrainingSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerGroup(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerLoader(
              height: 220,
              borderRadius: BorderRadius.all(Radius.circular(28)),
              shouldAnimate: false,
            ),
            const SizedBox(height: 32),
            const ShimmerLoader(width: 150, height: 24, shouldAnimate: false),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(height: 16),
              itemBuilder: (_, _) => const ShimmerLoader(
                height: 90,
                borderRadius: BorderRadius.all(Radius.circular(20)),
                shouldAnimate: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CareSkeletonLoader extends StatelessWidget {
  const CareSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerGroup(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gamification Card
            const ShimmerLoader(
              width: double.infinity,
              height: 180,
              shouldAnimate: false,
            ),
            const SizedBox(height: 32),

            // Statistics/Charts
            const Row(
              children: [
                Expanded(
                  child: ShimmerLoader(
                    height: 120,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    shouldAnimate: false,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ShimmerLoader(
                    height: 120,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    shouldAnimate: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Tasks List
            const ShimmerLoader(width: 140, height: 24, shouldAnimate: false),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, _) => const Row(
                children: [
                  ShimmerLoader(
                    width: 24,
                    height: 24,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                    shouldAnimate: false,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerLoader(
                          width: double.infinity,
                          height: 16,
                          shouldAnimate: false,
                        ),
                        SizedBox(height: 6),
                        ShimmerLoader(
                          width: 100,
                          height: 12,
                          shouldAnimate: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Recent Expenses
            const ShimmerLoader(width: 160, height: 24, shouldAnimate: false),
            const SizedBox(height: 16),
            const ShimmerLoader(
              width: double.infinity,
              height: 100,
              borderRadius: BorderRadius.all(Radius.circular(16)),
              shouldAnimate: false,
            ),
          ],
        ),
      ),
    );
  }
}
