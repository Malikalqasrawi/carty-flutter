import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.dart';
import '../models/product.dart';

class ProductService {
  final SupabaseClient _client;

  ProductService([SupabaseClient? client])
      : _client = client ?? Supabase.instance.client;

  Future<List<ProductCategory>> fetchCategories() async {
    final rows = await _client
        .from('categories')
        .select()
        .order('sort_order', ascending: true);
    return rows.map(ProductCategory.fromMap).toList();
  }

  Future<List<Product>> fetchProductsByCategory(int categoryId) async {
    final rows = await _client
        .from('products')
        .select()
        .eq('category_id', categoryId)
        .order('name', ascending: true);
    return rows.map(Product.fromMap).toList();
  }
}
