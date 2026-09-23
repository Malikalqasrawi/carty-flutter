import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/nav_provider.dart';

/// Cart icon with a badge showing how many items are in the cart.
/// Tapping it jumps to the Cart tab from anywhere in the app.
class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CartProvider>().totalQuantity;

    return IconButton(
      tooltip: 'My Cart',
      onPressed: () {
        // Read the provider BEFORE popping (this widget may be on a page
        // that gets closed by popUntil).
        final nav = context.read<NavProvider>();
        Navigator.of(context).popUntil((route) => route.isFirst);
        nav.goTo(NavProvider.cart);
      },
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        backgroundColor: const Color(0xFFDBFE72),
        textColor: Colors.black,
        child: const Icon(Icons.shopping_bag_outlined),
      ),
    );
  }
}
