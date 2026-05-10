import 'package:petfolio/core/constants/supabase_config.dart';

class BreedScan {

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
  final String id;
  final String breedName;
  final double confidence;
  final String? imageUrl;
  final String? description;
  final Map<String, String>? characteristics;
  final DateTime scannedAt;

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
    return (rows as List)
        .map((e) => BreedScan.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BreedScan> saveScan(BreedScan scan) async {
    final json = scan.toJson()..remove('id');
    final row = await _db
        .from('pet_breed_scans')
        .insert(json)
        .select()
        .single();
    return BreedScan.fromJson(row);
  }

  // Mock AI detection for now
  Future<BreedScan> identifyBreed(String imagePath) async {
    // Simulate AI processing
    await Future<void>.delayed(const Duration(seconds: 3));

    return BreedScan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      breedName: 'Golden Retriever',
      confidence: 0.98,
      imageUrl: 'https://images.unsplash.com/photo-1552053831-71594a27632d',
      description:
          'The Golden Retriever is a sturdy, muscular dog of medium size, famous for the dense, lustrous coat of gold that gives the breed its name.',
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
