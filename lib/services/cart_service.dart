import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/cart_item.dart';

/// The cart is stored in the `cart_items` table, so it survives
/// app restarts and is the same on every device the user logs in on.
class CartService {
  final SupabaseClient _client;

  CartService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  Future<List<CartItem>> fetchCart() async {
    final rows = await _client
        .from('cart_items')
        .select('quantity, product:products(*)')
        .eq('user_id', _userId)
        .order('created_at', ascending: true);
    return rows.map(CartItem.fromMap).toList();
  }

  /// Insert the row, or update the quantity if the product is already in the cart.
  Future<void> setQuantity(int productId, int quantity) async {
    await _client.from('cart_items').upsert(
      {'user_id': _userId, 'product_id': productId, 'quantity': quantity},
      onConflict: 'user_id,product_id',
    );
  }

  Future<void> removeItem(int productId) async {
    await _client
        .from('cart_items')
        .delete()
        .eq('user_id', _userId)
        .eq('product_id', productId);
  }
}
