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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'image_url': imageUrl,
      'rating': rating,
      'review_count': reviewCount,
      'distance_miles': distanceMiles,
      'status': status,
      'created_at': createdAt.toUtc().toIso8601String(),
    };
  }

  PetFriendlyPlace copyWith({
    String? id,
    String? name,
    String? category,
    String? imageUrl,
    double? rating,
    int? reviewCount,
    double? distanceMiles,
    String? status,
    DateTime? createdAt,
  }) {
    return PetFriendlyPlace(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      distanceMiles: distanceMiles ?? this.distanceMiles,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetFriendlyPlace &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          category == other.category &&
          imageUrl == other.imageUrl &&
          rating == other.rating &&
          reviewCount == other.reviewCount &&
          distanceMiles == other.distanceMiles &&
          status == other.status &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      category.hashCode ^
      imageUrl.hashCode ^
      rating.hashCode ^
      reviewCount.hashCode ^
      distanceMiles.hashCode ^
      status.hashCode ^
      createdAt.hashCode;
}
