import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// A utility class for picking images and uploading them to Supabase Storage.
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

  /// Upload [file] to the given Supabase [bucket] under [path].
  /// Returns the public URL of the uploaded file.
  static Future<String> upload({
    required File file,
    required String bucket,
    required String path,
  }) async {
    await supabase.storage.from(bucket).upload(
          path,
          file,
          fileOptions: const FileOptions(upsert: true),
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
