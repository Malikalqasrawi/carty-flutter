import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/favorites_provider.dart';
import '../providers/nav_provider.dart';
import '../widgets/product_card.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favorites = context.watch<FavoritesProvider>();
    final items = favorites.items;
    final scheme = Theme.of(context).colorScheme;

    Widget body;
    if (favorites.isLoading && items.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (items.isEmpty) {
      body = ListView(
        // ListView so pull-to-refresh still works when empty.
        children: [
          const SizedBox(height: 140),
          Icon(Icons.favorite_border, size: 80, color: scheme.onSurfaceVariant),
          const SizedBox(height: 12),
          const Center(
            child: Text('No favorites yet',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text('Tap the ♥ on any product to save it here.',
                style: TextStyle(color: scheme.onSurfaceVariant)),
          ),
          const SizedBox(height: 16),
          Center(
            child: TextButton(
              onPressed: () => context.read<NavProvider>().goTo(NavProvider.home),
              child: const Text('Browse products'),
            ),
          ),
        ],
      );
    } else {
      body = GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        gridDelegate: const ProductGridDelegate(),
        itemCount: items.length,
        itemBuilder: (_, i) => ProductCard(product: items[i]),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: RefreshIndicator(onRefresh: favorites.load, child: body),
    );
  }
}
