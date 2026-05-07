class PetFriendlyPlace {
  final String id;
  final String name;
  final String category;
  final String? imageUrl;
  final double rating;
  final int reviewCount;
  final double distanceMiles;
  final String? status;
  final DateTime createdAt;

  const PetFriendlyPlace({
    required this.id,
    required this.name,
    required this.category,
    this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.distanceMiles,
    this.status,
    required this.createdAt,
  });

  factory PetFriendlyPlace.fromJson(Map<String, dynamic> json) {
    return PetFriendlyPlace(
      id: json['id'] as String,
      name: json['name'] as String,
      category: json['category'] as String,
      imageUrl: json['image_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (json['review_count'] as num?)?.toInt() ?? 0,
      distanceMiles: (json['distance_miles'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
}
