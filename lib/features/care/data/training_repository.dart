import 'dart:developer';
import 'package:petfolio/core/constants/supabase_config.dart';

class TrainingProgress {

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
  final String id;
  final String petId;
  final String? programId;
  final String command;
  final bool mastered;
  final String? notes;
  final DateTime loggedAt;
}

class TrainingRepository {
  final _db = supabase;

  Future<List<TrainingProgress>> fetchProgress(String petId) async {
    final rows = await _db
        .from('pet_training_progress')
        .select()
        .eq('pet_id', petId)
        .order('logged_at', ascending: false)
        .limit(100);
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
    await _db.from('pet_training_progress').upsert({
      'pet_id': petId,
      'program_id': programId,
      'command': command,
      'mastered': mastered,
      'notes': notes,
      'logged_at': DateTime.now().toUtc().toIso8601String(),
    }, onConflict: 'pet_id,program_id,command');
    log(
      'Logged command: $command (mastered: $mastered)',
      name: 'TrainingRepository',
    );
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
    List<TrainingProgress> all,
    List<String> commands,
  ) {
    final relevant = all.where((p) => commands.contains(p.command)).toList();
    return {
      'total': commands.length,
      'mastered': relevant.where((p) => p.mastered).length,
    };
  }
}

final trainingRepository = TrainingRepository();
