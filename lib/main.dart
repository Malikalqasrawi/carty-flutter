import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'config/env.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'services/auth_service.dart';
import 'services/cart_service.dart';
import 'services/order_service.dart';
import 'services/product_service.dart';

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

  runApp(
    // Every provider is created once here and shared with all screens.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(AuthService())),
        ChangeNotifierProvider(create: (_) => ProductProvider(ProductService())),
        ChangeNotifierProvider(create: (_) => CartProvider(CartService())),
        ChangeNotifierProvider(create: (_) => OrderProvider(OrderService())),
      ],
      child: const CartyApp(),
    ),
  );
}
