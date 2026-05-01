import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/pet_expense_model.dart';
import '../models/pet_model.dart';
import '../repositories/pet_expense_repository.dart';
import 'pet_controller.dart';

class PetExpenseState {
  final List<PetExpense> expenses;
  final bool isLoading;
  final String? error;

  PetExpenseState({
    this.expenses = const [],
    this.isLoading = false,
    this.error,
  });

  PetExpenseState copyWith({
    List<PetExpense>? expenses,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return PetExpenseState(
      expenses: expenses ?? this.expenses,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  double get totalSpent => expenses.fold(0.0, (sum, e) => sum + e.amount);
}

class PetExpenseNotifier extends Notifier<PetExpenseState> {
  @override
  PetExpenseState build() {
    ref.listen<PetModel?>(activePetProvider, (prev, next) {
      if (next != null && prev?.id != next.id) {
        loadExpenses(next.id);
      }
    });

    final activePet = ref.read(activePetProvider);
    if (activePet != null) {
      Future.microtask(() => loadExpenses(activePet.id));
    }

    return PetExpenseState(isLoading: true);
  }

  Future<void> loadExpenses(String petId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final expenses = await ref.read(petExpenseRepositoryProvider).fetchExpenses(petId);
      state = state.copyWith(expenses: expenses, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addExpense({
    required String title,
    required double amount,
    required DateTime date,
    required ExpenseCategory category,
    String? notes,
  }) async {
    final activePet = ref.read(activePetProvider);
    if (activePet == null) return;

    final newExpense = PetExpense(
      id: '',
      petId: activePet.id,
      title: title,
      amount: amount,
      date: date,
      category: category,
      notes: notes,
    );

    try {
      final created = await ref.read(petExpenseRepositoryProvider).createExpense(newExpense);
      state = state.copyWith(expenses: [created, ...state.expenses]);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await ref.read(petExpenseRepositoryProvider).deleteExpense(id);
      state = state.copyWith(
        expenses: state.expenses.where((e) => e.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final petExpenseProvider =
    NotifierProvider<PetExpenseNotifier, PetExpenseState>(() {
  return PetExpenseNotifier();
});
