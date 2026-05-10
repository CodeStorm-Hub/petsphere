import 'package:petfolio/core/constants/supabase_config.dart';

class SitterJob {

  const SitterJob({
    required this.id,
    required this.petOwnerId,
    this.sitterId,
    this.petId,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.description,
    this.ratePerDay,
    required this.createdAt,
  });

  factory SitterJob.fromJson(Map<String, dynamic> json) => SitterJob(
    id: json['id'] as String,
    petOwnerId: json['pet_owner_id'] as String,
    sitterId: json['sitter_id'] as String?,
    petId: json['pet_id'] as String?,
    startDate: DateTime.parse(json['start_date'] as String),
    endDate: DateTime.parse(json['end_date'] as String),
    status: json['status'] as String? ?? 'open',
    description: json['description'] as String?,
    ratePerDay: (json['rate_per_day'] as num?)?.toDouble(),
    createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
  );
  final String id;
  final String petOwnerId;
  final String? sitterId;
  final String? petId;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String? description;
  final double? ratePerDay;
  final DateTime createdAt;
}

class SitterJobsRepository {
  final _db = supabase;

  Future<List<SitterJob>> fetchMyJobs() async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return [];
    final rows = await _db
        .from('pet_sitter_jobs')
        .select()
        .eq('pet_owner_id', userId)
        .order('start_date')
        .limit(50);
    return (rows as List)
        .map((e) => SitterJob.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<SitterJob>> fetchOpenJobs() async {
    final rows = await _db
        .from('pet_sitter_jobs')
        .select()
        .eq('status', 'open')
        .order('created_at', ascending: false)
        .limit(20);
    return (rows as List)
        .map((e) => SitterJob.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SitterJob> postJob({
    required String petOwnerId,
    required String? petId,
    required DateTime startDate,
    required DateTime endDate,
    String? description,
    double? ratePerDay,
  }) async {
    final row = await _db
        .from('pet_sitter_jobs')
        .insert({
          'pet_owner_id': petOwnerId,
          'pet_id': petId,
          'start_date': startDate.toIso8601String().split('T')[0],
          'end_date': endDate.toIso8601String().split('T')[0],
          'description': description,
          'rate_per_day': ratePerDay,
        })
        .select()
        .single();
    return SitterJob.fromJson(row);
  }
}

final sitterJobsRepository = SitterJobsRepository();
