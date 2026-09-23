import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/favorite_button.dart';
import '../widgets/net_image.dart';
import '../widgets/quantity_stepper.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final quantity = cart.quantityOf(product.id);
    final category = context.read<ProductProvider>().categoryById(product.categoryId);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        actions: [
          FavoriteButton(product: product),
          const CartIconButton(),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          // Big image (the same Hero tag as the card, so it animates in)
          Container(
            height: 280,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Hero(
              tag: 'product-${product.id}',
              child: NetImage(product.imageUrl, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 20),
          if (category != null)
            Text(
              category.name.toUpperCase(),
              style: TextStyle(
                letterSpacing: 1.2,
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: scheme.onSurfaceVariant,
              ),
            ),
          const SizedBox(height: 4),
          Text(
            product.name,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: product.priceText,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.priceOf(context),
                  ),
                ),
                TextSpan(
                  text: '  / ${product.unit}',
                  style: TextStyle(fontSize: 16, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'About this product',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            product.description.isEmpty
                ? 'Fresh quality product delivered to your door.'
                : product.description,
            style: TextStyle(
              fontSize: 15,
              height: 1.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              _InfoChip(icon: Icons.local_shipping_outlined, label: 'Same-day delivery'),
              SizedBox(width: 8),
              _InfoChip(icon: Icons.eco_outlined, label: 'Fresh quality'),
            ],
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          child: quantity == 0
              ? ElevatedButton.icon(
                  onPressed: () {
                    cart.add(product);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                  },
                  icon: const Icon(Icons.add_shopping_cart),
                  label: Text('Add to cart  •  ${product.priceText}'),
                )
              : Row(
                  children: [
                    QuantityStepper(
                      quantity: quantity,
                      onIncrement: () => cart.add(product),
                      onDecrement: () => cart.decrement(product),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Total: ${(product.price * quantity).toStringAsFixed(2)} JOD',
                        textAlign: TextAlign.end,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 6),
            Flexible(
              child: Text(label,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }
}
