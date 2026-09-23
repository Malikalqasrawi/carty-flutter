# Carty 🛒

An online grocery app built with **Flutter**, **Provider** and **Supabase**.

Users can sign up with email, **Google** or **Apple**, browse products by category, manage a cart that syncs across devices, check out, and see their order history.

## Features

- Email/password sign-up and login, with form validation (Jordanian phone format, password rules)
- Social login with **Google** and **Apple** (Supabase OAuth + deep link)
- Categories and products loaded from a Postgres database
- Category search
- Cart saved in the database: survives restarts and syncs between devices
- Optimistic UI: cart updates right away and rolls back if saving fails
- Checkout with address, payment method and delivery instructions
- Orders are created by one database function (`place_order`) in a single transaction, and the total is calculated on the server
- "My Orders" history with expandable order details
- Row Level Security: each user can only read and change their own cart and orders

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
```

Data flows **Screen → Provider → Service → Supabase**. Screens never call the database directly.

## Run it locally

1. Create a free project at [supabase.com](https://supabase.com).
2. In **SQL Editor**, run `supabase/schema.sql`.
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
