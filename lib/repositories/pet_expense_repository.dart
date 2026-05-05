import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_expense_model.dart';
import '../utils/supabase_config.dart';

class PetExpenseRepository {
  Future<List<PetExpense>> fetchExpenses(String petId) async {
    final data = await supabase
        .from('pet_expenses')
        .select()
        .eq('pet_id', petId)
        .order('date', ascending: false);

    return (data as List<dynamic>)
        .map((e) => PetExpense.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PetExpense> createExpense(PetExpense expense) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final json = expense.toJson();
    json['user_id'] = user.id;

    final data = await supabase
        .from('pet_expenses')
        .insert(json)
        .select()
        .single();

    return PetExpense.fromJson(data);
  }

  Future<void> deleteExpense(String expenseId) async {
    await supabase.from('pet_expenses').delete().eq('id', expenseId);
  }
}

final petExpenseRepositoryProvider = Provider((ref) => PetExpenseRepository());

final petExpenseRepository = PetExpenseRepository(); // Keep for legacy if needed, but prefer provider
