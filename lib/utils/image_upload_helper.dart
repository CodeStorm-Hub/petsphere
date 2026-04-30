import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// A utility class for picking media and uploading it to Supabase Storage.
class ImageUploadHelper {
  static final _picker = ImagePicker();

  /// Pick an image from the gallery. Returns null if the user cancelled.
  static Future<File?> pickFromGallery() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  /// Pick a photo from the camera. Returns null if the user cancelled.
  static Future<File?> pickFromCamera() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1200,
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  /// Pick a video from the gallery. Returns null if the user cancelled.
  static Future<File?> pickVideoFromGallery() async {
    final xFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (xFile == null) return null;
    return File(xFile.path);
  }

  /// Record a video with the camera. Returns null if the user cancelled.
  static Future<File?> pickVideoFromCamera() async {
    final xFile = await _picker.pickVideo(
      source: ImageSource.camera,
      maxDuration: const Duration(minutes: 2),
    );
    if (xFile == null) return null;
    return File(xFile.path);
  }

  /// Upload [file] to the given Supabase [bucket] under [path].
  /// Returns the public URL of the uploaded file.
  static Future<String> upload({
    required File file,
    required String bucket,
    required String path,
  }) async {
    final ext = file.path.split('.').last.toLowerCase();
    final contentType = switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'gif' => 'image/gif',
      'webp' => 'image/webp',
      'heic' => 'image/heic',
      'mp4' => 'video/mp4',
      'mov' => 'video/quicktime',
      'm4v' => 'video/x-m4v',
      'webm' => 'video/webm',
      'avi' => 'video/x-msvideo',
      'mkv' => 'video/x-matroska',
      _ => 'image/jpeg',
    };

    await supabase.storage.from(bucket).upload(
          path,
          file,
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );

    return supabase.storage.from(bucket).getPublicUrl(path);
  }

  /// Convenience: Pick from gallery and upload in one call.
  /// Returns null if the user cancelled.
  static Future<String?> pickAndUpload({
    required String bucket,
    required String folder,
  }) async {
    final file = await pickFromGallery();
    if (file == null) return null;

    final ext = file.path.split('.').last;
    final path = '$folder/${DateTime.now().millisecondsSinceEpoch}.$ext';
    return upload(file: file, bucket: bucket, path: path);
  }
}
