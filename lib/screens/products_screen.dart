import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart';
import '../providers/product_provider.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/product_card.dart';

/// All products in one category, as a grid.
class ProductsScreen extends StatefulWidget {
  final ProductCategory category;

  const ProductsScreen({super.key, required this.category});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadProducts(widget.category.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final products = provider.productsFor(widget.category.id);
    final loading = provider.isLoadingProducts(widget.category.id);

    Widget body;
    if (loading && products == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (products == null) {
      body = Center(
        child: TextButton(
          onPressed: () => provider.loadProducts(widget.category.id, force: true),
          child: const Text('Could not load products. Try again'),
        ),
      );
    } else if (products.isEmpty) {
      body = const Center(child: Text('No products in this category yet'));
    } else {
      body = RefreshIndicator(
        onRefresh: () => provider.loadProducts(widget.category.id, force: true),
        child: GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          gridDelegate: const ProductGridDelegate(),
          itemCount: products.length,
          itemBuilder: (_, i) => ProductCard(product: products[i]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: const [CartIconButton(), SizedBox(width: 8)],
      ),
      body: body,
    );
  }
}
