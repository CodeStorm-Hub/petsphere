import 'dart:io';
import 'dart:developer' as developer;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';

/// Result of a video compression operation.
class VideoCompressionResult {
  final File file;
  final int originalBytes;
  final int compressedBytes;
  final Uint8List? thumbnail;

  const VideoCompressionResult({
    required this.file,
    required this.originalBytes,
    required this.compressedBytes,
    this.thumbnail,
  });

  double get compressionRatio =>
      originalBytes > 0 ? compressedBytes / originalBytes : 1.0;

  String get summary =>
      '${(originalBytes / 1024 / 1024).toStringAsFixed(1)} MB → '
      '${(compressedBytes / 1024 / 1024).toStringAsFixed(1)} MB '
      '(${((1 - compressionRatio) * 100).toStringAsFixed(0)}% saved)';
}

/// Validates video files and generates thumbnails before Supabase upload.
///
/// NOTE: Full transcoding requires a native plugin (e.g. ffmpeg_kit_flutter).
/// This utility enforces size/duration limits and generates thumbnails using
/// [video_thumbnail]. Add ffmpeg_kit_flutter_min to pubspec for transcoding.
class VideoCompressor {
  /// Maximum video file size (50 MB).
  static const int maxFileSizeBytes = 50 * 1024 * 1024;

  /// Minimum size before we attempt any processing (1 MB).
  static const int _minSizeToProcess = 1 * 1024 * 1024;

  /// Validates file size and returns the file wrapped in a result.
  ///
  /// Throws [ArgumentError] if the file exceeds [maxFileSizeBytes].
  static void validateSize(File file, [int? maxSizeLimit]) {
    final limit = maxSizeLimit ?? maxFileSizeBytes;
    final bytes = file.lengthSync();
    if (bytes > limit) {
      throw ArgumentError(
        'Video is too large (${(bytes / 1024 / 1024).toStringAsFixed(1)} MB). '
        'Maximum allowed size is ${limit ~/ 1024 ~/ 1024} MB.',
      );
    }
  }

  /// Generates a JPEG thumbnail from the first frame of [videoFile].
  ///
  /// Returns null if thumbnail generation fails.
  static Future<Uint8List?> generateThumbnail(
    File videoFile, {
    int maxWidth = 512,
    int quality = 75,
  }) async {
    try {
      return await VideoThumbnail.thumbnailData(
        video: videoFile.path,
        imageFormat: ImageFormat.JPEG,
        maxWidth: maxWidth,
        quality: quality,
      );
    } catch (e, st) {
      developer.log(
        'Thumbnail generation failed: $e',
        name: 'VideoCompressor',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Saves a thumbnail [Uint8List] to a temp file and returns it.
  static Future<File?> saveThumbnailToFile(Uint8List bytes) async {
    try {
      final dir = await getTemporaryDirectory();
      final path = p.join(
        dir.path,
        'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      final file = File(path);
      await file.writeAsBytes(bytes);
      return file;
    } catch (e, st) {
      developer.log(
        'Thumbnail save failed: $e',
        name: 'VideoCompressor',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  /// Validates a video file and generates its thumbnail.
  ///
  /// Does not transcode — enforces the size limit only.
  /// Returns a [VideoCompressionResult] with the original file and thumbnail.
  static Future<VideoCompressionResult> process(File videoFile) async {
    validateSize(videoFile);
    final originalBytes = await videoFile.length();

    Uint8List? thumbnail;
    if (originalBytes >= _minSizeToProcess) {
      thumbnail = await generateThumbnail(videoFile);
    }

    developer.log(
      'Video processed: ${(originalBytes / 1024 / 1024).toStringAsFixed(1)} MB',
      name: 'VideoCompressor',
    );

    return VideoCompressionResult(
      file: videoFile,
      originalBytes: originalBytes,
      compressedBytes: originalBytes,
      thumbnail: thumbnail,
    );
  }
}
