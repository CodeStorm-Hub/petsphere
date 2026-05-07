import 'dart:developer';
import '../models/pet_friendly_place_model.dart';
import '../models/knowledge_base_models.dart';
import '../models/gear_review_models.dart';
import '../models/pet_memorial_models.dart';
import '../utils/supabase_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Training Repository — #50
// ─────────────────────────────────────────────────────────────────────────────

class TrainingProgress {
  final String id;
  final String petId;
  final String? programId;
  final String command;
  final bool mastered;
  final String? notes;
  final DateTime loggedAt;

  const TrainingProgress({
    required this.id,
    required this.petId,
    this.programId,
    required this.command,
    required this.mastered,
    this.notes,
    required this.loggedAt,
  });

  factory TrainingProgress.fromJson(Map<String, dynamic> json) =>
      TrainingProgress(
        id: json['id'] as String,
        petId: json['pet_id'] as String,
        programId: json['program_id'] as String?,
        command: json['command'] as String,
        mastered: json['mastered'] as bool? ?? false,
        notes: json['notes'] as String?,
        loggedAt: DateTime.parse(json['logged_at'] as String).toLocal(),
      );
}

class TrainingRepository {
  final _db = supabase;

  Future<List<TrainingProgress>> fetchProgress(String petId) async {
    final rows = await _db
        .from('pet_training_progress')
        .select()
        .eq('pet_id', petId)
        .order('logged_at', ascending: false);
    return (rows as List)
        .map((e) => TrainingProgress.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> logCommand({
    required String petId,
    required String command,
    required bool mastered,
    String? notes,
    String? programId,
  }) async {
    await _db.from('pet_training_progress').upsert(
      {
        'pet_id': petId,
        'program_id': programId,
        'command': command,
        'mastered': mastered,
        'notes': notes,
        'logged_at': DateTime.now().toUtc().toIso8601String(),
      },
      onConflict: 'pet_id,program_id,command',
    );
    log('Logged command: $command (mastered: $mastered)', name: 'TrainingRepository');
  }

  Future<void> deleteProgress(String petId, String command) async {
    await _db
        .from('pet_training_progress')
        .delete()
        .eq('pet_id', petId)
        .eq('command', command);
  }

  /// Returns count and mastered count for a category (program label).
  Map<String, int> progressForCategory(
      List<TrainingProgress> all, List<String> commands) {
    final relevant = all.where((p) => commands.contains(p.command)).toList();
    return {
      'total': commands.length,
      'mastered': relevant.where((p) => p.mastered).length,
    };
  }
}

final trainingRepository = TrainingRepository();

// ─────────────────────────────────────────────────────────────────────────────
// Nutrition Repository — #63
// ─────────────────────────────────────────────────────────────────────────────

class NutritionLog {
  final String id;
  final String petId;
  final String mealName;
  final String mealType;
  final int? calories;
  final int? proteinPct;
  final int? fatPct;
  final int? carbPct;
  final int? waterMl;
  final DateTime loggedAt;

  const NutritionLog({
    required this.id,
    required this.petId,
    required this.mealName,
    required this.mealType,
    this.calories,
    this.proteinPct,
    this.fatPct,
    this.carbPct,
    this.waterMl,
    required this.loggedAt,
  });

  factory NutritionLog.fromJson(Map<String, dynamic> json) => NutritionLog(
        id: json['id'] as String,
        petId: json['pet_id'] as String,
        mealName: json['meal_name'] as String,
        mealType: json['meal_type'] as String? ?? 'kibble',
        calories: json['calories'] as int?,
        proteinPct: json['protein_pct'] as int?,
        fatPct: json['fat_pct'] as int?,
        carbPct: json['carb_pct'] as int?,
        waterMl: json['water_ml'] as int?,
        loggedAt: DateTime.parse(json['logged_at'] as String).toLocal(),
      );
}

class NutritionRepository {
  final _db = supabase;

  Future<List<NutritionLog>> fetchTodayLogs(String petId) async {
    final start = DateTime.now().toUtc().copyWith(
        hour: 0, minute: 0, second: 0, millisecond: 0);
    final rows = await _db
        .from('pet_nutrition_logs')
        .select()
        .eq('pet_id', petId)
        .gte('logged_at', start.toIso8601String())
        .order('logged_at');
    return (rows as List)
        .map((e) => NutritionLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<NutritionLog> addLog(NutritionLog log) async {
    final row = await _db.from('pet_nutrition_logs').insert({
      'pet_id': log.petId,
      'meal_name': log.mealName,
      'meal_type': log.mealType,
      if (log.calories != null) 'calories': log.calories,
      if (log.proteinPct != null) 'protein_pct': log.proteinPct,
      if (log.fatPct != null) 'fat_pct': log.fatPct,
      if (log.carbPct != null) 'carb_pct': log.carbPct,
      if (log.waterMl != null) 'water_ml': log.waterMl,
    }).select().single();
    return NutritionLog.fromJson(row);
  }

  Future<void> deleteLog(String id) async {
    await _db.from('pet_nutrition_logs').delete().eq('id', id);
  }
}

final nutritionRepository = NutritionRepository();

// ─────────────────────────────────────────────────────────────────────────────
// Insurance Claims Repository — #52
// ─────────────────────────────────────────────────────────────────────────────

class InsuranceClaim {
  final String id;
  final String petId;
  final String userId;
  final String title;
  final double amount;
  final DateTime incurredAt;
  final String status;
  final String? notes;
  final DateTime createdAt;

  const InsuranceClaim({
    required this.id,
    required this.petId,
    required this.userId,
    required this.title,
    required this.amount,
    required this.incurredAt,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory InsuranceClaim.fromJson(Map<String, dynamic> json) => InsuranceClaim(
        id: json['id'] as String,
        petId: json['pet_id'] as String,
        userId: json['user_id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        incurredAt: DateTime.parse(json['incurred_at'] as String).toLocal(),
        status: json['status'] as String? ?? 'pending',
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'pet_id': petId,
        'user_id': userId,
        'title': title,
        'amount': amount,
        'incurred_at': incurredAt.toUtc().toIso8601String(),
        'status': status,
        if (notes != null) 'notes': notes,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
}

class InsuranceClaimsRepository {
  final _db = supabase;

  Future<List<InsuranceClaim>> fetchClaims(String petId) async {
    final rows = await _db
        .from('pet_insurance_claims')
        .select()
        .eq('pet_id', petId)
        .order('created_at', ascending: false);
    return (rows as List)
        .map((e) => InsuranceClaim.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<InsuranceClaim> fileClaim({
    required String petId,
    required String userId,
    required String title,
    required double amount,
    required DateTime incurredAt,
    String? notes,
  }) async {
    final row = await _db.from('pet_insurance_claims').insert({
      'pet_id': petId,
      'user_id': userId,
      'title': title,
      'amount': amount,
      'incurred_at': incurredAt.toIso8601String().split('T')[0],
      'notes': notes,
    }).select().single();
    return InsuranceClaim.fromJson(row);
  }
}

final insuranceClaimsRepository = InsuranceClaimsRepository();

// ─────────────────────────────────────────────────────────────────────────────
// Sitter Jobs Repository — #51
// ─────────────────────────────────────────────────────────────────────────────

class SitterJob {
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
        .order('start_date');
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
    final row = await _db.from('pet_sitter_jobs').insert({
      'pet_owner_id': petOwnerId,
      'pet_id': petId,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'description': description,
      'rate_per_day': ratePerDay,
    }).select().single();
    return SitterJob.fromJson(row);
  }
}

final sitterJobsRepository = SitterJobsRepository();

// ──────────────────────────────────────────────────────────────────────────
// Pet Friendly Places Repository
// ──────────────────────────────────────────────────────────────────────────
class PetFriendlyPlacesRepository {
  Future<List<PetFriendlyPlace>> fetchPetFriendlyPlaces(String category) async {
    final response = await supabase
        .from('pet_friendly_places')
        .select()
        .eq('category', category)
        .order('distance_miles');
        
    return (response as List)
        .cast<Map<String, dynamic>>()
        .map(PetFriendlyPlace.fromJson)
        .toList();
  }
}

final petFriendlyPlacesRepository = PetFriendlyPlacesRepository();

// ─────────────────────────────────────────────────────────────────────────────
// Knowledge Base Repository — #64
// ─────────────────────────────────────────────────────────────────────────────

class KnowledgeBaseRepository {
  final _db = supabase;

  Future<List<KnowledgeArticle>> fetchArticles({String? category, String? query}) async {
    var request = _db.from('knowledge_base_articles').select();
    
    if (category != null && category != 'All Topics') {
      request = request.eq('category', category);
    }
    
    if (query != null && query.isNotEmpty) {
      request = request.ilike('title', '%$query%');
    }
    
    final rows = await request.order('created_at', ascending: false);
    return (rows as List).map((e) => KnowledgeArticle.fromJson(e)).toList();
  }

  Future<List<KnowledgeArticle>> fetchFeaturedArticles() async {
    final rows = await _db
        .from('knowledge_base_articles')
        .select()
        .eq('is_featured', true)
        .limit(5);
    return (rows as List).map((e) => KnowledgeArticle.fromJson(e)).toList();
  }
}

final knowledgeBaseRepository = KnowledgeBaseRepository();

// ─────────────────────────────────────────────────────────────────────────────
// Gear Reviews Repository — #65
// ─────────────────────────────────────────────────────────────────────────────

class GearReviewsRepository {
  final _db = supabase;

  Future<List<GearReview>> fetchReviews({String? category}) async {
    var request = _db.from('gear_reviews').select();
    if (category != null && category != 'All') {
      request = request.eq('category', category);
    }
    final rows = await request.order('created_at', ascending: false);
    return (rows as List).map((e) => GearReview.fromJson(e)).toList();
  }

  Future<GearReview> submitReview(GearReview review) async {
    final row = await _db.from('gear_reviews').insert(review.toJson()).select().single();
    return GearReview.fromJson(row);
  }
}

final gearReviewsRepository = GearReviewsRepository();

// ─────────────────────────────────────────────────────────────────────────────
// Pet Memorial Repository — #67
// ─────────────────────────────────────────────────────────────────────────────

class PetMemorialRepository {
  final _db = supabase;

  Future<List<PetMemorialEntry>> fetchMemorials() async {
    final rows = await _db
        .from('pet_memorial_entries')
        .select()
        .order('created_at', ascending: false);
    return (rows as List).map((e) => PetMemorialEntry.fromJson(e)).toList();
  }

  Future<PetMemorialEntry?> getMemorialEntryById(String id) async {
    final response = await _db
        .from('pet_memorial_entries')
        .select('*')
        .eq('id', id)
        .single();
    return PetMemorialEntry.fromJson(response);
  }

  Future<PetMemorialEntry> createMemorial(PetMemorialEntry entry) async {
    final row = await _db.from('pet_memorial_entries').insert(entry.toJson()).select().single();
    return PetMemorialEntry.fromJson(row);
  }
}

final petMemorialRepository = PetMemorialRepository();

// ─────────────────────────────────────────────────────────────────────────────
// Breed Identifier Repository — #66
// ─────────────────────────────────────────────────────────────────────────────

class BreedScan {
  final String id;
  final String breedName;
  final double confidence;
  final String? imageUrl;
  final String? description;
  final Map<String, String>? characteristics;
  final DateTime scannedAt;

  const BreedScan({
    required this.id,
    required this.breedName,
    required this.confidence,
    this.imageUrl,
    this.description,
    this.characteristics,
    required this.scannedAt,
  });

  factory BreedScan.fromJson(Map<String, dynamic> json) => BreedScan(
        id: json['id'] as String,
        breedName: json['breed_name'] as String,
        confidence: (json['confidence'] as num).toDouble(),
        imageUrl: json['image_url'] as String?,
        description: json['description'] as String?,
        characteristics: (json['characteristics'] as Map?)?.cast<String, String>(),
        scannedAt: DateTime.parse(json['scanned_at'] as String).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'breed_name': breedName,
        'confidence': confidence,
        'image_url': imageUrl,
        'description': description,
        'characteristics': characteristics,
        'scanned_at': scannedAt.toUtc().toIso8601String(),
      };
}

class BreedIdentifierRepository {
  final _db = supabase;

  Future<List<BreedScan>> fetchScanHistory() async {
    final rows = await _db
        .from('pet_breed_scans')
        .select()
        .order('scanned_at', ascending: false)
        .limit(10);
    return (rows as List).map((e) => BreedScan.fromJson(e)).toList();
  }

  Future<BreedScan> saveScan(BreedScan scan) async {
    final row = await _db.from('pet_breed_scans').insert(scan.toJson()).select().single();
    return BreedScan.fromJson(row);
  }

  // Mock AI detection for now
  Future<BreedScan> identifyBreed(String imagePath) async {
    // Simulate AI processing
    await Future.delayed(const Duration(seconds: 3));
    
    return BreedScan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      breedName: 'Golden Retriever',
      confidence: 0.98,
      imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d',
      description: 'The Golden Retriever is a sturdy, muscular dog of medium size, famous for the dense, lustrous coat of gold that gives the breed its name.',
      characteristics: {
        'Lifespan': '10-12 yrs',
        'Weight': '55-75 lbs',
        'Group': 'Sporting',
      },
      scannedAt: DateTime.now(),
    );
  }
}

final breedIdentifierRepository = BreedIdentifierRepository();
