# Bag Selling App

A Flutter storefront UI for browsing and selecting fashion bags, with a glassmorphism-inspired design, local auth persistence, favorites, and a demo checkout flow.

## Project Overview

This project is a single Flutter application currently centered in `lib/main.dart`.

It includes:
- a responsive navigation layout (desktop + compact/mobile behavior)
- a featured bag collection and new arrivals carousel
- saved/favorite products
- search dialog for bag discovery
- selected-items billing panel with quantity controls
- a mock payment confirmation flow
- login/signup with local persistence via `shared_preferences`

## Implemented Features

### 1) Authentication (local/demo)
- Login and Signup forms
- Basic credential validation against locally saved credentials
- Forgot password dialog (UI flow)
- Logged-in state persisted in local storage

### 2) Shopping Experience
- New arrivals horizontal slider
- “View all” bag grid
- Product metadata (name, price, category, material, color)
- Add to selection using **Buy Now**
- Quantity increase/decrease/remove controls
- Total bill calculation

### 3) Saved/Favorites
- Toggle favorite on product cards
- Dedicated Saved page showing selected favorite items

### 4) Search
- Search popup filters bags by name, category, color, and material
- Triggered from top nav and in-page search field

### 5) Demo Payment Flow
- Collects bank details in a modal
- Confirmation dialog before payment
- Success feedback via snackbar
- Clears selected items after successful payment

## Tech Stack

- Flutter (Material 3)
- Dart SDK: `^3.10.7`
- Dependencies:
	- `shared_preferences`
	- `google_fonts`
	- `cupertino_icons`

## Assets

Bag images are stored in `assets/` (`bag1.jpg` to `bag20.jpg`) and loaded via `pubspec.yaml`.

## Run Locally

### Prerequisites
- Flutter SDK installed and available in PATH
- A configured emulator, simulator, or device

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

Note: `test/widget_test.dart` is currently empty, so there are no meaningful widget/unit tests yet.

## Project Structure (key files)

- `lib/main.dart` - main app entry and all UI/screens/components
- `pubspec.yaml` - dependencies and asset registration
- `assets/` - product images
- `analysis_options.yaml` - lint/analyzer configuration

## Current Limitations

- No backend integration (auth/catalog/payment are local/demo only)
- Search, filter sidebar, and payment are UI-driven and not connected to APIs
- Most code currently lives in a single large file (`lib/main.dart`)

## Suggested Next Improvements

- Split UI into feature-based files (`auth`, `catalog`, `cart`, `shared widgets`)
- Add real data and service layers
- Add widget and integration tests
- Introduce state management as complexity grows (e.g., Riverpod/Bloc/Provider)
