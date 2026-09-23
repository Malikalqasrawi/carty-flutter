import 'package:flutter/foundation.dart';

/// Which bottom-navigation tab is selected.
/// Lets any screen jump to a tab, e.g. the cart icon opens the Cart tab.
class NavProvider extends ChangeNotifier {
  static const home = 0;
  static const search = 1;
  static const favorites = 2;
  static const cart = 3;
  static const profile = 4;

  int _index = home;
  int get index => _index;

  void goTo(int index) {
    if (_index == index) return;
    _index = index;
    notifyListeners();
  }
}
