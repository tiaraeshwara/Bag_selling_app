# Bag Selling App

A Flutter storefront UI for browsing and selecting fashion bags, with a glassmorphism-inspired design, local auth persistence, favorites, and a demo checkout flow.

## Project Overview

Root widget: `ElegantCosmeticApp` — entry point in `lib/main.dart` (~3,500 lines).

The app includes:
- Responsive navigation layout (desktop wide-rail + compact/mobile drawer)
- Featured bag collection with a new-arrivals carousel
- Saved / favourite products page
- Search dialog for bag discovery
- Selection billing panel with quantity controls
- Mock payment confirmation flow
- Login / Signup with local persistence via `shared_preferences`

## Implemented Features

### 1. Authentication (local / demo)
- Login and Signup forms with basic credential validation
- Credentials stored in `SharedPreferences` (demo only — not suitable for production)
- Forgot-password dialog (UI flow)
- Authenticated state persisted across sessions

### 2. Shopping Experience
- New-arrivals horizontal slider (`NewArrivalSection`)
- Full bag grid with "View all" toggle (`BagPage`)
- Product metadata: name, price, category, material, colour
- **Buy Now** adds items to the billing panel
- Quantity increase / decrease / remove controls
- Running total bill calculation

### 3. Saved / Favourites
- Heart-toggle on every product card
- Dedicated `SavedPage` listing all favourited items

### 4. Search
- Search popup filters bags by name, category, colour, and material
- Triggered from the top nav bar and the in-page search field

### 5. Filters Sidebar
- `FiltersSidebar` widget with category, material, and colour filter chips
- Filters applied live to the bag grid

### 6. Demo Payment Flow
- Bank-details modal collects card / account info
- Confirmation dialog before submitting
- Success feedback via `SnackBar`
- Clears selected items after successful payment

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Material 3) |
| Language | Dart `^3.10.7` |
| Fonts | `google_fonts ^6.2.1` |
| Persistence | `shared_preferences ^2.5.3` |
| Icons | `cupertino_icons ^1.0.8` |

## Key Components

| Class | Role |
|---|---|
| `ElegantCosmeticApp` | App root, theme configuration |
| `AuthGateway` | Decides login vs. main shell on startup |
| `AuthSection` | Login / Signup / Forgot-password UI |
| `MainNavigationLayout` | Top nav bar + page routing |
| `BagPage` | Main catalogue page |
| `SavedPage` | Favourites page |
| `NewArrivalSection` | Horizontal carousel of new arrivals |
| `FiltersSidebar` | Live filter panel |
| `BagDescriptionSection` | Inline product description block |
| `ArrivalBagCard` | Card widget for new-arrival items |
| `GlassCard` / `GlassImageTile` | Glassmorphism UI primitives |

## Assets

24 product images (`bag1.jpg` – `bag24.jpg`) stored in `assets/` and registered in `pubspec.yaml`.

## Run Locally

### Prerequisites
- Flutter SDK installed and on `PATH`
- A configured emulator, simulator, or physical device

### Commands
```bash
flutter pub get
flutter run
```

## Quality Checks

```bash
flutter analyze
flutter test
```

> `test/widget_test.dart` is currently a placeholder — no meaningful tests exist yet.

## Project Structure

```
lib/
  main.dart           # All app code (~3,500 lines)
assets/               # Product images (bag1.jpg – bag24.jpg)
pubspec.yaml          # Dependencies and asset registration
analysis_options.yaml
```

## Current Limitations

- No backend: auth, catalogue, and payment are all local / demo
- All screens live in a single `main.dart` file
- No real state-management solution — state is passed via callbacks

## Suggested Next Steps

- Split code into feature folders (`auth/`, `catalog/`, `cart/`, `shared/`)
- Replace local credential storage with a real auth service
- Add widget and integration tests
- Introduce a state-management library (e.g., Riverpod, Bloc, or Provider)
- Connect catalogue and payment to a real backend / API