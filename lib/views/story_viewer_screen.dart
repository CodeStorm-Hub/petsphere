import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../controllers/feed_controller.dart';
import '../controllers/pet_controller.dart';
import '../models/story_model.dart';
import '../utils/media_utils.dart';

class StoryViewerScreen extends ConsumerStatefulWidget {
  final String petId;

  const StoryViewerScreen({super.key, required this.petId});

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen> {
  final _pageController = PageController();
  int _index = 0;

  void _next(int storyCount) {
    if (_index >= storyCount - 1) {
      context.pop();
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
    final feedState = ref.watch(feedProvider);
    final stories = feedState.stories
        .where((story) => story.pet.id == widget.petId)
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    final myPetIds = ref.watch(petProvider).myPets.map((pet) => pet.id).toSet();
    final canDelete = myPetIds.contains(widget.petId);

    if (stories.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('This story is no longer available.',
                  style: TextStyle(color: Colors.white)),
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
            PageView.builder(
              controller: _pageController,
              itemCount: stories.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) {
                final story = stories[index];
                return _StoryPage(
                  story: story,
                  onPrevious: _previous,
                  onNext: () => _next(stories.length),
                );
              },
            ),
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Column(
                children: [
                  Row(
                    children: List.generate(stories.length, (index) {
                      return Expanded(
                        child: Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            color: index <= _index
                                ? Colors.white
                                : Colors.white.withAlpha(80),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundImage: stories[_index].pet.profileImageUrl.isNotEmpty
                            ? NetworkImage(stories[_index].pet.profileImageUrl)
                            : null,
                        child: stories[_index].pet.profileImageUrl.isEmpty
                            ? const Icon(Icons.pets)
                            : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          stories[_index].pet.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
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
                          icon: const Icon(Icons.delete_outline,
                              color: Colors.white),
                        ),
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close, color: Colors.white),
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

class _StoryPage extends StatelessWidget {
  final StoryModel story;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _StoryPage({
    required this.story,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (isVideoMedia(story.mediaUrl))
          _StoryVideo(url: story.mediaUrl)
        else
          Image.network(
            story.mediaUrl,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.broken_image, color: Colors.white, size: 56),
            ),
          ),
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
        if (story.caption.isNotEmpty)
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: Text(
              story.caption,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                shadows: [Shadow(color: Colors.black87, blurRadius: 8)],
              ),
            ),
          ),
      ],
    );
  }
}

class _StoryVideo extends StatefulWidget {
  final String url;

  const _StoryVideo({required this.url});

  @override
  State<_StoryVideo> createState() => _StoryVideoState();
}

class _StoryVideoState extends State<_StoryVideo> {
  late final VideoPlayerController _controller;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..setLooping(true)
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _isReady = true);
        _controller.play();
      });
  }

  @override
  void dispose() {
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
