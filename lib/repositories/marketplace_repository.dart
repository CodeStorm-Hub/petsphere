import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../utils/supabase_config.dart';

class CreatePaymentIntentResult {
  final String clientSecret;
  final String paymentIntentId;
  const CreatePaymentIntentResult({
    required this.clientSecret,
    required this.paymentIntentId,
  });
}

class MarketplaceOutOfStockException implements Exception {
  final List<OutOfStockLine> lines;
  MarketplaceOutOfStockException(this.lines);

  @override
  String toString() {
    if (lines.isEmpty) return 'One or more items are out of stock.';
    final joined = lines
        .map((l) => '${l.productName} (available ${l.available}, requested ${l.requested})')
        .join(', ');
    return 'Some items are out of stock: $joined';
  }
}

class OutOfStockLine {
  final String productId;
  final String productName;
  final int available;
  final int requested;
  OutOfStockLine({
    required this.productId,
    required this.productName,
    required this.available,
    required this.requested,
  });
}

class MarketplaceRepository {
  // -------------------------------------------------------------------------
  // Fetch products (optionally filtered by category)
  // -------------------------------------------------------------------------
  Future<List<ProductModel>> fetchProducts({String? category}) async {
    var query = supabase.from('products').select();

    if (category != null && category.isNotEmpty) {
      query = query.eq('category', category);
    }

    final data =
        await query.order('created_at', ascending: false).limit(200);

    return (data as List<dynamic>)
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // -------------------------------------------------------------------------
  // Fetch a single product by ID — used for deep-linking into /product/:id
  // -------------------------------------------------------------------------
  Future<ProductModel?> fetchProductById(String id) async {
    final data =
        await supabase.from('products').select().eq('id', id).maybeSingle();
    if (data == null) return null;
    return ProductModel.fromJson(data);
  }

  // -------------------------------------------------------------------------
  // Submit an order (called at checkout)
  // Cart stays local; only the final order lands in Supabase
  // -------------------------------------------------------------------------
  Future<void> placeOrder({
    required String userId,
    required List<CartItemModel> items,
    String? paymentProvider,
    String? paymentIntentId,
  }) async {
    await _validateStockOrThrow(items);

    final total = items.fold<double>(0, (sum, i) => sum + i.subtotal);

    final orderItems = items
        .map((i) => {
              'product_id': i.product.id,
              'name': i.product.name,
              'quantity': i.quantity,
              'price': i.product.price,
              'subtotal': i.subtotal,
            })
        .toList();

    final payload = <String, dynamic>{
      'user_id': userId,
      'items': orderItems,
      'total': total,
      'status': 'pending',
      if (paymentProvider != null && paymentProvider.isNotEmpty)
        'payment_provider': paymentProvider,
      if (paymentIntentId != null && paymentIntentId.isNotEmpty)
        'payment_intent_id': paymentIntentId,
    };

    await supabase.from('orders').insert(payload);
  }

  Future<CreatePaymentIntentResult> createStripePaymentIntent({
    required int amountCents,
    String currency = 'usd',
    Map<String, String>? metadata,
  }) async {
    final res = await supabase.functions.invoke(
      'create-payment-intent',
      body: {
        'amount_cents': amountCents,
        'currency': currency,
        'metadata': metadata ?? <String, String>{},
      },
    );

    final data = res.data;
    if (data is! Map) {
      throw Exception('Payment init failed: invalid response');
    }
    final map = data.map((k, v) => MapEntry(k.toString(), v));
    final clientSecret = map['client_secret'] as String?;
    final paymentIntentId = map['payment_intent_id'] as String?;
    if (clientSecret == null ||
        clientSecret.isEmpty ||
        paymentIntentId == null ||
        paymentIntentId.isEmpty) {
      throw Exception('Payment init failed: missing client secret');
    }
    return CreatePaymentIntentResult(
      clientSecret: clientSecret,
      paymentIntentId: paymentIntentId,
    );
  }

  Future<void> _validateStockOrThrow(List<CartItemModel> items) async {
    if (items.isEmpty) return;
    final ids = items.map((i) => i.product.id).toSet().toList();
    final data = await supabase
        .from('products')
        .select('id,name,stock')
        .inFilter('id', ids);

    final byId = <String, Map<String, dynamic>>{};
    for (final row in (data as List<dynamic>)) {
      final m = row as Map<String, dynamic>;
      final id = m['id'] as String?;
      if (id != null) byId[id] = m;
    }

    final missingOrInvalid = <OutOfStockLine>[];
    for (final line in items) {
      final row = byId[line.product.id];
      final available = (row?['stock'] as num?)?.toInt() ?? 0;
      final name = (row?['name'] as String?) ?? line.product.name;
      if (available < line.quantity) {
        missingOrInvalid.add(
          OutOfStockLine(
            productId: line.product.id,
            productName: name,
            available: available,
            requested: line.quantity,
          ),
        );
      }
    }

    if (missingOrInvalid.isNotEmpty) {
      throw MarketplaceOutOfStockException(missingOrInvalid);
    }
  }

  // -------------------------------------------------------------------------
  // Fetch orders for a user
  // -------------------------------------------------------------------------
  Future<List<OrderModel>> fetchOrders(String userId) async {
    final data = await supabase
        .from('orders')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(100);

    return (data as List<dynamic>)
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final marketplaceRepository = MarketplaceRepository();
