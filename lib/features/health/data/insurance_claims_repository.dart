import 'package:petsphere/core/constants/supabase_config.dart';

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
    final row = await _db
        .from('pet_insurance_claims')
        .insert({
          'pet_id': petId,
          'user_id': userId,
          'title': title,
          'amount': amount,
          'incurred_at': incurredAt.toIso8601String().split('T')[0],
          'notes': notes,
        })
        .select()
        .single();
    return InsuranceClaim.fromJson(row);
  }
}

final insuranceClaimsRepository = InsuranceClaimsRepository();
