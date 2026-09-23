import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../providers/cart_provider.dart';

/// Cart icon with a badge showing how many items are in the cart.
class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    final count = context.watch<CartProvider>().totalQuantity;

    return IconButton(
      tooltip: 'My Cart',
      onPressed: () => Navigator.pushNamed(context, AppRoutes.cart),
      icon: Badge(
        isLabelVisible: count > 0,
        label: Text('$count'),
        backgroundColor: Colors.black,
        textColor: const Color(0xFFDBFE72),
        child: const Icon(Icons.shopping_cart_outlined),
      ),
    );
  }
}
