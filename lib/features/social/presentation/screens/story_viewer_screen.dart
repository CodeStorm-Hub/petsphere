import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_view/story_view.dart';
import 'package:petfolio/features/social/data/models/story_model.dart';
import 'package:petfolio/features/pet/data/models/pet_model.dart';
import 'package:petfolio/features/social/presentation/controllers/feed_controller.dart';
import 'package:petfolio/core/widgets/async_value_widget.dart';
import 'package:google_fonts/google_fonts.dart';

class StoryViewerScreen extends ConsumerStatefulWidget {

  const StoryViewerScreen({super.key, required this.petId});
  final String petId;

  @override
  ConsumerState<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends ConsumerState<StoryViewerScreen> {
  final StoryController _controller = StoryController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final storiesAsync = ref.watch(petStoriesProvider(widget.petId));

    return Scaffold(
      backgroundColor: Colors.black,
      body: AsyncValueWidget<List<StoryModel>>(
        value: storiesAsync,
        data: (List<StoryModel> stories) {
          if (stories.isEmpty) {
            return const _EmptyStoriesView();
          }

          return Stack(
            children: [
              StoryView(
                storyItems: stories.map((story) {
                  if (story.isVideo) {
                    return StoryItem.pageVideo(
                      story.mediaUrl,
                      controller: _controller,
                      caption: story.caption.isNotEmpty
                          ? Text(
                              story.caption,
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            )
                          : null,
                    );
                  } else {
                    return StoryItem.pageImage(
                      url: story.mediaUrl,
                      controller: _controller,
                      caption: story.caption.isNotEmpty
                          ? Text(
                              story.caption,
                              style: GoogleFonts.dmSans(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            )
                          : null,
                      duration: const Duration(seconds: 7),
                    );
                  }
                }).toList(),
                onStoryShow: (s, index) {},
                onComplete: () => Navigator.of(context).pop(),
                onVerticalSwipeComplete: (direction) {
                  if (direction == Direction.down) {
                    Navigator.of(context).pop();
                  }
                },
                controller: _controller,
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 20,
                left: 16,
                right: 16,
                child: _StoryHeader(pet: stories.first.pet),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StoryHeader extends StatelessWidget {

  const _StoryHeader({required this.pet});
  final PetModel pet;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundImage: NetworkImage(pet.profileImageUrl),
          backgroundColor: Colors.grey[800],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pet.name,
                style: GoogleFonts.dmSans(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${pet.breed} • ${pet.age} years',
                style: GoogleFonts.dmSans(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

class _EmptyStoriesView extends StatelessWidget {
  const _EmptyStoriesView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 64, color: Colors.grey[700]),
          const SizedBox(height: 16),
          Text(
            'No active stories',
            style: GoogleFonts.dmSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check back later for updates!',
            style: GoogleFonts.dmSans(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Go Back',
              style: TextStyle(color: Theme.of(context).primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
