import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pet_dating_app/controllers/cart_controller.dart';
import 'package:pet_dating_app/models/product_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  ProductModel makeProduct({String id = 'p1', double price = 9.99}) =>
      ProductModel(
        id: id,
        name: 'Test',
        price: price,
        vendorId: 'v1',
        description: '',
        images: const [],
        stock: 10,
        category: 'food',
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CartController persistence', () {
    test('addProduct writes the cart to shared_preferences', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cartProvider.notifier);
      // Allow async hydrate (which finds nothing) to settle.
      await Future<void>.delayed(Duration.zero);

      notifier.addProduct(makeProduct());
      // Allow the async _persist call to settle.
      await Future<void>.delayed(Duration.zero);

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('petsphere.cart.v1');
      expect(raw, isNotNull);
      final decoded = jsonDecode(raw!) as List<dynamic>;
      expect(decoded.length, 1);
      expect(
        (decoded.first as Map<String, dynamic>)['product']['id'],
        'p1',
      );
    });

    test('updateQuantity to 0 removes item and persists empty list', () async {
      SharedPreferences.setMockInitialValues({
        'petsphere.cart.v1': jsonEncode([
          {
            'id': 'c1',
            'quantity': 2,
            'product': {
              'id': 'p1',
              'name': 'Test',
              'price': 5,
              'vendor_id': 'v1',
              'description': '',
              'images': <String>[],
              'stock': 10,
              'category': 'food',
              'rating': 0,
              'review_count': 0,
              'tags': <String>[],
              'is_bestseller': false,
            },
          }
        ]),
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(cartProvider.notifier);
      // Allow hydrate to read from prefs.
      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(container.read(cartProvider).items.length, 1);

      notifier.updateQuantity('c1', 0);
      await Future<void>.delayed(Duration.zero);

      expect(container.read(cartProvider).items, isEmpty);
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('petsphere.cart.v1');
      expect(jsonDecode(raw!), isEmpty);
    });
  });

  // shared_preferences uses a platform channel; nothing to tear down beyond
  // the per-test mock reset. Silence unused-import warnings on ServicesBinding.
  ServicesBinding.instance.toString();
}
