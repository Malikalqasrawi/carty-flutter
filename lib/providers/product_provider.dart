import 'package:flutter/foundation.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service;

  ProductProvider(this._service);

  List<ProductCategory> _categories = [];
  bool _loadingCategories = false;
  String? _error;
  String _search = '';

  /// Products are cached per category, so going back and forth
  /// does not download them again.
  final Map<int, List<Product>> _productsByCategory = {};
  final Set<int> _loadingProducts = {};

  bool get isLoadingCategories => _loadingCategories;
  String? get error => _error;
  String get search => _search;

  List<ProductCategory> get categories {
    if (_search.isEmpty) return _categories;
    final q = _search.toLowerCase();
    return _categories.where((c) => c.name.toLowerCase().contains(q)).toList();
  }

  List<Product>? productsFor(int categoryId) => _productsByCategory[categoryId];
  bool isLoadingProducts(int categoryId) => _loadingProducts.contains(categoryId);

  void setSearch(String value) {
    _search = value.trim();
    notifyListeners();
  }

  Future<void> loadCategories({bool force = false}) async {
    if (_categories.isNotEmpty && !force) return;
    _loadingCategories = true;
    _error = null;
    notifyListeners();
    try {
      _categories = await _service.fetchCategories();
    } catch (_) {
      _error = 'Could not load categories.';
    } finally {
      _loadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> loadProducts(int categoryId, {bool force = false}) async {
    if (_productsByCategory.containsKey(categoryId) && !force) return;
    _loadingProducts.add(categoryId);
    _error = null;
    notifyListeners();
    try {
      _productsByCategory[categoryId] =
          await _service.fetchProductsByCategory(categoryId);
    } catch (_) {
      _error = 'Could not load products.';
    } finally {
      _loadingProducts.remove(categoryId);
      notifyListeners();
    }
  }
}
