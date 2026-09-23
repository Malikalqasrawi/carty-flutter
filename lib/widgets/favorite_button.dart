import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/favorites_provider.dart';

/// Heart icon that adds/removes a product from favorites.
class FavoriteButton extends StatelessWidget {
  final Product product;
  final double size;

  const FavoriteButton({super.key, required this.product, this.size = 22});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final isFav = favorites.isFavorite(product.id);

    return Material(
      color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () => favorites.toggle(product),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, animation) =>
                ScaleTransition(scale: animation, child: child),
            child: Icon(
              isFav ? Icons.favorite : Icons.favorite_border,
              key: ValueKey(isFav),
              size: size,
              color: isFav ? const Color(0xFFE53935) : null,
            ),
          ),
        ),
      ),
    );
  }
}
