import 'dart:developer';
import 'package:petsphere/core/constants/supabase_config.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Models
// ─────────────────────────────────────────────────────────────────────────────

class AdoptionListing {
  final String id;
  final String shelterName;
  final String petName;
  final String species;
  final String? breed;
  final int? ageMonths;
  final String? gender;
  final String? description;
  final String? imageUrl;
  final double? adoptionFee;
  final bool isAvailable;
  final String? contactEmail;
  final String? contactPhone;
  final String? location;
  final DateTime createdAt;

  const AdoptionListing({
    required this.id,
    required this.shelterName,
    required this.petName,
    required this.species,
    this.breed,
    this.ageMonths,
    this.gender,
    this.description,
    this.imageUrl,
    this.adoptionFee,
    required this.isAvailable,
    this.contactEmail,
    this.contactPhone,
    this.location,
    required this.createdAt,
  });

  String get ageLabel {
    if (ageMonths == null) return 'Age unknown';
    if (ageMonths! < 12) return '${ageMonths}mo';
    final years = ageMonths! ~/ 12;
    final months = ageMonths! % 12;
    return months > 0 ? '${years}y ${months}mo' : '${years}y';
  }

  factory AdoptionListing.fromJson(Map<String, dynamic> json) =>
      AdoptionListing(
        id: json['id'] as String,
        shelterName: json['shelter_name'] as String,
        petName: json['pet_name'] as String,
        species: json['species'] as String? ?? 'dog',
        breed: json['breed'] as String?,
        ageMonths: json['age_months'] as int?,
        gender: json['gender'] as String?,
        description: json['description'] as String?,
        imageUrl: json['image_url'] as String?,
        adoptionFee: (json['adoption_fee'] as num?)?.toDouble(),
        isAvailable: json['is_available'] as bool? ?? true,
        contactEmail: json['contact_email'] as String?,
        contactPhone: json['contact_phone'] as String?,
        location: json['location'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      );
}

class AdoptionApplication {
  final String id;
  final String listingId;
  final String applicantId;
  final String status; // pending|approved|rejected|withdrawn
  final String? message;
  final DateTime createdAt;

  const AdoptionApplication({
    required this.id,
    required this.listingId,
    required this.applicantId,
    required this.status,
    this.message,
    required this.createdAt,
  });

  factory AdoptionApplication.fromJson(Map<String, dynamic> json) =>
      AdoptionApplication(
        id: json['id'] as String,
        listingId: json['listing_id'] as String,
        applicantId: json['applicant_id'] as String,
        status: json['status'] as String? ?? 'pending',
        message: json['message'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Repository
// ─────────────────────────────────────────────────────────────────────────────

class AdoptionRepository {
  final _db = supabase;

  Future<List<AdoptionListing>> fetchListings({String? species}) async {
    final query = _db
        .from('adoption_listings')
        .select()
        .eq('is_available', true)
        .order('created_at', ascending: false)
        .limit(50);
    final rows = await query;
    var listings = (rows as List)
        .map((r) => AdoptionListing.fromJson(r as Map<String, dynamic>))
        .toList();
    if (species != null && species != 'All') {
      listings = listings.where((l) => l.species == species).toList();
    }
    return listings;
  }

  Future<AdoptionApplication> applyForAdoption({
    required String listingId,
    required String message,
  }) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');
    final row = await _db
        .from('adoption_applications')
        .insert({
          'listing_id': listingId,
          'applicant_id': userId,
          'message': message,
        })
        .select()
        .single();
    return AdoptionApplication.fromJson(row);
  }

  /// Check if current user has already applied for [listingId].
  Future<AdoptionApplication?> getMyApplication(String listingId) async {
    final userId = _db.auth.currentUser?.id;
    if (userId == null) return null;
    try {
      final row = await _db
          .from('adoption_applications')
          .select()
          .eq('listing_id', listingId)
          .eq('applicant_id', userId)
          .maybeSingle();
      return row == null ? null : AdoptionApplication.fromJson(row);
    } catch (e) {
      log('getMyApplication error: $e', name: 'AdoptionRepository');
      return null;
    }
  }

  Future<void> withdrawApplication(String applicationId) async {
    await _db
        .from('adoption_applications')
        .update({'status': 'withdrawn'})
        .eq('id', applicationId);
  }
}

final adoptionRepository = AdoptionRepository();
