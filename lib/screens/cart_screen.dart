import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../core/theme.dart';
import '../providers/cart_provider.dart';
import '../providers/nav_provider.dart';
import '../widgets/net_image.dart';
import '../widgets/quantity_stepper.dart';

/// Cart tab (bottom navigation).
class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  static const _freeDeliveryFrom = 15.0; // JOD, matches the promo banner

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final scheme = Theme.of(context).colorScheme;

    Widget body;
    if (cart.isLoading && cart.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (cart.isEmpty) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_bag_outlined, size: 64),
            ),
            const SizedBox(height: 16),
            const Text('Your cart is empty',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Add something fresh to get started.',
                style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<NavProvider>().goTo(NavProvider.home),
              child: const Text('Start shopping'),
            ),
          ],
        ),
      );
    } else {
      final remaining = _freeDeliveryFrom - cart.totalPrice;
      body = ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
        children: [
          // Free-delivery progress bar
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    remaining > 0
                        ? 'Add ${remaining.toStringAsFixed(2)} JOD more for free delivery'
                        : 'You get free delivery! 🎉',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: (cart.totalPrice / _freeDeliveryFrom).clamp(0.0, 1.0),
                      color: AppColors.accent,
                      backgroundColor: scheme.surfaceContainerHighest,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (cart.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(cart.error!, style: const TextStyle(color: AppColors.error)),
            ),
          for (final item in cart.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Dismissible(
                key: ValueKey(item.product.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 24),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.delete_outline, color: Colors.white),
                ),
                onDismissed: (_) => cart.remove(item.product),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: NetImage(item.product.imageUrl, fit: BoxFit.contain),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.product.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${item.lineTotal.toStringAsFixed(2)} JOD',
                                style: TextStyle(
                                  color: AppColors.priceOf(context),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        QuantityStepper(
                          compact: true,
                          quantity: item.quantity,
                          onIncrement: () => cart.add(item.product),
                          onDecrement: () => cart.decrement(item.product),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          Text(
            'Tip: swipe an item left to remove it.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: RefreshIndicator(onRefresh: cart.load, child: body),
      bottomNavigationBar: cart.isEmpty
          ? null
          : SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${cart.totalQuantity} items',
                              style: TextStyle(color: scheme.onSurfaceVariant)),
                          Text(
                            '${cart.totalPrice.toStringAsFixed(2)} JOD',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 160,
                      child: ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.checkout),
                        child: const Text('Checkout'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
