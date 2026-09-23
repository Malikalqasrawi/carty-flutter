import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme.dart';
import '../models/category.dart';
import '../providers/auth_provider.dart';
import '../providers/nav_provider.dart';
import '../providers/product_provider.dart';
import '../widgets/cart_icon_button.dart';
import '../widgets/carty_logo.dart';
import '../widgets/net_image.dart';
import '../widgets/product_card.dart';
import 'products_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load after the first frame (context is ready then).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadHome();
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final name = context.watch<AuthProvider>().displayName.split(' ').first;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 20,
        title: Row(
          children: [
            // Lime tile keeps the black logo visible in dark mode too.
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const CartyLogo(size: 22),
            ),
            const SizedBox(width: 10),
            const Text('Carty'),
          ],
        ),
        actions: const [CartIconButton(), SizedBox(width: 8)],
      ),
      body: RefreshIndicator(
        onRefresh: () => products.loadHome(force: true),
        child: CustomScrollView(
          slivers: [
            // ---------- Greeting + search box ----------
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi $name 👋',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      'What would you like to buy today?',
                      style: TextStyle(color: scheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    // Looks like a search box; tapping opens the Search tab.
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => context.read<NavProvider>().goTo(NavProvider.search),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                        ),
                        child: Text(
                          'Search for apples, milk, bread...',
                          style: TextStyle(color: scheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ---------- Promo banners ----------
            const SliverToBoxAdapter(child: _PromoCarousel()),

            if (products.isLoadingHome && products.categories.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else if (products.error != null && products.categories.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(products.error!),
                      TextButton(
                        onPressed: () => products.loadHome(force: true),
                        child: const Text('Try again'),
                      ),
                    ],
                  ),
                ),
              )
            else ...[
              // ---------- Categories (horizontal) ----------
              const SliverToBoxAdapter(child: _SectionTitle('Categories')),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 112,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    scrollDirection: Axis.horizontal,
                    itemCount: products.categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (_, i) => _CategoryBubble(category: products.categories[i]),
                  ),
                ),
              ),

              // ---------- Popular products (grid) ----------
              const SliverToBoxAdapter(child: _SectionTitle('Popular right now 🔥')),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                sliver: SliverGrid.builder(
                  gridDelegate: const ProductGridDelegate(),
                  itemCount: products.popular.length,
                  itemBuilder: (_, i) => ProductCard(product: products.popular[i]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Text(text, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
    );
  }
}

class _CategoryBubble extends StatelessWidget {
  final ProductCategory category;
  const _CategoryBubble({required this.category});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ProductsScreen(category: category)),
      ),
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              width: 72,
              height: 72,
              padding: const EdgeInsets.all(3),
              decoration: const BoxDecoration(
                color: AppColors.accent,
                shape: BoxShape.circle,
              ),
              child: ClipOval(child: NetImage(category.imageUrl, radius: 0)),
            ),
            const SizedBox(height: 6),
            Text(
              category.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Auto-sliding promo banners with page dots.
class _PromoCarousel extends StatefulWidget {
  const _PromoCarousel();

  @override
  State<_PromoCarousel> createState() => _PromoCarouselState();
}

class _PromoCarouselState extends State<_PromoCarousel> {
  static const _promos = [
    (
      title: 'Fresh fruits\n20% off',
      subtitle: 'This week only',
      icon: Icons.local_florist_outlined,
      colors: [Color(0xFFDBFE72), Color(0xFFB8E04A)],
    ),
    (
      title: 'Free delivery\nover 15 JOD',
      subtitle: 'Anywhere in Amman',
      icon: Icons.local_shipping_outlined,
      colors: [Color(0xFF111111), Color(0xFF3A3A3A)],
    ),
    (
      title: 'Bakery fresh\nevery morning',
      subtitle: 'Order before 10 AM',
      icon: Icons.bakery_dining_outlined,
      colors: [Color(0xFFFFC857), Color(0xFFFF9F43)],
    ),
  ];

  final _controller = PageController(viewportFraction: 0.9);
  Timer? _timer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_controller.hasClients) return;
      final next = (_page + 1) % _promos.length;
      _controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          child: PageView.builder(
            controller: _controller,
            itemCount: _promos.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) {
              final promo = _promos[i];
              final dark = promo.colors.first.computeLuminance() < 0.3;
              final fg = dark ? Colors.white : Colors.black;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(colors: promo.colors),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              promo.title,
                              style: TextStyle(
                                color: fg,
                                fontSize: 22,
                                height: 1.15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(promo.subtitle,
                                style: TextStyle(color: fg.withValues(alpha: 0.8))),
                          ],
                        ),
                      ),
                      Icon(promo.icon, size: 72, color: fg.withValues(alpha: 0.85)),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Page dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < _promos.length; i++)
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: i == _page ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: i == _page
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
