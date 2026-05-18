# 🍲 Recipe Mood Planner

A modern Flutter app to browse recipes and save them into a personal **mood-based journal** — powered entirely by the [DummyJSON API](https://dummyjson.com/).

---

## ✨ Features

| Feature | Description |
|---|---|
| 🔍 Recipe Explorer | Browse 30+ recipes with image, cuisine, rating, difficulty |
| ❤️ Favorites | Toggle favorite recipes locally |
| 🔎 Search | Search recipes by name or cuisine via API |
| 📔 Mood Journal | Save recipes with mood tags (Happy, Sad, Energy, Comfort) |
| ⭐ Ratings | Rate recipes 1–5 stars with descriptive labels |
| 📝 Notes | Add personal journal notes to each recipe |
| 🎨 Mood Filter | Filter journal entries by mood tag |
| 📊 Mood Stats | See counts per mood at a glance |
| 🔄 Pull to Refresh | Refresh both recipe list and journal |
| ⚠️ Error Handling | Graceful error states with retry buttons |
| 💀 Skeleton Loading | Shimmer loading placeholders |
| 🌑 Dark Theme | Full dark mode with warm accent colors |

---

## 🏗️ Architecture

```
lib/
├── models/
│   ├── recipe.dart          # Recipe model (DummyJSON /recipes)
│   └── journal_entry.dart   # JournalEntry model (DummyJSON /posts)
├── providers/
│   ├── recipe_provider.dart # Recipe state (fetch, search, favorites)
│   └── journal_provider.dart# Journal state (CRUD, filter)
├── services/
│   ├── recipe_service.dart  # HTTP calls to /recipes
│   └── journal_service.dart # HTTP calls to /posts (CRUD)
├── screens/
│   ├── home_screen.dart         # Recipe Explorer tab
│   ├── journal_screen.dart      # Mood Journal tab
│   └── add_edit_journal_screen.dart # Add/Edit entry form
├── widgets/
│   ├── app_theme.dart       # Colors, typography, ThemeData
│   └── common_widgets.dart  # RecipeCard, JournalCard, EmptyState, etc.
└── main.dart                # App entry, MultiProvider, navigation
```

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK ≥ 3.0.0
- Dart ≥ 3.0.0

### Installation

```bash
# Clone or unzip the project
cd recipe_mood_planner

# Get dependencies
flutter pub get

# Run the app
flutter run
```

### Build

```bash
# Android APK
flutter build apk --release

# iOS
flutter build ios --release
```

---

## 📡 API Endpoints Used

| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/recipes` | Browse recipes |
| GET | `/recipes/search?q=` | Search recipes |
| GET | `/posts` | Fetch journal entries |
| POST | `/posts/add` | Create journal entry |
| PUT | `/posts/{id}` | Update journal entry |
| DELETE | `/posts/{id}` | Delete journal entry |

> **Note:** DummyJSON is a mock API — POSTs/PUTs/DELETEs are simulated and won't persist between sessions. Entries added locally in-memory are shown immediately.

---

## 📦 Dependencies

| Package | Version | Purpose |
|---|---|---|
| `provider` | ^6.1.1 | State management |
| `http` | ^1.2.0 | HTTP requests |
| `google_fonts` | ^6.1.0 | Playfair Display + Plus Jakarta Sans |
| `cached_network_image` | ^3.3.1 | Image caching |
| `flutter_rating_bar` | ^4.0.1 | Star rating input |
| `shimmer` | ^3.0.0 | Loading skeletons |
| `flutter_staggered_animations` | ^1.1.1 | List animations |

---

## 🎨 Design Decisions

- **Dark theme** with warm orange (`#FF6B35`) as primary
- **Playfair Display** for headings (editorial feel)
- **Plus Jakarta Sans** for body (clean readability)  
- Mood tags encoded into the DummyJSON `post.body` field as pipe-delimited data
- Local state updates immediately on CRUD for snappy UX

---

## 📄 License

MIT
