enum PostMediaType { image, video }

PostMediaType postMediaTypeFromPath(String path) {
  final cleanPath = Uri.tryParse(path)?.path ?? path;
  final ext = cleanPath.split('.').last.toLowerCase();
  return switch (ext) {
    'mp4' || 'mov' || 'm4v' || 'webm' || 'avi' || 'mkv' => PostMediaType.video,
    _ => PostMediaType.image,
  };
}

bool isVideoMedia(String path) =>
    postMediaTypeFromPath(path) == PostMediaType.video;
