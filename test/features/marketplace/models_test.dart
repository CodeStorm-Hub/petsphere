import 'package:flutter_test/flutter_test.dart';
import 'package:petfolio/features/marketplace/data/models/product_model.dart';
import 'package:petfolio/features/marketplace/data/models/cart_item_model.dart';
import 'package:petfolio/features/marketplace/data/models/order_model.dart';

void main() {
  group('ProductModel', () {
    test('fromJson creates a valid ProductModel', () {
      final json = {
        'id': 'p1',
        'name': 'Dog Food',
        'description': 'Premium kibble',
        'price': 25.5,
        'vendor_id': 'v1',
        'images': ['https://example.com/food.png'],
        'category': 'Food',
        'stock': 10,
        'rating': 4.5,
      };

      final product = ProductModel.fromJson(json);

      expect(product.id, 'p1');
      expect(product.name, 'Dog Food');
      expect(product.price, 25.5);
      expect(product.stock, 10);
    });

    test('toJson returns a valid map', () {
      final product = ProductModel(
        id: 'p1',
        name: 'Dog Food',
        description: 'Premium kibble',
        price: 25.5,
        vendorId: 'v1',
        images: ['https://example.com/food.png'],
        category: 'Food',
        stock: 10,
        rating: 4.5,
      );

      final json = product.toJson();

      expect(json['id'], 'p1');
      expect(json['name'], 'Dog Food');
      expect(json['price'], 25.5);
      expect(json['stock'], 10);
    });
  });

  group('CartItemModel', () {
    final product = ProductModel(
      id: 'p1',
      name: 'Dog Food',
      description: 'Premium kibble',
      price: 25.0,
      vendorId: 'v1',
      images: [],
      category: 'Food',
      stock: 10,
    );

    test('subtotal calculates correctly', () {
      final item = CartItemModel(id: 'c1', product: product, quantity: 3);
      expect(item.subtotal, 75.0);
    });

    test('copyWith updates quantity', () {
      final item = CartItemModel(id: 'c1', product: product);
      final updated = item.copyWith(quantity: 5);
      expect(updated.quantity, 5);
      expect(updated.product.id, product.id);
    });
  });

  group('OrderModel', () {
    test('fromJson preserves shipping fields', () {
      final order = OrderModel.fromJson({
        'id': 'order-1',
        'user_id': 'user-1',
        'items': const <Map<String, Object?>>[
          {
            'product_id': 'p1',
            'name': 'Dog Food',
            'quantity': 2,
            'price': 10.0,
            'subtotal': 20.0,
          },
        ],
        'total': 20.0,
        'status': 'pending',
        'created_at': DateTime(2026, 5, 11).toIso8601String(),
        'shipping_name': 'Jane Smith',
        'shipping_address': '123 Paw Lane',
        'shipping_city': 'San Francisco',
        'shipping_state': 'CA',
        'shipping_zip': '94107',
      });

      expect(order.shippingName, 'Jane Smith');
      expect(order.shippingAddress, '123 Paw Lane');
      expect(order.shippingCity, 'San Francisco');
      expect(order.shippingState, 'CA');
      expect(order.shippingZip, '94107');
      expect(order.items.single.subtotal, 20.0);
    });
  });
}
