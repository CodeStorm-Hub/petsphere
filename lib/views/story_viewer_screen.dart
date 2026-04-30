import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../controllers/feed_controller.dart';
import '../controllers/pet_controller.dart';
import '../models/story_model.dart';
import '../utils/media_utils.dart';

/// How long a still-image frame is displayed before auto-advancing.
const Duration _kImageDuration = Duration(seconds: 7);

/// Maximum allowed display time for a video frame.
const Duration _kVideoMaxDuration = Duration(seconds: 60);

class StoryViewerScreen extends ConsumerStatefulWidget {
  final String petId;

  const StoryViewerScreen({super.key, required this.petId});

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen>
    with TickerProviderStateMixin {
  final _pageController = PageController();
  int _index = 0;

  // Per-frame progress animation controller.
  late AnimationController _progressController;

  // Expose the current list length so callbacks can read it safely.
  int _storyCount = 0;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // Called by each _StoryPage once it knows its true duration.
  void _startProgressFor(Duration duration) {
    _progressController.stop();
    _progressController.reset();
    _progressController.duration = duration;
    _progressController.forward().whenComplete(() {
      // Only auto-advance if the widget is still alive and the controller
      // finished naturally (not stopped/reset by user gesture).
      if (mounted && _progressController.status == AnimationStatus.completed) {
        _next();
      }
    });
  }

  void _next() {
    if (_index >= _storyCount - 1) {
      if (mounted) context.pop();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  void _previous() {
    if (_index == 0) return;
    _pageController.previousPage(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final feedState = ref.watch(feedProvider);
    final stories = feedState.stories
        .where((story) => story.pet.id == widget.petId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _storyCount = stories.length;

    final myPetIds =
        ref.watch(petProvider).myPets.map((pet) => pet.id).toSet();
    final canDelete = myPetIds.contains(widget.petId);

    if (stories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('This story is no longer available.',
                  style: TextStyle(color: colorScheme.onPrimary)),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () => ref.read(feedProvider.notifier).refresh(),
                child: const Text('Refresh'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // ── Media pages ────────────────────────────────────────────
            PageView.builder(
              controller: _pageController,
              itemCount: stories.length,
              onPageChanged: (index) {
                setState(() => _index = index);
                // Reset progress; the _StoryPage will call _startProgressFor
                // once it knows the frame duration.
                _progressController.stop();
                _progressController.reset();
              },
              itemBuilder: (context, index) {
                final story = stories[index];
                return _StoryPage(
                  key: ValueKey(story.id),
                  story: story,
                  onReady: (duration) {
                    if (_index == index) _startProgressFor(duration);
                  },
                  onPrevious: _previous,
                  onNext: _next,
                );
              },
            ),

            // ── Overlay: progress bars + header ────────────────────────
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Column(
                children: [
                  // Progress bars
                  Row(
                    children: List.generate(stories.length, (i) {
                      return Expanded(
                        child: _ProgressBar(
                          progress: i < _index
                              ? 1.0
                              : i == _index
                                  ? _progressController
                                  : 0.0,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  // Header row
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: stories[_index]
                                .pet
                                .profileImageUrl
                                .isNotEmpty
                            ? NetworkImage(
                                stories[_index].pet.profileImageUrl)
                            : null,
                        child: stories[_index].pet.profileImageUrl.isEmpty
                            ? const Icon(Icons.pets)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              stories[_index].pet.name,
                              style: TextStyle(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _ExpiryBadge(
                                expiresAt: stories[_index].expiresAt),
                          ],
                        ),
                      ),
                      if (canDelete)
                        IconButton(
                          onPressed: () async {
                            final storyId = stories[_index].id;
                            final success = await ref
                                .read(feedProvider.notifier)
                                .deleteStory(storyId);
                            if (context.mounted && success) {
                              if (stories.length == 1) context.pop();
                            }
                          },
                          icon: Icon(Icons.delete_outline,
                              color: colorScheme.onPrimary),
                        ),
                      IconButton(
                        onPressed: () => context.pop(),
                        icon:
                            Icon(Icons.close, color: colorScheme.onPrimary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Segmented animated progress bar ────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  /// Accepts either a double (0–1 static fill) or an [AnimationController].
  final Object progress;

  const _ProgressBar({required this.progress});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Widget bar(double value) => Container(
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(99),
            color: colorScheme.onPrimary.withAlpha(60),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.onPrimary,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        );

    if (progress is double) return bar(progress as double);

    return AnimatedBuilder(
      animation: progress as AnimationController,
      builder: (_, __) => bar((progress as AnimationController).value),
    );
  }
}

// ── 24-hour expiry badge ────────────────────────────────────────────────────

class _ExpiryBadge extends StatelessWidget {
  final DateTime expiresAt;

  const _ExpiryBadge({required this.expiresAt});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final remaining = expiresAt.difference(DateTime.now());
    if (remaining.isNegative) {
      return Text(
        'Expired',
        style: TextStyle(color: colorScheme.error, fontSize: 11),
      );
    }
    final h = remaining.inHours;
    final m = remaining.inMinutes % 60;
    final label = h > 0 ? '${h}h ${m}m left' : '${m}m left';
    return Text(
      label,
      style: TextStyle(
        color: colorScheme.onPrimary.withAlpha(160),
        fontSize: 11,
      ),
    );
  }
}

// ── Individual story page ───────────────────────────────────────────────────

class _StoryPage extends StatelessWidget {
  final StoryModel story;
  final ValueChanged<Duration> onReady;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _StoryPage({
    super.key,
    required this.story,
    required this.onReady,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (isVideoMedia(story.mediaUrl))
          _StoryVideo(
            url: story.mediaUrl,
            onReady: onReady,
          )
        else
          _StoryImage(
            url: story.mediaUrl,
            onReady: onReady,
          ),

        // Tap zones: left → previous, right → next
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onPrevious,
              ),
            ),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: onNext,
              ),
            ),
          ],
        ),

        // Caption
        if (story.caption.isNotEmpty)
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: Text(
              story.caption,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: colorScheme.onPrimary,
                fontSize: 16,
                shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
              ),
            ),
          ),
      ],
    );
  }
}

// ── Still-image frame — 7-second display ───────────────────────────────────

class _StoryImage extends StatefulWidget {
  final String url;
  final ValueChanged<Duration> onReady;

  const _StoryImage({required this.url, required this.onReady});

  @override
  State<_StoryImage> createState() => _StoryImageState();
}

class _StoryImageState extends State<_StoryImage> {
  bool _reported = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Image.network(
      widget.url,
      fit: BoxFit.contain,
      loadingBuilder: (_, child, progress) {
        if (progress == null) {
          // Image fully loaded — start the 7-second timer once.
          if (!_reported) {
            _reported = true;
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => widget.onReady(_kImageDuration),
            );
          }
          return child;
        }
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (_, __, ___) {
        // Even on error, start timer so the viewer doesn't get stuck.
        if (!_reported) {
          _reported = true;
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => widget.onReady(_kImageDuration),
          );
        }
        return Center(
          child: Icon(Icons.broken_image, color: colorScheme.onPrimary, size: 56),
        );
      },
    );
  }
}

// ── Video frame — up to 60-second cap ──────────────────────────────────────

class _StoryVideo extends StatefulWidget {
  final String url;
  final ValueChanged<Duration> onReady;

  const _StoryVideo({required this.url, required this.onReady});

  @override
  State<_StoryVideo> createState() => _StoryVideoState();
}

class _StoryVideoState extends State<_StoryVideo> {
  late final VideoPlayerController _controller;
  bool _isReady = false;
  bool _reported = false;
  Timer? _capTimer;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..setLooping(false)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _isReady = true);
        _controller.play();

        // Clamp display duration to 60 seconds.
        final videoDuration = _controller.value.duration;
        final displayDuration = videoDuration > _kVideoMaxDuration
            ? _kVideoMaxDuration
            : videoDuration;

        if (!_reported) {
          _reported = true;
          widget.onReady(displayDuration);
        }

        // If video is longer than 60 s, forcibly stop it at the cap.
        if (videoDuration > _kVideoMaxDuration) {
          _capTimer = Timer(_kVideoMaxDuration, () {
            if (mounted) _controller.pause();
          });
        }
      });
  }

  @override
  void dispose() {
    _capTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady) {
      return const Center(child: CircularProgressIndicator());
    }
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: _controller.value.size.width,
        height: _controller.value.size.height,
        child: VideoPlayer(_controller),
      ),
    );
  }
}
