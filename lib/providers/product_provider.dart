import 'package:flutter/foundation.dart';

import '../models/category.dart';
import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service;

  ProductProvider(this._service);

  List<ProductCategory> _categories = [];
  List<Product> _popular = [];
  bool _loadingHome = false;
  String? _error;

  /// Products are cached per category, so going back and forth
  /// does not download them again.
  final Map<int, List<Product>> _productsByCategory = {};
  final Set<int> _loadingProducts = {};

  // Search state
  List<Product> _searchResults = [];
  String _searchQuery = '';
  bool _searching = false;

  List<ProductCategory> get categories => _categories;
  List<Product> get popular => _popular;
  bool get isLoadingHome => _loadingHome;
  String? get error => _error;

  List<Product> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  bool get isSearching => _searching;

  List<Product>? productsFor(int categoryId) => _productsByCategory[categoryId];
  bool isLoadingProducts(int categoryId) => _loadingProducts.contains(categoryId);

  ProductCategory? categoryById(int id) {
    for (final c in _categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  /// Categories + popular products for the Home screen.
  Future<void> loadHome({bool force = false}) async {
    if (_categories.isNotEmpty && !force) return;
    _loadingHome = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _service.fetchCategories(),
        _service.fetchPopular(),
      ]);
      _categories = results[0] as List<ProductCategory>;
      _popular = results[1] as List<Product>;
    } catch (_) {
      _error = 'Could not load products. Check your connection.';
    } finally {
      _loadingHome = false;
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

  Future<void> search(String query) async {
    _searchQuery = query.trim();
    if (_searchQuery.isEmpty) {
      _searchResults = [];
      _searching = false;
      notifyListeners();
      return;
    }
    _searching = true;
    notifyListeners();
    final requested = _searchQuery;
    try {
      final results = await _service.search(requested);
      // Ignore old answers if the user kept typing.
      if (requested == _searchQuery) _searchResults = results;
    } catch (_) {
      _searchResults = [];
    } finally {
      if (requested == _searchQuery) {
        _searching = false;
        notifyListeners();
      }
    }
  }
}
