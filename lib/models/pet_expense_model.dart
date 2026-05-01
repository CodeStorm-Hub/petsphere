import 'package:flutter/material.dart';

enum ExpenseCategory {
  food,
  health,
  toys,
  grooming,
  insurance,
  training,
  other;

  String get label {
    switch (this) {
      case ExpenseCategory.food:
        return 'Food';
      case ExpenseCategory.health:
        return 'Health';
      case ExpenseCategory.toys:
        return 'Toys';
      case ExpenseCategory.grooming:
        return 'Grooming';
      case ExpenseCategory.insurance:
        return 'Insurance';
      case ExpenseCategory.training:
        return 'Training';
      case ExpenseCategory.other:
        return 'Other';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.food:
        return Icons.restaurant_rounded;
      case ExpenseCategory.health:
        return Icons.medical_services_rounded;
      case ExpenseCategory.toys:
        return Icons.toys_rounded;
      case ExpenseCategory.grooming:
        return Icons.content_cut_rounded;
      case ExpenseCategory.insurance:
        return Icons.shield_rounded;
      case ExpenseCategory.training:
        return Icons.fitness_center_rounded;
      case ExpenseCategory.other:
        return Icons.more_horiz_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.food:
        return Colors.orange;
      case ExpenseCategory.health:
        return Colors.redAccent;
      case ExpenseCategory.toys:
        return Colors.purpleAccent;
      case ExpenseCategory.grooming:
        return Colors.blueAccent;
      case ExpenseCategory.insurance:
        return Colors.teal;
      case ExpenseCategory.training:
        return Colors.indigo;
      case ExpenseCategory.other:
        return Colors.grey;
    }
  }
}

class PetExpense {
  final String id;
  final String petId;
  final String title;
  final double amount;
  final DateTime date;
  final ExpenseCategory category;
  final String? notes;

  const PetExpense({
    required this.id,
    required this.petId,
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
    this.notes,
  });

  factory PetExpense.fromJson(Map<String, dynamic> json) {
    return PetExpense(
      id: json['id'] as String,
      petId: json['pet_id'] as String,
      title: json['title'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      category: ExpenseCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => ExpenseCategory.other,
      ),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'pet_id': petId,
        'title': title,
        'amount': amount,
        'date': date.toIso8601String(),
        'category': category.name,
        'notes': notes,
      };

  PetExpense copyWith({
    String? id,
    String? petId,
    String? title,
    double? amount,
    DateTime? date,
    ExpenseCategory? category,
    String? notes,
  }) {
    return PetExpense(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }
}
