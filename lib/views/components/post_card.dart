import 'package:flutter/material.dart';
import '../../models/post_model.dart';
import 'pet_avatar.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final String currentPetId;
  final VoidCallback onLikeToggle;
  final VoidCallback onCommentIconTap;
  final VoidCallback onShareIconTap;
  final VoidCallback? onPetTap;

  const PostCard({
    super.key,
    required this.post,
    required this.currentPetId,
    required this.onLikeToggle,
    required this.onCommentIconTap,
    required this.onShareIconTap,
    this.onPetTap,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isSaved = false;
  bool _showHeart = false;

  void _handleDoubleTap() {
    final isLiked = widget.post.likedByPetIds.contains(widget.currentPetId);
    if (!isLiked) {
      widget.onLikeToggle();
    }
    setState(() => _showHeart = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  void _showSettingsSheet() {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withAlpha(76),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: Text(_isSaved ? 'Unsave Post' : 'Save Post'),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _isSaved = !_isSaved;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(_isSaved ? 'Post Saved!' : 'Post Unsaved.'),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.visibility_off_outlined),
                title: const Text('Hide'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Post hidden. We\'ll show you fewer like this.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.report_problem_outlined,
                  color: Colors.redAccent,
                ),
                title: const Text(
                  'Report',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Thanks — our team will review this post.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Derives a mood label from the caption text
  String _moodBadge(String caption) {
    final lower = caption.toLowerCase();
    if (lower.contains('play') || lower.contains('fun') || lower.contains('ball')) return 'Playful';
    if (lower.contains('nap') || lower.contains('sleep') || lower.contains('rest')) return 'Napping';
    if (lower.contains('park') || lower.contains('walk') || lower.contains('outdoor')) return 'Outdoors';
    if (lower.contains('eat') || lower.contains('food') || lower.contains('treat')) return 'Mealtime';
    return 'Happy';
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.post.likedByPetIds.contains(widget.currentPetId);
    final mood = _moodBadge(widget.post.caption);
    // Alternate slight rotation for editorial feel
    final rotation = widget.post.id.hashCode.isEven ? -0.012 : 0.012;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF99472C).withAlpha(15),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 10),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onPetTap,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PetAvatar(
                        imageUrl: widget.post.pet.profileImageUrl,
                        hasStory: true,
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.post.pet.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: Color(0xFF35322D),
                            ),
                          ),
                          Text(
                            widget.post.pet.breed,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF625E59),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.more_horiz, color: Color(0xFF625E59)),
                  onPressed: _showSettingsSheet,
                ),
              ],
            ),
          ),

          // ── Image with editorial rotation + mood badge ────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onDoubleTap: _handleDoubleTap,
              child: Transform.rotate(
                angle: rotation,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 4 / 5,
                        child: Image.network(
                          widget.post.mediaUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: const Color(0xFFF3EDE6),
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (ctx, err, stack) => Container(
                            color: const Color(0xFFF3EDE6),
                            child: const Icon(Icons.pets, size: 48, color: Color(0xFF99472C)),
                          ),
                        ),
                      ),
                      // Double-tap heart overlay
                      Positioned.fill(
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 300),
                          opacity: _showHeart ? 1.0 : 0.0,
                          child: Center(
                            child: AnimatedScale(
                              scale: _showHeart ? 1.0 : 0.5,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutBack,
                              child: const Icon(Icons.favorite, size: 80, color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      // Mood badge
                      Positioned(
                        bottom: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(50),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: Colors.white.withAlpha(76)),
                          ),
                          child: Text(
                            mood,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Caption ───────────────────────────────────────────────
          if (widget.post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Text(
                widget.post.caption,
                style: const TextStyle(
                  color: Color(0xFF35322D),
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

          // ── Actions ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Row(
              children: [
                IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isLiked),
                      color: isLiked ? const Color(0xFF99472C) : const Color(0xFF625E59),
                    ),
                  ),
                  onPressed: widget.onLikeToggle,
                ),
                if (widget.post.likedByPetIds.isNotEmpty)
                  Text(
                    '${widget.post.likedByPetIds.length}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF35322D)),
                  ),
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.chat_bubble_outline, color: Color(0xFF625E59)),
                  onPressed: widget.onCommentIconTap,
                ),
                if (widget.post.comments.isNotEmpty)
                  Text(
                    '${widget.post.comments.length}',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF35322D)),
                  ),
                const Spacer(),
                // Share button with secondary-container bg
                GestureDetector(
                  onTap: widget.onShareIconTap,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE087),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.share, size: 18, color: Color(0xFF644F00)),
                  ),
                ),
                const SizedBox(width: 4),
                IconButton(
                  icon: Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    color: const Color(0xFF625E59),
                  ),
                  onPressed: () {
                    setState(() => _isSaved = !_isSaved);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_isSaved ? 'Post Saved!' : 'Post Unsaved.')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
