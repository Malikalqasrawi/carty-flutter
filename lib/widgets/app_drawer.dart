import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    void goTo(String route) {
      Navigator.pop(context); // close drawer
      Navigator.pushNamed(context, route);
    }

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.accent),
            accountName: Text(
              auth.displayName,
              style: const TextStyle(
                  color: Colors.black, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              auth.user?.email ?? '',
              style: const TextStyle(color: Colors.black87),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.primary,
              foregroundImage:
                  auth.avatarUrl != null ? NetworkImage(auth.avatarUrl!) : null,
              child: Text(
                auth.displayName.isNotEmpty
                    ? auth.displayName[0].toUpperCase()
                    : '?',
                style: const TextStyle(fontSize: 28, color: AppColors.accent),
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.shopping_cart_outlined),
            title: const Text('My Cart'),
            onTap: () => goTo(AppRoutes.cart),
          ),
          ListTile(
            leading: const Icon(Icons.receipt_long_outlined),
            title: const Text('My Orders'),
            onTap: () => goTo(AppRoutes.orders),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Logout', style: TextStyle(color: AppColors.error)),
            onTap: () async {
              // Go back to the first screen, then log out.
              // AuthGate will then show the Login screen.
              Navigator.of(context).popUntil((route) => route.isFirst);
              await auth.signOut();
            },
          ),
        ],
      ),
    );
  }
}
