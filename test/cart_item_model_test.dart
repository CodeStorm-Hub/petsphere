import 'package:flutter_test/flutter_test.dart';
import 'package:pet_dating_app/models/cart_item_model.dart';
import 'package:pet_dating_app/models/product_model.dart';

void main() {
  ProductModel makeProduct({double price = 9.99}) => ProductModel(
        id: 'p1',
        name: 'Test',
        price: price,
        vendorId: 'v1',
        description: '',
        images: const [],
        stock: 10,
        category: 'food',
      );

  group('CartItemModel', () {
    test('subtotal multiplies price by quantity', () {
      final item = CartItemModel(id: 'c1', product: makeProduct(price: 5), quantity: 3);
      expect(item.subtotal, 15);
    });

    test('copyWith preserves untouched fields', () {
      final item = CartItemModel(id: 'c1', product: makeProduct(), quantity: 1);
      final updated = item.copyWith(quantity: 4);
      expect(updated.id, 'c1');
      expect(updated.product.id, 'p1');
      expect(updated.quantity, 4);
    });

    test('default quantity is 1', () {
      final item = CartItemModel(id: 'c1', product: makeProduct());
      expect(item.quantity, 1);
    });
  });
}
