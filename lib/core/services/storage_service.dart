import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// A robust service for managing Supabase Storage buckets and file operations.
/// 
/// Provides self-healing capabilities by ensuring required buckets exist 
/// and are correctly configured. Supports cross-platform uploads.
class StorageService {

  StorageService(this._supabase);
  final SupabaseClient _supabase;

  /// Initializes all required buckets if they don't exist.
  /// 
  /// This should be called during app bootstrap (Phase 1.1 Remediation).
  Future<void> initializeBuckets() async {
    final requiredBuckets = [
      kBucketAvatars,
      kBucketPetImages,
      kBucketPostMedia,
      kBucketProductImages,
    ];

    try {
      final buckets = await _supabase.storage.listBuckets();
      final existingIds = buckets.map((b) => b.id).toSet();

      for (final bucketId in requiredBuckets) {
        if (!existingIds.contains(bucketId)) {
          developer.log('Creating missing bucket: $bucketId', name: 'StorageService');
          await _supabase.storage.createBucket(
            bucketId,
            const BucketOptions(public: true),
          );
        }
      }
    } catch (e) {
      // In production, users might not have permission to create buckets.
      // We log but don't crash, as buckets are likely already there.
      developer.log('Bucket initialization skipped: $e', name: 'StorageService');
    }
  }

  /// Uploads binary data to a bucket and returns the public URL.
  /// 
  /// This is the preferred cross-platform upload method.
  Future<String> uploadBinary({
    required Uint8List bytes,
    required String bucket,
    required String path,
    required String contentType,
  }) async {
    try {
      await _supabase.storage.from(bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(
              upsert: true,
              contentType: contentType,
            ),
          );

      return _supabase.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      developer.log('Upload failed for $path in $bucket: $e', name: 'StorageService');
      rethrow;
    }
  }

  /// Deletes a file from a bucket.
  Future<void> deleteFile(String bucket, String path) async {
    try {
      await _supabase.storage.from(bucket).remove([path]);
    } catch (e) {
      developer.log('Delete failed for $path in $bucket: $e', name: 'StorageService');
      // Non-critical: don't rethrow unless necessary
    }
  }
}

/// Constants for bucket names (aligned with supabase_config.dart)
const kBucketAvatars = 'avatars';
const kBucketPetImages = 'pet-images';
const kBucketPostMedia = 'post-media';
const kBucketProductImages = 'product-images';
