class OrderModel {
  final String id;
  final String userId;
  final List<OrderLineItem> items;
  final double total;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OrderLineItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  String get statusLabel {
    return switch (status) {
      'pending' => 'Pending',
      'confirmed' => 'Confirmed',
      'shipped' => 'Shipped',
      'delivered' => 'Delivered',
      'cancelled' => 'Cancelled',
      _ => status,
    };
  }
}

class OrderLineItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final double subtotal;

  OrderLineItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.price,
    required this.subtotal,
  });

  factory OrderLineItem.fromJson(Map<String, dynamic> json) {
    return OrderLineItem(
      productId: json['product_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      price: (json['price'] as num?)?.toDouble() ?? 0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0,
    );
  }
}
