import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/checkout_screen.dart';
import 'screens/home_screen.dart';
import 'screens/orders_screen.dart';

class AppRoutes {
  static const register = '/register';
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orders = '/orders';
}

class CartyApp extends StatelessWidget {
  const CartyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Carty',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGate(),
      routes: {
        AppRoutes.register: (_) => const RegisterScreen(),
        AppRoutes.cart: (_) => const CartScreen(),
        AppRoutes.checkout: (_) => const CheckoutScreen(),
        AppRoutes.orders: (_) => const OrdersScreen(),
      },
    );
  }
}

/// Decides which screen to show: Login (logged out) or Home (logged in).
/// Because it listens to AuthProvider, it switches automatically after
/// email login, after Google/Apple redirect back, and after logout.
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  String? _loadedUserId;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    // Load (or clear) the user's cart and orders once per login.
    if (user?.id != _loadedUserId) {
      _loadedUserId = user?.id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final cart = context.read<CartProvider>();
        final orders = context.read<OrderProvider>();
        if (user == null) {
          cart.clearLocal();
          orders.clearLocal();
        } else {
          cart.load();
          orders.load();
        }
      });
    }

    return user == null ? const LoginScreen() : const HomeScreen();
  }
}

/// Shown when the app is started without Supabase keys.
class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text(
              'Supabase keys are missing.\n\n'
              '1. Copy env.example.json to env.json\n'
              '2. Put your Supabase URL and publishable key in it\n'
              '3. Run: flutter run --dart-define-from-file=env.json',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
