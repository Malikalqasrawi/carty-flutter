import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/env.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/nav_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'providers/profile_provider.dart';
import 'providers/theme_provider.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'services/favorites_service.dart';
import 'services/order_service.dart';
import 'services/product_service.dart';
import 'services/profile_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // If the app was started without env.json, show a helpful screen
  // instead of crashing.
  if (!Env.isConfigured) {
    runApp(const MissingConfigApp());
    return;
  }

  await Supabase.initialize(
    url: Env.supabaseUrl,
    publishableKey: Env.supabaseKey,
  );

  // Read the saved light/dark choice before the first frame.
  final themeProvider = ThemeProvider();
  await themeProvider.load();

  runApp(
    // Every provider is created once here and shared with all screens.
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => NavProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(create: (_) => ProductProvider(ProductService())),
        ChangeNotifierProvider(create: (_) => CartProvider(CartService())),
        ChangeNotifierProvider(create: (_) => OrderProvider(OrderService())),
        ChangeNotifierProvider(create: (_) => FavoritesProvider(FavoritesService())),
        ChangeNotifierProvider(create: (_) => ProfileProvider(ProfileService())),
      ],
      child: const CartyApp(),
    ),
  );
}
