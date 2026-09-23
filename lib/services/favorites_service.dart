import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';

/// Favorites are stored in the `favorites` table (one row per user + product).
class FavoritesService {
  final SupabaseClient _client;

  FavoritesService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  String get _userId => _client.auth.currentUser!.id;

  Future<List<Product>> fetchFavorites() async {
    final rows = await _client
        .from('favorites')
        .select('product:products(*)')
        .eq('user_id', _userId)
        .order('created_at', ascending: false);
    return rows
        .map((row) => Product.fromMap(row['product'] as Map<String, dynamic>))
        .toList();
  }

  Future<void> add(int productId) async {
    await _client.from('favorites').upsert(
      {'user_id': _userId, 'product_id': productId},
      onConflict: 'user_id,product_id',
    );
  }

  Future<void> remove(int productId) async {
    await _client
        .from('favorites')
        .delete()
        .eq('user_id', _userId)
        .eq('product_id', productId);
  }
}
