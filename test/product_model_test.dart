import 'package:flutter_test/flutter_test.dart';
import 'package:pet_dating_app/models/product_model.dart';

void main() {
  group('ProductModel', () {
    test('parses a complete row from Postgres', () {
      final p = ProductModel.fromJson({
        'id': 'p1',
        'name': 'Test Treat',
        'price': 12.50,
        'vendor_id': 'v1',
        'description': 'A treat.',
        'images': ['https://example.com/a.jpg'],
        'stock': 5,
        'category': 'food',
        'rating': 4.6,
        'review_count': 12,
        'tags': ['organic', 'grain-free'],
        'is_bestseller': true,
      });

      expect(p.id, 'p1');
      expect(p.price, 12.50);
      expect(p.images, ['https://example.com/a.jpg']);
      expect(p.tags.length, 2);
      expect(p.isBestseller, isTrue);
    });

    test('tolerates missing optional fields', () {
      final p = ProductModel.fromJson({
        'id': 'p2',
        'name': 'Plain',
        'price': 1,
        'vendor_id': 'v2',
      });

      expect(p.images, isEmpty);
      expect(p.stock, 0);
      expect(p.rating, 0);
      expect(p.tags, isEmpty);
      expect(p.isBestseller, isFalse);
    });
  });
}
