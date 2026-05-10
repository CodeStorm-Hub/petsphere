import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petsphere/core/constants/supabase_config.dart';
import 'package:petsphere/core/utils/image_compressor.dart';

/// A utility class for picking media and uploading it to Supabase Storage.
///
/// Automatically compresses images before upload and validates file sizes.
class ImageUploadHelper {
  static final _picker = ImagePicker();

  /// Maximum video duration allowed (Phase 3.2 anti-pattern fix).
  static const Duration maxVideoDuration = Duration(minutes: 2);

  /// Pick an image from the gallery. Returns null if the user cancelled.
  static Future<File?> pickFromGallery() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 2048,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  /// Pick a photo from the camera. Returns null if the user cancelled.
  static Future<File?> pickFromCamera() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 2048,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  /// Pick a video from the gallery. Returns null if the user cancelled.
  static Future<File?> pickVideoFromGallery() async {
    final xFile = await _picker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: maxVideoDuration,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  /// Record a video with the camera. Returns null if the user cancelled.
  static Future<File?> pickVideoFromCamera() async {
    final xFile = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: maxVideoDuration,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  /// Upload [file] to the given Supabase [bucket] under [path].
  ///
  /// For images, automatically compresses before uploading.
  /// Validates file size (max 10 MB) before any upload.
  /// Returns the public URL of the uploaded file.
  static Future<String> upload({
    required File file,
    required String bucket,
    required String path,
    bool compress = true,
  }) async {
    // Validate file size first
    ImageCompressor.validateSize(file);

    final ext = file.path.split('.').last.toLowerCase();
    final isImage = _imageExtensions.contains(ext);

    // Compress images automatically
    final uploadFile = (compress && isImage)
        ? (await ImageCompressor.compress(file)).file
        : file;

    final contentType = _contentTypeFor(ext);

    await supabase.storage
        .from(bucket)
        .upload(
          path,
          uploadFile,
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );

    return supabase.storage.from(bucket).getPublicUrl(path);
  }

  /// Convenience: Pick from gallery, compress, and upload in one call.
  /// Returns null if the user cancelled.
  static Future<String?> pickAndUpload({
    required String bucket,
    required String folder,
    bool compress = true,
  }) async {
    final file = await pickFromGallery();
    if (file == null) return null;

    final ext = file.path.split('.').last;
    final path = '$folder/${DateTime.now().millisecondsSinceEpoch}.$ext';
    return upload(file: file, bucket: bucket, path: path, compress: compress);
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  static const _imageExtensions = {
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'heic',
    'heif',
  };

  static String _contentTypeFor(String ext) {
    return switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'heic' || 'heif' => 'image/heic',
      'mp4' => 'video/mp4',
      'mov' => 'video/quicktime',
      'm4v' => 'video/x-m4v',
      'webm' => 'video/webm',
      'avi' => 'video/x-msvideo',
      'mkv' => 'video/x-matroska',
      _ => 'image/jpeg',
    };
  }
}
