import 'dart:developer';
import '../utils/supabase_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Model
// ─────────────────────────────────────────────────────────────────────────────

class LostFoundReport {
  final String id;
  final String reporterId;
  final String? petId;
  final String status; // lost | found | reunited
  final String petName;
  final String petType;
  final String? breed;
  final String? description;
  final DateTime? lastSeenAt;
  final String? lastSeenLocation;
  final String? contactInfo;
  final double? rewardAmount;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;

  const LostFoundReport({
    required this.id,
    required this.reporterId,
    this.petId,
    required this.status,
    required this.petName,
    required this.petType,
    this.breed,
    this.description,
    this.lastSeenAt,
    this.lastSeenLocation,
    this.contactInfo,
    this.rewardAmount,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
  });

  bool get hasReward => rewardAmount != null && rewardAmount! > 0;

  factory LostFoundReport.fromJson(Map<String, dynamic> json) {
    return LostFoundReport(
      id: json['id'] as String,
      reporterId: json['reporter_id'] as String,
      petId: json['pet_id'] as String?,
      status: json['status'] as String? ?? 'lost',
      petName: json['pet_name'] as String,
      petType: json['pet_type'] as String? ?? 'dog',
      breed: json['breed'] as String?,
      description: json['description'] as String?,
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.parse(json['last_seen_at'] as String).toLocal()
          : null,
      lastSeenLocation: json['last_seen_location'] as String?,
      contactInfo: json['contact_info'] as String?,
      rewardAmount: (json['reward_amount'] as num?)?.toDouble(),
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
    );
  }

  Map<String, dynamic> toInsertJson() => {
        'reporter_id': reporterId,
        if (petId != null) 'pet_id': petId,
        'status': status,
        'pet_name': petName,
        'pet_type': petType,
        if (breed != null) 'breed': breed,
        if (description != null) 'description': description,
        if (lastSeenAt != null) 'last_seen_at': lastSeenAt!.toUtc().toIso8601String(),
        if (lastSeenLocation != null) 'last_seen_location': lastSeenLocation,
        if (contactInfo != null) 'contact_info': contactInfo,
        if (rewardAmount != null) 'reward_amount': rewardAmount,
        if (imageUrl != null) 'image_url': imageUrl,
        'is_active': isActive,
      };
}

// ─────────────────────────────────────────────────────────────────────────────
// Repository
// ─────────────────────────────────────────────────────────────────────────────

class LostFoundRepository {
  final _db = supabase;

  Future<List<LostFoundReport>> fetchReports({String? status}) async {
    var query = _db
        .from('lost_and_found_reports')
        .select()
        .eq('is_active', true)
        .order('created_at', ascending: false)
        .limit(50);
    if (status != null) {
      // Filter after fetch (PostgREST string filter)
    }
    final rows = await query;
    var reports =
        (rows as List).map((r) => LostFoundReport.fromJson(r)).toList();
    if (status != null) {
      reports = reports.where((r) => r.status == status).toList();
    }
    return reports;
  }

  Future<LostFoundReport> createReport(LostFoundReport report) async {
    final row = await _db
        .from('lost_and_found_reports')
        .insert(report.toInsertJson())
        .select()
        .single();
    return LostFoundReport.fromJson(row);
  }

  Future<void> markReunited(String id) async {
    await _db
        .from('lost_and_found_reports')
        .update({'status': 'reunited', 'is_active': false}).eq('id', id);
  }

  Future<void> deleteReport(String id) async {
    try {
      await _db.from('lost_and_found_reports').delete().eq('id', id);
    } catch (e) {
      log('deleteReport error: $e', name: 'LostFoundRepository');
    }
  }
}

final lostFoundRepository = LostFoundRepository();
