import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/marketplace/data/models/gear_review_models.dart';

void main() {
  final testDate = DateTime.utc(2026, 1, 10, 9);

  GearReview makeReview({
    String id = 'review-1',
    double rating = 4.5,
    bool verified = false,
  }) {
    return GearReview(
      id: id,
      userId: 'user-1',
      productName: 'Dog Harness Pro',
      brand: 'PetTech',
      category: 'Accessories',
      rating: rating,
      reviewCount: 120,
      price: '\$39.99',
      createdAt: testDate,
      isVerifiedPurchase: verified,
    );
  }

  group('GearReview', () {
    test('constructs with required fields', () {
      final review = makeReview();

      expect(review.id, 'review-1');
      expect(review.productName, 'Dog Harness Pro');
      expect(review.brand, 'PetTech');
      expect(review.rating, 4.5);
      expect(review.isVerifiedPurchase, false);
      expect(review.isEditorChoice, false);
      expect(review.pros, isNull);
      expect(review.cons, isNull);
    });

    test('fromJson deserializes all fields', () {
      final json = {
        'id': 'review-2',
        'user_id': 'user-2',
        'product_name': 'Cat Tower Deluxe',
        'brand': 'FurHome',
        'category': 'Furniture',
        'rating': 5.0,
        'review_count': 45,
        'price': '\$89.99',
        'review_text': 'My cat loves it!',
        'pros': ['Sturdy', 'Easy assembly'],
        'cons': ['Heavy'],
        'image_url': 'https://example.com/tower.jpg',
        'is_verified_purchase': true,
        'is_editor_choice': true,
        'created_at': testDate.toIso8601String(),
      };

      final review = GearReview.fromJson(json);

      expect(review.id, 'review-2');
      expect(review.productName, 'Cat Tower Deluxe');
      expect(review.rating, 5.0);
      expect(review.pros, ['Sturdy', 'Easy assembly']);
      expect(review.cons, ['Heavy']);
      expect(review.isVerifiedPurchase, true);
      expect(review.isEditorChoice, true);
      expect(review.reviewText, 'My cat loves it!');
    });

    test('fromJson applies defaults for optional fields', () {
      final json = {
        'id': 'review-3',
        'user_id': 'user-1',
        'product_name': 'Basic Leash',
        'category': 'Accessories',
        'rating': 3.0,
        'created_at': testDate.toIso8601String(),
      };

      final review = GearReview.fromJson(json);

      expect(review.brand, 'Generic');
      expect(review.price, 'TBD');
      expect(review.reviewCount, 0);
      expect(review.isVerifiedPurchase, false);
      expect(review.isEditorChoice, false);
    });

    test('toJson includes id (used for display, not insert)', () {
      final review = makeReview();
      final json = review.toJson();

      expect(json['id'], 'review-1');
      expect(json['product_name'], 'Dog Harness Pro');
      expect(json['brand'], 'PetTech');
      expect(json['rating'], 4.5);
      expect(json['is_verified_purchase'], false);
    });

    test('toJson roundtrips through fromJson', () {
      final original = GearReview(
        id: 'review-rt',
        userId: 'user-1',
        productName: 'Pet Carrier',
        brand: 'TravelPet',
        category: 'Travel',
        rating: 4.0,
        reviewCount: 88,
        price: '\$59.99',
        pros: const ['Lightweight', 'Airline-approved'],
        cons: const ['Small for large cats'],
        isVerifiedPurchase: true,
        createdAt: testDate,
      );

      final json = original.toJson();
      final restored = GearReview.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.productName, original.productName);
      expect(restored.pros, original.pros);
      expect(restored.cons, original.cons);
      expect(restored.isVerifiedPurchase, original.isVerifiedPurchase);
    });

    test('copyWith updates only specified fields', () {
      final original = makeReview(rating: 4.0);
      final updated = original.copyWith(
        rating: 5.0,
        isEditorChoice: true,
      );

      expect(updated.rating, 5.0);
      expect(updated.isEditorChoice, true);
      expect(updated.id, original.id);
      expect(updated.productName, original.productName);
      expect(original.rating, 4.0); // immutable
    });

    test('equality is value-based', () {
      final r1 = makeReview();
      final r2 = makeReview();

      expect(r1, equals(r2));
    });

    test('different ratings break equality', () {
      final r1 = makeReview(rating: 3.0);
      final r2 = makeReview(rating: 5.0);

      expect(r1, isNot(equals(r2)));
    });
  });
}
