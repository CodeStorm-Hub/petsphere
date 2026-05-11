import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:petfolio/core/constants/supabase_config.dart';
import 'package:petfolio/core/utils/image_compressor.dart';

/// A utility class for picking media and uploading it to Supabase Storage.
///
/// Automatically compresses images before upload and validates file sizes.
/// Enforces pathing that matches the RLS policies in Supabase.
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

  /// Specialized: Upload a pet's profile image to the 'pet-images' bucket.
  /// Path: `avatars/uid_timestamp.ext` (Matches RLS policy)
  static Future<String> uploadPetAvatar(File file) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('User not authenticated');

    final ext = file.path.split('.').last.toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'avatars/${uid}_$timestamp.$ext';

    return upload(file: file, bucket: kBucketAvatars, path: path);
  }

  /// Specialized: Upload a user's profile image to the 'avatars' bucket.
  /// Path: `avatars/uid_timestamp.ext` (Matches RLS policy)
  static Future<String> uploadUserAvatar(File file) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('User not authenticated');

    final ext = file.path.split('.').last.toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'avatars/${uid}_$timestamp.$ext';

    return upload(file: file, bucket: kBucketAvatars, path: path);
  }

  /// Specialized: Upload post media to the 'post-media' bucket.
  /// Path: `uid/timestamp.ext` (Matches RLS policy)
  static Future<String> uploadPostMedia(File file) async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) throw Exception('User not authenticated');

    final ext = file.path.split('.').last.toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = '$uid/$timestamp.$ext';

    return upload(file: file, bucket: kBucketPostMedia, path: path);
  }

  /// Specialized: Upload story media to the 'post-media' bucket.
  /// Path: `stories/petId/timestamp.ext` (Matches RLS policy)
  static Future<String> uploadStoryMedia(File file, String petId) async {
    final ext = file.path.split('.').last.toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'stories/$petId/$timestamp.$ext';

    return upload(file: file, bucket: kBucketPostMedia, path: path);
  }

  /// Specialized: Upload chat media to the 'post-media' bucket.
  /// Path: `chat/threadId/timestamp.ext`
  static Future<String> uploadChatMedia(File file, String threadId) async {
    final ext = file.path.split('.').last.toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'chat/$threadId/$timestamp.$ext';

    return upload(file: file, bucket: kBucketPostMedia, path: path);
  }

  /// Specialized: Upload lost/found report images to the 'pet-images' bucket.
  /// Path: `lost-found/uid_timestamp.ext`
  static Future<String> uploadLostFoundImage(
    File file,
    String reporterId,
  ) async {
    final ext = file.path.split('.').last.toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'lost-found/${reporterId}_$timestamp.$ext';

    return upload(file: file, bucket: kBucketPetImages, path: path);
  }

  /// Specialized: Upload product images to the 'product-images' bucket.
  /// Path: `products/productId/timestamp.ext`
  static Future<String> uploadProductImage(File file, String productId) async {
    final ext = file.path.split('.').last.toLowerCase();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final path = 'products/$productId/$timestamp.$ext';

    return upload(file: file, bucket: kBucketProductImages, path: path);
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
      _ => 'application/octet-stream',
    };
  }
}
