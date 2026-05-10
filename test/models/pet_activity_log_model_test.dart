import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/care/data/models/pet_activity_log_model.dart';

void main() {
  group('PetActivityLog', () {
    final testDate = DateTime(2026, 5, 10);
    final testLog = PetActivityLog(
      id: 'log123',
      petId: 'pet456',
      logDate: testDate,
      activityType: 'walk',
      durationMinutes: 30,
      notes: 'Good walk',
    );

    test('creates instance with required parameters', () {
      expect(testLog.id, 'log123');
      expect(testLog.petId, 'pet456');
      expect(testLog.logDate, testDate);
      expect(testLog.activityType, 'walk');
      expect(testLog.durationMinutes, 30);
      expect(testLog.intensity, 'moderate');
      expect(testLog.notes, 'Good walk');
    });

    test('typeLabel returns correct labels', () {
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'walk').typeLabel, 'Walk');
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'run').typeLabel, 'Run');
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'play').typeLabel, 'Play');
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'swim').typeLabel, 'Swim');
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'training').typeLabel, 'Training');
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'grooming').typeLabel, 'Grooming');
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'social').typeLabel, 'Social Time');
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'free_roam').typeLabel, 'Free Roam');
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'unknown').typeLabel, 'Other');
    });

    test('icon returns correct icons', () {
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'walk').icon, Icons.directions_walk);
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'run').icon, Icons.directions_run);
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'play').icon, Icons.sports_tennis);
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'swim').icon, Icons.pool);
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'training').icon, Icons.school);
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'grooming').icon, Icons.content_cut);
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'social').icon, Icons.people);
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'free_roam').icon, Icons.holiday_village_outlined);
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'unknown').icon, Icons.fitness_center);
    });

    test('intensityColor returns correct colors', () {
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'walk', intensity: 'low').intensityColor, const Color(0xFF5BA3F5));
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'walk', intensity: 'high').intensityColor, const Color(0xFFFFA726));
      expect(PetActivityLog(petId: '1', logDate: testDate, activityType: 'walk').intensityColor, const Color(0xFF2979FF));
    });

    test('parses from JSON correctly', () {
      final json = {
        'id': 'log123',
        'pet_id': 'pet456',
        'log_date': '2026-05-10T00:00:00.000',
        'activity_type': 'walk',
        'duration_minutes': 30,
        'intensity': 'moderate',
        'notes': 'Good walk',
      };
      final parsed = PetActivityLog.fromJson(json);
      expect(parsed, testLog);
    });

    test('converts to JSON correctly', () {
      final json = testLog.toJson();
      expect(json['pet_id'], 'pet456');
      expect(json['log_date'], '2026-05-10');
      expect(json['activity_type'], 'walk');
      expect(json['duration_minutes'], 30);
      expect(json['intensity'], 'moderate');
      expect(json['notes'], 'Good walk');
    });

    test('copyWith creates new instance with updated fields', () {
      final updated = testLog.copyWith(notes: 'Updated note');
      expect(updated.notes, 'Updated note');
      expect(updated.id, testLog.id);
      expect(updated.petId, testLog.petId);
    });

    test('typesForSpecies returns correct lists', () {
      expect(PetActivityLog.typesForSpecies('dog'), contains('walk'));
      expect(PetActivityLog.typesForSpecies('cat'), contains('play'));
      expect(PetActivityLog.typesForSpecies('bird'), contains('free_roam'));
      expect(PetActivityLog.typesForSpecies('rabbit'), contains('free_roam'));
      expect(PetActivityLog.typesForSpecies('other'), contains('walk'));
    });

    test('equality and hashCode', () {
      final log2 = testLog.copyWith();
      expect(testLog, log2);
      expect(testLog.hashCode, log2.hashCode);
      
      final different = testLog.copyWith(id: 'different');
      expect(testLog == different, false);
      expect(testLog.hashCode == different.hashCode, false);
    });
  });
}
