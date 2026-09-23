import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/nav_provider.dart';
import 'cart_screen.dart';
import 'favorites_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

/// The main app frame after login: 5 tabs with a bottom navigation bar.
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  static const _tabs = <Widget>[
    HomeScreen(),
    SearchScreen(),
    FavoritesScreen(),
    CartScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final nav = context.watch<NavProvider>();
    final cartCount = context.watch<CartProvider>().totalQuantity;
    final favCount = context.watch<FavoritesProvider>().items.length;

    return Scaffold(
      // IndexedStack keeps every tab alive, so scroll position and
      // search text are not lost when switching tabs.
      body: IndexedStack(
        index: nav.index,
        children: [
          for (int i = 0; i < _tabs.length; i++)
            // Only the visible tab takes part in Hero animations
            // (otherwise the same product in two tabs would clash).
            HeroMode(enabled: i == nav.index, child: _tabs[i]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: nav.index,
        onDestinationSelected: nav.goTo,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          const NavigationDestination(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: favCount > 0,
              label: Text('$favCount'),
              child: const Icon(Icons.favorite_border),
            ),
            selectedIcon: const Icon(Icons.favorite),
            label: 'Favorites',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: cartCount > 0,
              label: Text('$cartCount'),
              child: const Icon(Icons.shopping_bag_outlined),
            ),
            selectedIcon: const Icon(Icons.shopping_bag),
            label: 'Cart',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
