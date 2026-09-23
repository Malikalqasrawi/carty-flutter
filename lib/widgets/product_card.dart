import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../screens/product_details_screen.dart';
import 'favorite_button.dart';
import 'net_image.dart';
import 'quantity_stepper.dart';

/// Grid card: image, favorite heart, name, price and add/stepper.
/// Tapping the card opens the Product Details page.
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final quantity = cart.quantityOf(product.id);
    final scheme = Theme.of(context).colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailsScreen(product: product),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image + heart
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.all(8),
                        // Hero = the image "flies" to the details page.
                        child: Hero(
                          tag: 'product-${product.id}',
                          child: NetImage(product.imageUrl, fit: BoxFit.contain),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: FavoriteButton(product: product, size: 18),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                product.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Text(
                'per ${product.unit}',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      product.priceText,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.priceOf(context),
                      ),
                    ),
                  ),
                  if (quantity == 0)
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton.filled(
                        padding: EdgeInsets.zero,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () => cart.add(product),
                        icon: const Icon(Icons.add, size: 20),
                      ),
                    )
                  else
                    QuantityStepper(
                      compact: true,
                      quantity: quantity,
                      onIncrement: () => cart.add(product),
                      onDecrement: () => cart.decrement(product),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Grid layout shared by Home, Category, Search and Favorites.
class ProductGridDelegate extends SliverGridDelegateWithMaxCrossAxisExtent {
  const ProductGridDelegate()
      : super(
          maxCrossAxisExtent: 220,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.66,
        );
}
