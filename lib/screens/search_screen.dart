import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../widgets/product_card.dart';

/// Search products by name across all categories.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _suggestions = ['Apple', 'Milk', 'Bread', 'Chicken', 'Juice', 'Cheese'];

  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  /// Wait 350 ms after the user stops typing before searching,
  /// so we don't send a request for every single letter.
  void _onChanged(String value) {
    setState(() {}); // update the clear (x) button
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      context.read<ProductProvider>().search(value);
    });
  }

  void _useSuggestion(String text) {
    _controller.text = text;
    _debounce?.cancel();
    setState(() {});
    context.read<ProductProvider>().search(text);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final results = provider.searchResults;
    final query = provider.searchQuery;
    final scheme = Theme.of(context).colorScheme;

    Widget body;
    if (query.isEmpty) {
      body = ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Popular searches',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final s in _suggestions)
                ActionChip(label: Text(s), onPressed: () => _useSuggestion(s)),
            ],
          ),
        ],
      );
    } else if (provider.isSearching && results.isEmpty) {
      body = const Center(child: CircularProgressIndicator());
    } else if (results.isEmpty) {
      body = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off, size: 64, color: scheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text('No products match "$query"'),
          ],
        ),
      );
    } else {
      body = GridView.builder(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        gridDelegate: const ProductGridDelegate(),
        itemCount: results.length,
        itemBuilder: (_, i) => ProductCard(product: results[i]),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
            child: TextField(
              controller: _controller,
              onChanged: _onChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search products',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _controller.clear();
                          _onChanged('');
                        },
                      ),
              ),
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}
