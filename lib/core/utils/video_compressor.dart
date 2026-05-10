import 'dart:io';
import 'dart:developer' as developer;
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:video_compress/video_compress.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

/// Result of a video compression operation.
class VideoCompressionResult {
  final File file;
  final int originalBytes;
  final int compressedBytes;
  final Uint8List? thumbnail;
  final Duration? duration;

  const VideoCompressionResult({
    required this.file,
    required this.originalBytes,
    required this.compressedBytes,
    this.thumbnail,
    this.duration,
  });

  double get compressionRatio =>
      originalBytes > 0 ? compressedBytes / originalBytes : 1.0;

  String get summary =>
      '${(originalBytes / 1024 / 1024).toStringAsFixed(1)} MB → '
      '${(compressedBytes / 1024 / 1024).toStringAsFixed(1)} MB '
      '(${((1 - compressionRatio) * 100).toStringAsFixed(0)}% saved)';
}

/// Validates and compresses video files before Supabase upload.
///
/// Uses [video_compress] for transcoding and [video_thumbnail] for thumbnails.
/// Falls back gracefully to the original file if compression fails.
class VideoCompressor {
  /// Maximum allowed file size (50 MB).
  static const int maxFileSizeBytes = 50 * 1024 * 1024;

  /// Maximum video duration in seconds.
  static const int maxDurationSeconds = 60;

  /// Minimum size before compression is attempted (5 MB).
  static const int _minSizeToCompress = 5 * 1024 * 1024;

  /// Validates that [file] does not exceed [maxFileSizeBytes].
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

  /// Validates that the video does not exceed [maxDurationSeconds].
  static Future<Duration?> getAndValidateDuration(String videoPath) async {
    try {
      final info = await VideoCompress.getMediaInfo(videoPath);
      if (info.duration == null) return null;
      final durationMs = info.duration!;
      if (durationMs > maxDurationSeconds * 1000) {
        throw ArgumentError(
          'Video is too long (${(durationMs / 1000).toStringAsFixed(0)}s). '
          'Maximum allowed duration is ${maxDurationSeconds}s.',
        );
      }
      return Duration(milliseconds: durationMs.toInt());
    } catch (e) {
      if (e is ArgumentError) rethrow;
      // Media info retrieval failed — skip duration check
      developer.log('Could not get video duration: $e', name: 'VideoCompressor');
      return null;
    }
  }

  /// Compresses [file] and returns a [VideoCompressionResult].
  ///
  /// Validates size and duration before compression. Falls back to the
  /// original file if compression fails or produces a larger output.
  static Future<VideoCompressionResult> compress(
    File file, {
    VideoQuality quality = VideoQuality.MediumQuality,
  }) async {
    validateSize(file);
    final originalBytes = file.lengthSync();
    final duration = await getAndValidateDuration(file.path);
    final thumbnail = await _generateThumbnail(file.path);

    if (originalBytes < _minSizeToCompress) {
      return VideoCompressionResult(
        file: file,
        originalBytes: originalBytes,
        compressedBytes: originalBytes,
        thumbnail: thumbnail,
        duration: duration,
      );
    }

    try {
      final info = await VideoCompress.compressVideo(
        file.path,
        quality: quality,
        includeAudio: true,
      );

      if (info == null || info.file == null) {
        developer.log('Compression returned null, using original', name: 'VideoCompressor');
        return VideoCompressionResult(
          file: file,
          originalBytes: originalBytes,
          compressedBytes: originalBytes,
          thumbnail: thumbnail,
          duration: duration,
        );
      }

      final compressedFile = info.file!;
      final compressedBytes = compressedFile.lengthSync();

      if (compressedBytes >= originalBytes) {
        developer.log('Compression increased size, using original', name: 'VideoCompressor');
        return VideoCompressionResult(
          file: file,
          originalBytes: originalBytes,
          compressedBytes: originalBytes,
          thumbnail: thumbnail,
          duration: duration,
        );
      }

      final result = VideoCompressionResult(
        file: compressedFile,
        originalBytes: originalBytes,
        compressedBytes: compressedBytes,
        thumbnail: thumbnail,
        duration: duration,
      );
      developer.log('Compression: ${result.summary}', name: 'VideoCompressor');
      return result;
    } catch (e, st) {
      developer.log(
        'Compression failed, falling back to original: $e',
        name: 'VideoCompressor',
        error: e,
        stackTrace: st,
      );
      return VideoCompressionResult(
        file: file,
        originalBytes: originalBytes,
        compressedBytes: originalBytes,
        thumbnail: thumbnail,
        duration: duration,
      );
    }
  }

  /// Saves a [Uint8List] thumbnail to a temp file and returns the [File].
  static Future<File?> saveThumbnailToFile(Uint8List bytes) async {
    try {
      final dir = await getTemporaryDirectory();
      final path = p.join(dir.path, 'thumb_${DateTime.now().millisecondsSinceEpoch}.jpg');
      return await File(path).writeAsBytes(bytes);
    } catch (e, st) {
      developer.log('Thumbnail save failed: $e', name: 'VideoCompressor', error: e, stackTrace: st);
      return null;
    }
  }

  /// Cancel an in-progress compression.
  static Future<void> cancelCompression() => VideoCompress.cancelCompression();

  static Future<Uint8List?> _generateThumbnail(String videoPath) async {
    try {
      return await VideoThumbnail.thumbnailData(
        video: videoPath,
        imageFormat: ImageFormat.JPEG,
        maxWidth: 512,
        quality: 75,
      );
    } catch (e) {
      developer.log('Thumbnail generation failed: $e', name: 'VideoCompressor');
      return null;
    }
  }
}
