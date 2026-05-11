import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:petfolio/core/constants/app_durations.dart';
import 'package:petfolio/core/constants/supabase_config.dart'
    show
        kBucketAvatars,
        kBucketPetImages,
        kBucketPostMedia,
        kBucketProductImages;
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  StorageService(this._supabase);
  final SupabaseClient _supabase;

  Future<void> initializeBuckets() async {
    const requiredBuckets = [
      kBucketAvatars,
      kBucketPetImages,
      kBucketPostMedia,
      kBucketProductImages,
    ];

    try {
      final buckets = await _supabase.storage.listBuckets().timeout(
        AppDurations.realtimeSubscriptionTimeout,
      );
      final existingIds = buckets.map((b) => b.id).toSet();
      final missing = requiredBuckets
          .where((bucketId) => !existingIds.contains(bucketId))
          .toList(growable: false);

      if (missing.isNotEmpty) {
        developer.log(
          'Missing storage buckets: ${missing.join(', ')}',
          name: 'StorageService',
        );
      }
    } on TimeoutException catch (e) {
      developer.log(
        'Bucket verification timed out: $e',
        name: 'StorageService',
      );
    } catch (e) {
      developer.log('Bucket verification skipped: $e', name: 'StorageService');
    }
  }

  Future<String> uploadBinary({
    required Uint8List bytes,
    required String bucket,
    required String path,
    required String contentType,
  }) async {
    try {
      await _supabase.storage
          .from(bucket)
          .uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(upsert: true, contentType: contentType),
          )
          .timeout(AppDurations.imageUploadTimeout);

      return _supabase.storage.from(bucket).getPublicUrl(path);
    } catch (e) {
      developer.log(
        'Upload failed for $path in $bucket: $e',
        name: 'StorageService',
      );
      rethrow;
    }
  }

  Future<void> deleteFile(String bucket, String path) async {
    try {
      await _supabase.storage
          .from(bucket)
          .remove([path])
          .timeout(AppDurations.defaultNetworkTimeout);
    } catch (e) {
      developer.log(
        'Delete failed for $path in $bucket: $e',
        name: 'StorageService',
      );
    }
  }
}
