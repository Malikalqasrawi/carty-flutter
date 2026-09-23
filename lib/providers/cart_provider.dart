import 'package:flutter/foundation.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';

/// The cart lives in Supabase. This provider keeps a local copy so the UI
/// updates instantly ("optimistic update"), then saves the change to the
/// database. If saving fails, the change is undone and an error is shown.
class CartProvider extends ChangeNotifier {
  final CartService _service;

  CartProvider(this._service);

  List<CartItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CartItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmpty => _items.isEmpty;

  int get totalQuantity {
    int total = 0;
    for (final item in _items) {
      total += item.quantity;
    }
    return total;
  }

  double get totalPrice {
    double total = 0;
    for (final item in _items) {
      total += item.lineTotal;
    }
    return total;
  }

  int quantityOf(int productId) {
    for (final item in _items) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _items = await _service.fetchCart();
    } catch (_) {
      _error = 'Could not load your cart.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> add(Product product) => setQuantity(product, quantityOf(product.id) + 1);

  Future<void> decrement(Product product) =>
      setQuantity(product, quantityOf(product.id) - 1);

  Future<void> remove(Product product) => setQuantity(product, 0);

  /// Quantity 0 (or less) removes the product from the cart.
  Future<void> setQuantity(Product product, int quantity) async {
    final backup = List<CartItem>.from(_items);
    final index = _items.indexWhere((i) => i.product.id == product.id);

    // 1. Update the screen immediately.
    if (quantity <= 0) {
      if (index != -1) _items.removeAt(index);
    } else if (index == -1) {
      _items.add(CartItem(product: product, quantity: quantity));
    } else {
      _items[index] = _items[index].copyWith(quantity: quantity);
    }
    _error = null;
    notifyListeners();

    // 2. Save to Supabase; roll back if it fails.
    try {
      if (quantity <= 0) {
        await _service.removeItem(product.id);
      } else {
        await _service.setQuantity(product.id, quantity);
      }
    } catch (_) {
      _items = backup;
      _error = 'Could not update your cart. Please try again.';
      notifyListeners();
    }
  }

  /// Called after an order is placed (the database already emptied the cart)
  /// and on logout.
  void clearLocal() {
    _items = [];
    _error = null;
    notifyListeners();
  }
}
