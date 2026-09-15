# TOURNA

TOURNA is a Flutter application for discovering and participating in competitive tournaments. Phase 1 provides the Material 3 foundation, adaptive navigation, and static previews for the product's five main destinations.

## Run locally

```sh
flutter pub get
flutter run
```

Quality checks:

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

## Phase 1 architecture

- `lib/app` owns application bootstrap and centralized light/dark Material 3 themes.
- `lib/features/<feature>/presentation` keeps each destination independently evolvable while the navigation feature owns destination selection and adaptive shell behavior.
- `lib/core/widgets` contains presentation primitives genuinely shared across features.
- The shell uses a bottom navigation bar on phones and a navigation rail on wider layouts. An `IndexedStack` preserves destination state between switches.
- All content is static mock data. Backend services, authentication, payments, QR codes, notifications, and tournament business logic are intentionally deferred.
