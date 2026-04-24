import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_config.dart';

/// Web implementation without `dart:io` imports.
class ImageUploadHelper {
  static final _picker = ImagePicker();

  static Future<XFile?> pickXFileFromGallery() async {
    return _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1200,
    );
  }

  static Future<XFile?> pickXFileFromCamera() async {
    return _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
      maxWidth: 1200,
    );
  }

  static Future<String> uploadXFile({
    required XFile file,
    required String bucket,
    required String path,
  }) async {
    final bytes = await file.readAsBytes();
    await supabase.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: _contentTypeForPath(path),
          ),
        );

    return supabase.storage.from(bucket).getPublicUrl(path);
  }

  static String _contentTypeForPath(String path) {
    final normalized = path.trim();
    final lastDot = normalized.lastIndexOf('.');
    if (normalized.isEmpty || lastDot < 0 || lastDot == normalized.length - 1) {
      return 'image/jpeg';
    }

    final extension = normalized.substring(lastDot + 1).trim().toLowerCase();
    if (extension.isEmpty) return 'image/jpeg';
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/jpeg';
    }
  }
}
