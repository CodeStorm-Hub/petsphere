import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../../models/post_model.dart';

/// Instagram-style edge-to-edge post card.
///
/// Layout (top → bottom):
///   1. Header: 32×32 avatar with story ring · username (bold) + verified ·
///      pet breed / time-ago subtitle · 3-dot menu
///   2. 1:1 media (double-tap to like, animated heart overlay)
///   3. Action row: heart, comment, share · bookmark (right-aligned)
///   4. "X likes" line
///   5. RichText caption: bold username + caption text + "more" (on overflow)
///   6. "View all N comments" link (if any)
///   7. Time-ago / date
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

class _PostCardState extends State<PostCard> with TickerProviderStateMixin {
  bool _isSaved = false;
  bool _showHeart = false;
  bool _captionExpanded = false;

  void _handleDoubleTap() {
    final isLiked = widget.post.likedByPetIds.contains(widget.currentPetId);
    if (!isLiked) widget.onLikeToggle();
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
                  setState(() => _isSaved = !_isSaved);
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

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    if (diff.inDays < 7) return '${diff.inDays}d';
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  String _formatCount(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i != 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLiked = widget.post.likedByPetIds.contains(widget.currentPetId);
    final likeCount = widget.post.likedByPetIds.length;
    final commentCount = widget.post.comments.length;
    final caption = widget.post.caption;
    final timeAgo = _formatTimeAgo(widget.post.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 4, 6),
            child: Row(
              children: [
                GestureDetector(
                  onTap: widget.onPetTap,
                  child: _StoryRingAvatar(
                    imageUrl: widget.post.pet.profileImageUrl,
                    radius: 16,
                    showRing: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: widget.onPetTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.post.pet.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13.5,
                                  color: colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (widget.post.pet.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(Icons.verified,
                                  size: 14, color: Color(0xFF1DA1F2)),
                            ],
                          ],
                        ),
                        if (widget.post.pet.breed.isNotEmpty)
                          Text(
                            widget.post.pet.breed,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  iconSize: 22,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(Icons.more_horiz, color: colorScheme.onSurface),
                  onPressed: _showSettingsSheet,
                ),
              ],
            ),
          ),

          // ── Media (1:1, edge-to-edge) ──────────────────────────────
          GestureDetector(
            onDoubleTap: _handleDoubleTap,
            child: AspectRatio(
              aspectRatio: 1,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.post.mediaUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(
                        color: colorScheme.surfaceContainerHighest,
                        child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2)),
                      );
                    },
                    errorBuilder: (ctx, err, stack) => Container(
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(Icons.pets,
                          size: 56, color: colorScheme.onSurfaceVariant),
                    ),
                  ),
                  IgnorePointer(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 250),
                      opacity: _showHeart ? 1.0 : 0.0,
                      child: Center(
                        child: AnimatedScale(
                          scale: _showHeart ? 1.0 : 0.4,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutBack,
                          child: const Icon(
                            Icons.favorite,
                            size: 96,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                color: Color(0x66000000),
                                blurRadius: 24,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Action row ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 4, 6, 0),
            child: Row(
              children: [
                _ActionIcon(
                  onTap: widget.onLikeToggle,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) =>
                        ScaleTransition(scale: anim, child: child),
                    child: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isLiked),
                      size: 26,
                      color: isLiked
                          ? const Color(0xFFED4956)
                          : colorScheme.onSurface,
                    ),
                  ),
                ),
                _ActionIcon(
                  onTap: widget.onCommentIconTap,
                  child: Icon(Icons.mode_comment_outlined,
                      size: 26, color: colorScheme.onSurface),
                ),
                _ActionIcon(
                  onTap: widget.onShareIconTap,
                  child: Transform.rotate(
                    angle: -0.5,
                    child: Icon(Icons.send_outlined,
                        size: 26, color: colorScheme.onSurface),
                  ),
                ),
                const Spacer(),
                _ActionIcon(
                  onTap: () {
                    setState(() => _isSaved = !_isSaved);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            _isSaved ? 'Post Saved!' : 'Post Unsaved.'),
                      ),
                    );
                  },
                  child: Icon(
                    _isSaved ? Icons.bookmark : Icons.bookmark_border,
                    size: 26,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // ── Like count ─────────────────────────────────────────────
          if (likeCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 2, 14, 0),
              child: Text(
                likeCount == 1
                    ? '1 like'
                    : '${_formatCount(likeCount)} likes',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13.5,
                  color: colorScheme.onSurface,
                ),
              ),
            ),

          // ── Caption (username + text, expandable) ──────────────────
          if (caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
              child: _ExpandableCaption(
                username: widget.post.pet.name,
                caption: caption,
                expanded: _captionExpanded,
                onUsernameTap: widget.onPetTap,
                onMoreTap: () => setState(() => _captionExpanded = true),
                onSurface: colorScheme.onSurface,
                onSurfaceVariant: colorScheme.onSurfaceVariant,
              ),
            ),

          // ── "View all N comments" ──────────────────────────────────
          if (commentCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 4, 14, 0),
              child: GestureDetector(
                onTap: widget.onCommentIconTap,
                child: Text(
                  commentCount == 1
                      ? 'View 1 comment'
                      : 'View all ${_formatCount(commentCount)} comments',
                  style: TextStyle(
                    fontSize: 13,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),

          // ── Timestamp ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 6, 14, 4),
            child: Text(
              timeAgo,
              style: TextStyle(
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Story-ring avatar (Instagram-style gradient ring) ──────────────────────
class _StoryRingAvatar extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final bool showRing;

  const _StoryRingAvatar({
    required this.imageUrl,
    this.radius = 16,
    this.showRing = true,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final inner = CircleAvatar(
      radius: radius,
      backgroundImage: imageUrl.isNotEmpty ? NetworkImage(imageUrl) : null,
      backgroundColor: colorScheme.surfaceContainerHighest,
      child: imageUrl.isEmpty
          ? Icon(Icons.pets,
              size: radius * 0.9, color: colorScheme.onSurfaceVariant)
          : null,
    );

    if (!showRing) return inner;

    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [
            Color(0xFFFFC837),
            Color(0xFFFF8008),
            Color(0xFFFE2D49),
            Color(0xFFBC2A8D),
            Color(0xFF4F5BD5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        padding: const EdgeInsets.all(2),
        child: inner,
      ),
    );
  }
}

// ── Reusable action icon button (tighter spacing than IconButton) ─────────
class _ActionIcon extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _ActionIcon({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: onTap,
      radius: 22,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: child,
      ),
    );
  }
}

// ── Caption with inline username + "more" expansion ───────────────────────
class _ExpandableCaption extends StatelessWidget {
  final String username;
  final String caption;
  final bool expanded;
  final VoidCallback? onUsernameTap;
  final VoidCallback onMoreTap;
  final Color onSurface;
  final Color onSurfaceVariant;

  const _ExpandableCaption({
    required this.username,
    required this.caption,
    required this.expanded,
    required this.onUsernameTap,
    required this.onMoreTap,
    required this.onSurface,
    required this.onSurfaceVariant,
  });

  @override
  Widget build(BuildContext context) {
    final usernameSpan = TextSpan(
      text: username,
      style: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 13.5,
        color: onSurface,
      ),
      recognizer: onUsernameTap != null
          ? (TapGestureRecognizer()..onTap = onUsernameTap)
          : null,
    );
    final captionStyle = TextStyle(
      fontSize: 13.5,
      height: 1.35,
      color: onSurface,
    );

    if (expanded) {
      return RichText(
        text: TextSpan(
          children: [
            usernameSpan,
            const TextSpan(text: '  '),
            TextSpan(text: caption, style: captionStyle),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final fullText = TextSpan(
          children: [
            usernameSpan,
            const TextSpan(text: '  '),
            TextSpan(text: caption, style: captionStyle),
          ],
        );
        final tp = TextPainter(
          text: fullText,
          maxLines: 2,
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: constraints.maxWidth);

        if (!tp.didExceedMaxLines) {
          return RichText(text: fullText);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              text: fullText,
            ),
            const SizedBox(height: 2),
            GestureDetector(
              onTap: onMoreTap,
              child: Text(
                'more',
                style: TextStyle(
                  fontSize: 13,
                  color: onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
