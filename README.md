# Carty 🛒

An online grocery app built with **Flutter**, **Provider** and **Supabase**.

Users can sign up with email, **Google** or **Apple**, browse products by category, manage a cart that syncs across devices, check out, and see their order history.

## Features

- **Modern UI**: bottom navigation, auto-sliding promo banners, category bubbles and a product grid, with Hero animations into the product page
- **Dark mode**: Light / Dark / System, remembered between launches
- **Auth**: email/password with validation (Jordanian phone format), plus **Google** and **Apple** sign-in through Supabase OAuth and a deep link
- **Product details** page with description, price per unit and add-to-cart
- **Search** across all products, with debounced typing and popular suggestions
- **Favorites / wishlist** saved per user in the database
- **Cart** synced to the database: survives restarts and works across devices, with optimistic updates and a free-delivery progress bar
- **Map location picker** (Talabat-style): drag the map under a fixed pin, or jump to your GPS position; the address is looked up automatically (OpenStreetMap + Nominatim, no API key)
- **Checkout** that pre-fills your saved address and map location; orders are created by one database function (`place_order`) in a single transaction, with the total calculated on the server
- **Profile**: edit name, phone and default address; see your order history
- **Row Level Security**: each user can only read and change their own cart, favorites and orders

## Tech stack

| Layer | Tech |
|---|---|
| UI | Flutter (Material 3) |
| State management | Provider (`ChangeNotifier`) |
| Backend | Supabase: Auth, Postgres, RLS, RPC |
| Tests | `flutter_test` (models, validators, widgets) |

## Project structure

```
lib/
├── main.dart              # starts Supabase + registers providers
├── app.dart               # MaterialApp, routes, AuthGate
├── config/env.dart        # reads keys from --dart-define
├── core/                  # theme, validators
├── models/                # Product, ProductCategory, CartItem, Order
├── services/              # the only code that talks to Supabase
├── providers/             # app state (auth, products, cart, orders)
├── screens/               # one file per page
└── widgets/               # reusable UI pieces
supabase/schema.sql        # tables, RLS policies, trigger, place_order, seed data
supabase/upgrade_v2.sql    # favorites, descriptions, popular flag, profile address
supabase/upgrade_v3.sql    # latitude/longitude on orders and profiles
```

Data flows **Screen → Provider → Service → Supabase**. Screens never call the database directly.

## Run it locally

1. Create a free project at [supabase.com](https://supabase.com).
2. In **SQL Editor**, run `supabase/schema.sql`, then `supabase/upgrade_v2.sql`, then `supabase/upgrade_v3.sql`.
3. Copy `env.example.json` to `env.json` and add your project URL and publishable key.
4. Run:
   ```bash
   flutter pub get
   flutter run --dart-define-from-file=env.json
   ```

See [SETUP.md](SETUP.md) for the full guide, including Google and Apple login.

## Screenshots

_Coming soon_

## Author

Malik · Faculty of IT, Applied Science Private University, Amman
