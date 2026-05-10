import 'dart:io';
import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

/// Compression result containing the compressed file and metadata.
class CompressionResult {
  final File file;
  final int originalBytes;
  final int compressedBytes;

  const CompressionResult({
    required this.file,
    required this.originalBytes,
    required this.compressedBytes,
  });

  double get compressionRatio =>
      originalBytes > 0 ? compressedBytes / originalBytes : 1.0;

  String get summary =>
      '${(originalBytes / 1024).toStringAsFixed(0)} KB → '
      '${(compressedBytes / 1024).toStringAsFixed(0)} KB '
      '(${((1 - compressionRatio) * 100).toStringAsFixed(0)}% saved)';
}

/// Validates and compresses images before Supabase upload.
///
/// Uses [flutter_image_compress] which runs natively off the UI thread.
/// Falls back gracefully if compression fails, returning the original file.
class ImageCompressor {
  /// Maximum allowed file size in bytes (10 MB).
  static const int maxFileSizeBytes = 10 * 1024 * 1024;

  /// Target quality for compressed images (0–100).
  static const int _defaultQuality = 80;

  /// Maximum dimension (width or height) after compression.
  static const int _defaultMaxDimension = 1920;

  /// Minimum image size to trigger compression (skip tiny images).
  static const int _minSizeToCompress = 200 * 1024; // 200 KB

  /// Validates that [file] does not exceed [maxFileSizeBytes].
  ///
  /// Throws [ArgumentError] with a user-friendly message if too large.
  static void validateSize(File file, [int? maxSizeLimit]) {
    final limit = maxSizeLimit ?? maxFileSizeBytes;
    final bytes = file.lengthSync();
    if (bytes > limit) {
      throw ArgumentError(
        'File is too large (${(bytes / 1024 / 1024).toStringAsFixed(1)} MB). '
        'Maximum allowed size is ${limit ~/ 1024 ~/ 1024} MB.',
      );
    }
  }

  /// Compresses an image file and returns a [CompressionResult].
  ///
  /// If the image is already small enough or compression fails, returns the
  /// original file wrapped in a [CompressionResult].
  ///
  /// Parameters:
  /// - [file]: Source image file.
  /// - [quality]: JPEG quality 0–100 (default 80).
  /// - [maxDimension]: Max width/height in pixels (default 1920).
  static Future<CompressionResult> compress(
    File file, {
    int quality = _defaultQuality,
    int maxDimension = _defaultMaxDimension,
  }) async {
    final originalBytes = await file.length();

    // Skip compression for small files
    if (originalBytes < _minSizeToCompress) {
      return CompressionResult(
        file: file,
        originalBytes: originalBytes,
        compressedBytes: originalBytes,
      );
    }

    try {
      final ext = p.extension(file.path).toLowerCase().replaceAll('.', '');
      final format = _formatFromExtension(ext);
      final targetPath = await _buildTargetPath(file.path, format);

      final result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: maxDimension,
        minHeight: maxDimension,
        format: format,
      );

      if (result == null) {
        developer.log(
          'Image compression returned null, using original',
          name: 'ImageCompressor',
        );
        return CompressionResult(
          file: file,
          originalBytes: originalBytes,
          compressedBytes: originalBytes,
        );
      }

      final compressedFile = File(result.path);
      final compressedBytes = await compressedFile.length();

      final cr = CompressionResult(
        file: compressedFile,
        originalBytes: originalBytes,
        compressedBytes: compressedBytes,
      );
      developer.log('Compression: ${cr.summary}', name: 'ImageCompressor');
      return cr;
    } catch (e, st) {
      developer.log(
        'Compression failed, falling back to original: $e',
        name: 'ImageCompressor',
        error: e,
        stackTrace: st,
      );
      return CompressionResult(
        file: file,
        originalBytes: originalBytes,
        compressedBytes: originalBytes,
      );
    }
  }

  /// Batch-compresses multiple images using [compute] for off-thread work.
  static Future<List<CompressionResult>> compressBatch(
    List<File> files, {
    int quality = _defaultQuality,
    int maxDimension = _defaultMaxDimension,
  }) async {
    return compute(
      _compressBatchIsolate,
      _BatchParams(files, quality, maxDimension),
    );
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  static CompressFormat _formatFromExtension(String ext) {
    return switch (ext) {
      'png' => CompressFormat.png,
      'webp' => CompressFormat.webp,
      'heic' || 'heif' => CompressFormat.heic,
      _ => CompressFormat.jpeg,
    };
  }

  static Future<String> _buildTargetPath(
    String sourcePath,
    CompressFormat format,
  ) async {
    final dir = await getTemporaryDirectory();
    final name = p.basenameWithoutExtension(sourcePath);
    final ext = switch (format) {
      CompressFormat.png => 'png',
      CompressFormat.webp => 'webp',
      CompressFormat.heic => 'heic',
      _ => 'jpg',
    };
    return '${dir.path}/${name}_compressed.$ext';
  }
}

// Isolate payload for batch compression
class _BatchParams {
  final List<File> files;
  final int quality;
  final int maxDimension;
  const _BatchParams(this.files, this.quality, this.maxDimension);
}

Future<List<CompressionResult>> _compressBatchIsolate(
  _BatchParams params,
) async {
  final results = <CompressionResult>[];
  for (final file in params.files) {
    final result = await ImageCompressor.compress(
      file,
      quality: params.quality,
      maxDimension: params.maxDimension,
    );
    results.add(result);
  }
  return results;
}
