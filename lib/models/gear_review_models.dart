import 'package:flutter/foundation.dart';

@immutable
class GearReview {
  final String id;
  final String userId;
  final String productName;
  final String brand;
  final String category;
  final double rating;
  final int reviewCount;
  final String price;
  final String? reviewText;
  final List<String>? pros;
  final List<String>? cons;
  final String? imageUrl;
  final bool isVerifiedPurchase;
  final bool isEditorChoice;
  final DateTime createdAt;

  const GearReview({
    required this.id,
    required this.userId,
    required this.productName,
    required this.brand,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.price,
    this.reviewText,
    this.pros,
    this.cons,
    this.imageUrl,
    this.isVerifiedPurchase = false,
    this.isEditorChoice = false,
    required this.createdAt,
  });

  factory GearReview.fromJson(Map<String, dynamic> json) => GearReview(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        productName: json['product_name'] as String,
        brand: json['brand'] as String? ?? 'Generic',
        category: json['category'] as String,
        rating: (json['rating'] as num).toDouble(),
        reviewCount: json['review_count'] as int? ?? 0,
        price: json['price'] as String? ?? 'TBD',
        reviewText: json['review_text'] as String?,
        pros: (json['pros'] as List?)?.cast<String>(),
        cons: (json['cons'] as List?)?.cast<String>(),
        imageUrl: json['image_url'] as String?,
        isVerifiedPurchase: json['is_verified_purchase'] as bool? ?? false,
        isEditorChoice: json['is_editor_choice'] as bool? ?? false,
        createdAt: DateTime.parse(json['created_at'] as String).toLocal(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'product_name': productName,
        'brand': brand,
        'category': category,
        'rating': rating,
        'review_count': reviewCount,
        'price': price,
        'review_text': reviewText,
        'pros': pros,
        'cons': cons,
        'image_url': imageUrl,
        'is_verified_purchase': isVerifiedPurchase,
        'is_editor_choice': isEditorChoice,
        'created_at': createdAt.toUtc().toIso8601String(),
      };
}
