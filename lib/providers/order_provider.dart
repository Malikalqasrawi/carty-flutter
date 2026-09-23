import 'package:flutter/foundation.dart';

import '../models/order.dart';
import '../services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _service;

  OrderProvider(this._service);

  List<Order> _orders = [];
  bool _isLoading = false;
  bool _isPlacing = false;
  String? _error;

  List<Order> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  bool get isPlacing => _isPlacing;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _orders = await _service.fetchOrders();
    } catch (_) {
      _error = 'Could not load your orders.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Returns the new order id, or null if it failed.
  Future<int?> placeOrder({
    required String address,
    required String paymentMethod,
    required List<String> instructions,
    double? latitude,
    double? longitude,
  }) async {
    _isPlacing = true;
    _error = null;
    notifyListeners();
    try {
      final id = await _service.placeOrder(
        address: address,
        paymentMethod: paymentMethod,
        instructions: instructions,
        latitude: latitude,
        longitude: longitude,
      );
      await load(); // refresh "My Orders"
      return id;
    } catch (_) {
      _error = 'Could not place your order. Please try again.';
      return null;
    } finally {
      _isPlacing = false;
      notifyListeners();
    }
  }

  void clearLocal() {
    _orders = [];
    notifyListeners();
  }
}
