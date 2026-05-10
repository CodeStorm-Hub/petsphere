import 'package:flutter/foundation.dart';

@immutable
class OrderModel {
  final String id;
  final String userId;
  final List<OrderLineItem> items;
  final double total;
  final String status;
  final DateTime createdAt;

  const OrderModel({
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
      items:
          (json['items'] as List<dynamic>?)
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

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'items': items.map((i) => i.toJson()).toList(),
    'total': total,
    'status': status,
    'created_at': createdAt.toIso8601String(),
  };

  OrderModel copyWith({
    String? id,
    String? userId,
    List<OrderLineItem>? items,
    double? total,
    String? status,
    DateTime? createdAt,
  }) => OrderModel(
    id: id ?? this.id,
    userId: userId ?? this.userId,
    items: items ?? this.items,
    total: total ?? this.total,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          userId == other.userId &&
          items == other.items &&
          total == other.total &&
          status == other.status &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      userId.hashCode ^
      items.hashCode ^
      total.hashCode ^
      status.hashCode ^
      createdAt.hashCode;
}


@immutable
class OrderLineItem {
  final String productId;
  final String name;
  final int quantity;
  final double price;
  final double subtotal;

  const OrderLineItem({
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

  Map<String, dynamic> toJson() => {
    'product_id': productId,
    'name': name,
    'quantity': quantity,
    'price': price,
    'subtotal': subtotal,
  };

  OrderLineItem copyWith({
    String? productId,
    String? name,
    int? quantity,
    double? price,
    double? subtotal,
  }) => OrderLineItem(
    productId: productId ?? this.productId,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    price: price ?? this.price,
    subtotal: subtotal ?? this.subtotal,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderLineItem &&
          runtimeType == other.runtimeType &&
          productId == other.productId &&
          name == other.name &&
          quantity == other.quantity &&
          price == other.price &&
          subtotal == other.subtotal;

  @override
  int get hashCode =>
      productId.hashCode ^
      name.hashCode ^
      quantity.hashCode ^
      price.hashCode ^
      subtotal.hashCode;
}
