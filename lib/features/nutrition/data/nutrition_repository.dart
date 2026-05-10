import 'package:petfolio/core/constants/supabase_config.dart';

class NutritionLog {

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
}

class NutritionRepository {
  final _db = supabase;

  Future<List<NutritionLog>> fetchTodayLogs(String petId) async {
    final start = DateTime.now().toUtc().copyWith(
      hour: 0,
      minute: 0,
      second: 0,
      millisecond: 0,
    );
    final rows = await _db
        .from('pet_nutrition_logs')
        .select()
        .eq('pet_id', petId)
        .gte('logged_at', start.toIso8601String())
        .order('logged_at')
        .limit(50);
    return (rows as List)
        .map((e) => NutritionLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<NutritionLog> addLog(NutritionLog log) async {
    final row = await _db
        .from('pet_nutrition_logs')
        .insert({
          'pet_id': log.petId,
          'meal_name': log.mealName,
          'meal_type': log.mealType,
          if (log.calories != null) 'calories': log.calories,
          if (log.proteinPct != null) 'protein_pct': log.proteinPct,
          if (log.fatPct != null) 'fat_pct': log.fatPct,
          if (log.carbPct != null) 'carb_pct': log.carbPct,
          if (log.waterMl != null) 'water_ml': log.waterMl,
        })
        .select()
        .single();
    return NutritionLog.fromJson(row);
  }

  Future<void> deleteLog(String id) async {
    await _db.from('pet_nutrition_logs').delete().eq('id', id);
  }
}

final nutritionRepository = NutritionRepository();
