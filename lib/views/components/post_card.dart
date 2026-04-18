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
                  color: Colors.grey.shade300,
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
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.report_problem_outlined,
                  color: Colors.red,
                ),
                title: const Text(
                  'Report',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLiked = widget.post.likedByPetIds.contains(widget.currentPetId);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);
    final mediaCacheWidth = (screenWidth * pixelRatio).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
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
                    const SizedBox(width: 8),
                    Text(
                      widget.post.pet.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: _showSettingsSheet,
              ),
            ],
          ),
        ),

        // Image with double-tap to like
        GestureDetector(
          onDoubleTap: _handleDoubleTap,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  widget.post.mediaUrl,
                  fit: BoxFit.cover,
                  cacheWidth: mediaCacheWidth,
                  filterQuality: FilterQuality.low,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (_, _, _) => Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.error, color: Colors.grey),
                  ),
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showHeart ? 1.0 : 0.0,
                child: AnimatedScale(
                  scale: _showHeart ? 1.0 : 0.5,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOutBack,
                  child: const Icon(
                    Icons.favorite,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Actions
        Row(
          children: [
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isLiked ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(isLiked),
                  color: isLiked ? Colors.red : Colors.black87,
                ),
              ),
              onPressed: widget.onLikeToggle,
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              onPressed: widget.onCommentIconTap,
            ),
            IconButton(
              icon: const Icon(Icons.send_outlined),
              onPressed: widget.onShareIconTap,
            ),
            const Spacer(),
            IconButton(
              icon: Icon(_isSaved ? Icons.bookmark : Icons.bookmark_border),
              color: Colors.black87,
              onPressed: () {
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
          ],
        ),

        // Likes
        if (widget.post.likedByPetIds.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              '${widget.post.likedByPetIds.length} likes',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

        // Caption
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
          child: RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black87),
              children: [
                TextSpan(
                  text: '${widget.post.pet.name} ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: widget.post.caption),
              ],
            ),
          ),
        ),

        // Comments Preview
        if (widget.post.comments.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: InkWell(
              onTap: widget.onCommentIconTap,
              child: Text(
                'View all ${widget.post.comments.length} comments',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ),

        const SizedBox(height: 16),
      ],
    );
  }
}
