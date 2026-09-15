# TOURNA

TOURNA is a Flutter application for discovering and participating in competitive tournaments. Phase 2 adds Supabase email/password authentication while preserving the Material 3 foundation, adaptive navigation, and static previews for the product's five main destinations.

## Run locally

```sh
flutter pub get
flutter run \
  --dart-define=SUPABASE_URL=https://your-project.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=your-anon-key
```

Copy `.env.example` to an ignored `.env` file if you prefer to keep local
values together, then pass them with `--dart-define-from-file=.env`. Only use
the public anon key in the app; never use a Supabase service-role key.

Quality checks:

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Architecture

- `lib/app` owns application bootstrap and centralized light/dark Material 3 themes.
- `lib/core/config` reads public Supabase client settings from runtime dart-defines. Never put a service-role key in the app.
- `lib/features/auth` owns the authentication domain contract, Supabase adapter, session gate, and email/password screens.
- `lib/features/<feature>/presentation` keeps each destination independently evolvable while the navigation feature owns destination selection and adaptive shell behavior.
- `lib/core/widgets` contains presentation primitives genuinely shared across features.
- The shell uses a bottom navigation bar on phones and a navigation rail on wider layouts. An `IndexedStack` preserves destination state between switches.
- Tournament content remains static mock data. Payments, QR codes, notifications, and tournament business logic remain intentionally deferred.
