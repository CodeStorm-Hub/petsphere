import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:video_player/video_player.dart';

class PostMedia extends StatefulWidget {

  const PostMedia({
    super.key,
    required this.mediaUrl,
    this.isVideo = false,
    this.aspectRatio,
  });
  final String mediaUrl;
  final bool isVideo;
  final double? aspectRatio;

  @override
  State<PostMedia> createState() => _PostMediaState();
}

class _PostMediaState extends State<PostMedia> {
  VideoPlayerController? _controller;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    debugPrint('PostMedia: Initializing with URL: ${widget.mediaUrl} (isVideo: ${widget.isVideo})');
    if (widget.isVideo) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.mediaUrl));
    try {
      await _controller!.initialize();
      if (mounted) {
        setState(() => _initialized = true);
        await _controller!.setLooping(true);
        await _controller!.setVolume(0); // Mute by default for feed
        await _controller!.play();
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVideo) {
      return _buildVideo();
    }
    return _buildImage();
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: widget.aspectRatio ?? 1.0,
      child: CachedNetworkImage(
        imageUrl: widget.mediaUrl,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator()),
        ),
        errorWidget: (context, url, error) => Container(
          color: Theme.of(context).colorScheme.errorContainer,
          child: const Icon(Icons.error_outline),
        ),
      ),
    ).animate().fade(duration: 400.ms);
  }

  Widget _buildVideo() {
    if (!_initialized || _controller == null) {
      return AspectRatio(
        aspectRatio: widget.aspectRatio ?? 1.0,
        child: Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: const Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: widget.aspectRatio ?? _controller!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller!),
          Positioned(
            bottom: 12,
            right: 12,
            child: CircleAvatar(
              backgroundColor: Colors.black45,
              radius: 16,
              child: IconButton(
                icon: Icon(
                  _controller!.value.volume == 0
                      ? Icons.volume_off
                      : Icons.volume_up,
                  size: 16,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _controller!.setVolume(_controller!.value.volume == 0 ? 1 : 0);
                  });
                },
              ),
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 400.ms);
  }
}
