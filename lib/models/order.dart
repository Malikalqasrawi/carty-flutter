class OrderItem {
  final String productName;
  final double unitPrice;
  final int quantity;

  const OrderItem({
    required this.productName,
    required this.unitPrice,
    required this.quantity,
  });

  double get lineTotal => unitPrice * quantity;

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productName: map['product_name'] as String,
      unitPrice: (map['unit_price'] as num).toDouble(),
      quantity: map['quantity'] as int,
    );
  }
}

class Order {
  final int id;
  final DateTime createdAt;
  final String address;
  final String paymentMethod;
  final List<String> instructions;
  final double total;
  final String status;
  final List<OrderItem> items;

  const Order({
    required this.id,
    required this.createdAt,
    required this.address,
    required this.paymentMethod,
    required this.instructions,
    required this.total,
    required this.status,
    required this.items,
  });

  int get itemCount {
    int count = 0;
    for (final item in items) {
      count += item.quantity;
    }
    return count;
  }

  /// Reads a row from: orders.select('*, order_items(*)')
  factory Order.fromMap(Map<String, dynamic> map) {
    final rawItems = (map['order_items'] ?? []) as List<dynamic>;
    final rawInstructions = (map['instructions'] ?? []) as List<dynamic>;

    return Order(
      id: map['id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      address: map['address'] as String,
      paymentMethod: map['payment_method'] as String,
      instructions: rawInstructions.map((e) => e.toString()).toList(),
      total: (map['total'] as num).toDouble(),
      status: map['status'] as String,
      items: rawItems
          .map((e) => OrderItem.fromMap(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
