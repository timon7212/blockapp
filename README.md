# VITALITY — Premium Move-to-Earn App

A polished Flutter frontend prototype for a premium move-to-earn mobile application.

## Getting Started

1. **Ensure Flutter is installed** (SDK >=3.2.0)
2. **Generate platform directories:**
   ```bash
   flutter create .
   ```
3. **Install dependencies:**
   ```bash
   flutter pub get
   ```
4. **Run the app:**
   ```bash
   flutter run
   ```

## Architecture

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp configuration
├── core/
│   ├── constants/               # App & economy constants
│   ├── router/                  # Navigation (future GoRouter)
│   └── utils/                   # Formatters, helpers
├── design_system/
│   ├── colors/                  # AppColors palette
│   ├── typography/              # AppTypography styles
│   ├── theme/                   # AppTheme (dark)
│   └── widgets/                 # Reusable glass cards, buttons, pills
├── models/                      # Data models
├── mock_data/                   # Rich mock data for all features
├── services/                    # Mock services (economy, steps, etc.)
├── shared/
│   └── providers/               # Riverpod state providers
└── features/
    ├── shell/                   # Bottom navigation shell
    ├── home/                    # Dashboard + Bio-Avatar + BIO-SYNC
    ├── arena/                   # PvP Duels, Global Raid, Social Feed
    ├── grid/                    # Referral network levels
    └── vault/                   # Rewards, Offers, Neuro-Games
```

## Tech Stack

- **Flutter** with Dart
- **Riverpod** for state management
- **Google Fonts** (Inter) for typography
- **CustomPainter** for progress rings and effects

## Features

- 4-tab navigation: Home, Arena, Grid, Vault
- Animated Bio-Avatar with vitality states (Peak/Stable/Low/Critical)
- BIO-SYNC reward simulation with economy split visualization
- 1v1 Duels and Global Raid community challenges
- 5-level referral network with Gold Zone
- Gift card marketplace, offerwall, and neuro-games
- Dev controls panel for testing states
- Full mock data with 300+ simulated network users

## Design

- OLED black dark theme
- Neon purple / Electric blue / Gold accents
- Glassmorphism panels with blur
- Premium spacing and typography hierarchy
- Animated progress indicators
- Vitality-responsive visual states

## Note

This is a **frontend-only** prototype. All data is mock/simulated.
Backend integration points are marked with `TODO` comments throughout the codebase.
