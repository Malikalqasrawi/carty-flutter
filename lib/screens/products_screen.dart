import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/category.dart';
import '../models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/net_image.dart';
import '../widgets/quantity_stepper.dart';

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
        child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: products.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (_, index) => _ProductTile(product: products[index]),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        actions: const [CartIconButton()],
      ),
      body: body,
    );
  }
}

class _ProductTile extends StatelessWidget {
  final Product product;

  const _ProductTile({required this.product});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final quantity = cart.quantityOf(product.id);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            NetImage(product.imageUrl, width: 72, height: 72, fit: BoxFit.contain),
            const SizedBox(width: 12),
            // Expanded stops long names from overflowing the row.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.priceLabel,
                    style: const TextStyle(color: AppColors.price, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (quantity == 0)
              FilledButton.icon(
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
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add'),
              )
            else
              QuantityStepper(
                quantity: quantity,
                onIncrement: () => cart.add(product),
                onDecrement: () => cart.decrement(product),
              ),
          ],
        ),
      ),
    );
  }
}
