import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../utils/supabase_config.dart';

class MarketplaceRepository {
  // -------------------------------------------------------------------------
  // Fetch products (optionally filtered by category)
  // -------------------------------------------------------------------------
  Future<List<ProductModel>> fetchProducts({String? category}) async {
    var query = supabase.from('products').select();

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    final data = await query.order('created_at', ascending: false);

    return (data as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // -------------------------------------------------------------------------
  // Submit an order (called at checkout)
  // Cart stays local; only the final order lands in Supabase
  // -------------------------------------------------------------------------
  Future<void> placeOrder({
    required String userId,
    required List<CartItemModel> items,
  }) async {
    final total = items.fold<double>(0, (sum, i) => sum + i.subtotal);

    final orderItems = items
        .map(
          (i) => {
            'product_id': i.product.id,
            'name': i.product.name,
            'quantity': i.quantity,
            'price': i.product.price,
            'subtotal': i.subtotal,
          },
        )
        .toList();

    final insertedOrder = await supabase
        .from('orders')
        .insert({
          'user_id': userId,
          'items': orderItems,
          'total': total,
          'status': 'pending',
        })
        .select('id')
        .single();

    final orderId = insertedOrder['id'] as String;

    // Keep order_items normalized for easier reporting/analytics.
    await supabase
        .from('order_items')
        .insert(
          items
              .map(
                (i) => {
                  'order_id': orderId,
                  'product_id': i.product.id,
                  'product_name': i.product.name,
                  'unit_price': i.product.price,
                  'quantity': i.quantity,
                },
              )
              .toList(),
        );
  }
}

final marketplaceRepository = MarketplaceRepository();
