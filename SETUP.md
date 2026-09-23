# Carty setup guide

Follow these steps in order. Parts 1–3 are required. Parts 4–5 are only for Google and Apple login.

---

## Part 1: Create the Supabase project

1. Go to https://supabase.com, sign in with GitHub and click **New project**.
2. Name: `carty`. Choose a region close to Jordan (e.g. Frankfurt). Save the database password somewhere safe.
3. Wait about 2 minutes for the project to be created.

## Part 2: Create the database

1. In the left menu, open **SQL Editor** and click **New query**.
2. Open `supabase/schema.sql` from this project, copy **everything**, paste it and click **Run**.
3. Open **Table Editor**. You should see `categories` (6 rows) and `products` (24 rows).

> Run the file only once. Running it a second time gives "policy already exists" errors.

## Part 3: Connect the app to Supabase

> Malik: `env.json` already exists with your current Supabase project's URL and key, so you can skip to step 5.

1. In Supabase, open **Project Settings → API Keys** and copy the **Publishable key** (it starts with `sb_publishable_`).
2. Open **Project Settings → Data API** and copy the **Project URL**.
3. In the project folder, copy `env.example.json` and rename the copy to `env.json`.
4. Paste your values into `env.json`:
   ```json
   {
     "SUPABASE_URL": "https://abcdxyz.supabase.co",
     "SUPABASE_PUBLISHABLE_KEY": "sb_publishable_..."
   }
   ```
5. Run the app:
   ```
   flutter pub get
   flutter run --dart-define-from-file=env.json
   ```
   In **Android Studio**:
   1. Open **Run → Edit Configurations → main.dart**.
   2. In **Additional run args**, write `--dart-define-from-file=env.json`.
   3. Click **OK**.

**Optional, for easier testing:** Supabase → **Authentication → Sign In / Providers → Email**. Turn **Confirm email** off, so new accounts can log in without clicking an email link.

---

## Part 4: Google login

### How it works

1. The user taps **Continue with Google**.
2. The app opens Google's login page in the browser.
3. The user picks their Google account.
4. Google sends the user to **Supabase**, which creates or finds the account.
5. Supabase sends the user back to the app using the link `carty://login-callback`.
6. Android and iOS open Carty because of that link. This is set up in `AndroidManifest.xml` and `Info.plist`.
7. `supabase_flutter` reads the login from the link. `AuthGate` sees the user is logged in and shows the Home screen.

### Steps

1. Go to https://console.cloud.google.com and create a project called `Carty`.
2. Open **APIs & Services → OAuth consent screen** (also called "Google Auth Platform"):
   - User type: **External**
   - App name: `Carty`, plus your email
   - Add yourself under **Test users**
3. Open **APIs & Services → Credentials → Create credentials → OAuth client ID**:
   - Application type: **Web application**
   - Under **Authorized redirect URIs**, add:
     `https://YOUR-PROJECT-ID.supabase.co/auth/v1/callback`
     You can copy this exact URL from Supabase → Authentication → Providers → Google.
   - Click **Create**, then copy the **Client ID** and **Client secret**.
4. In Supabase, open **Authentication → Sign In / Providers → Google**:
   - Turn it **on**.
   - Paste the Client ID and Client secret.
   - Click **Save**.
5. In Supabase, open **Authentication → URL Configuration → Redirect URLs**. Click **Add URL**, enter `carty://login-callback` and save.
6. Run the app and tap **Continue with Google**.

---

## Part 5: Apple login

Apple login works the same way as Google (browser, then Supabase, then back to the app), but Apple has two extra requirements:

1. **You need a paid Apple Developer account** ($99/year). Without it, you can't create the keys Supabase needs.
2. **The secret key expires every 6 months.** You must generate a new one and paste it into Supabase again.

If you don't have an Apple Developer account yet, the Apple button shows an error when tapped, but the rest of the app works normally.

### Steps (when you have the account)

1. Go to https://developer.apple.com/account → **Certificates, Identifiers & Profiles**:
   1. **Identifiers → App IDs:** create one, e.g. `com.malik.carty`, and enable **Sign in with Apple**.
   2. **Identifiers → Services IDs:** create one, e.g. `com.malik.carty.web`.
      - Enable **Sign in with Apple** and click **Configure**.
      - Primary App ID: the App ID from step 1.
      - Domain: `YOUR-PROJECT-ID.supabase.co`
      - Return URL: `https://YOUR-PROJECT-ID.supabase.co/auth/v1/callback`
   3. **Keys:** create a key with **Sign in with Apple** enabled and download the `.p8` file. You can only download it once.
2. In Supabase, open **Authentication → Sign In / Providers → Apple**:
   - Turn it **on**.
   - Client IDs: your Services ID (`com.malik.carty.web`).
   - Secret Key: use the generator on that page. It needs your Team ID, Key ID and the `.p8` file.
   - Click **Save**.
3. `carty://login-callback` is already in your Redirect URLs from Part 4.
4. Put a reminder in your calendar to generate a new secret in 5 months.

---

## Push the new version to GitHub

```
git add .
git commit -m "Rebuild Carty with Provider, Supabase database and Google/Apple login"
git push
```

`env.json` is in `.gitignore`, so your keys stay on your computer.
