import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/order.dart';

class OrderService {
  final SupabaseClient _client;

  OrderService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  /// Calls the `place_order` database function (see supabase/schema.sql).
  /// It creates the order from the cart, copies the items and empties the
  /// cart in ONE transaction, so an order can never be half-saved.
  Future<int> placeOrder({
    required String address,
    required String paymentMethod,
    required List<String> instructions,
  }) async {
    final orderId = await _client.rpc(
      'place_order',
      params: {
        'p_address': address,
        'p_payment_method': paymentMethod,
        'p_instructions': instructions,
      },
    );
    return orderId as int;
  }

  Future<List<Order>> fetchOrders() async {
    final rows = await _client
        .from('orders')
        .select('*, order_items(*)')
        .eq('user_id', _client.auth.currentUser!.id)
        .order('created_at', ascending: false);
    return rows.map(Order.fromMap).toList();
  }
}
