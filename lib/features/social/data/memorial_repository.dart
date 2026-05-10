import 'package:petsphere/core/constants/supabase_config.dart';
import 'package:petsphere/features/social/data/models/pet_memorial_models.dart';

class PetMemorialRepository {
  final _db = supabase;

  Future<List<PetMemorialEntry>> fetchMemorials() async {
    final rows = await _db
        .from('pet_memorial_entries')
        .select()
        .order('created_at', ascending: false)
        .limit(50);
    return rows
        .map((e) => PetMemorialEntry.fromJson(e))
        .toList();
  }

  Future<PetMemorialEntry?> getMemorialEntryById(String id) async {
    final response = await _db
        .from('pet_memorial_entries')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return PetMemorialEntry.fromJson(response);
  }

  Future<PetMemorialEntry> createMemorial(PetMemorialEntry entry) async {
    final row = await _db
        .from('pet_memorial_entries')
        .insert(entry.toJson())
        .select()
        .single();
    return PetMemorialEntry.fromJson(row);
  }
}

final petMemorialRepository = PetMemorialRepository();
