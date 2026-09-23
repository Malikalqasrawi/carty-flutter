import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../services/favorites_service.dart';

class FavoritesProvider extends ChangeNotifier {
  final FavoritesService _service;

  FavoritesProvider(this._service);

  List<Product> _items = [];
  bool _isLoading = false;
  String? _error;

  List<Product> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool isFavorite(int productId) => _items.any((p) => p.id == productId);

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _service.fetchFavorites();
    } catch (_) {
      _error = 'Could not load your favorites.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Optimistic toggle: update the heart right away, undo if saving fails.
  Future<void> toggle(Product product) async {
    final wasFavorite = isFavorite(product.id);
    final backup = List<Product>.from(_items);

    if (wasFavorite) {
      _items.removeWhere((p) => p.id == product.id);
    } else {
      _items.insert(0, product);
    }
    _error = null;
    notifyListeners();

    try {
      if (wasFavorite) {
        await _service.remove(product.id);
      } else {
        await _service.add(product.id);
      }
    } catch (_) {
      _items = backup;
      _error = 'Could not update favorites.';
      notifyListeners();
    }
  }

  void clearLocal() {
    _items = [];
    notifyListeners();
  }
}
