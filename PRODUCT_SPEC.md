# DoomScroll — Product Specification

> **Gamified Screen Time Tracker with Ad-to-Earn Rewards**
>
> Version 2.0 • Last updated: March 2026

---

## Table of Contents

1. [Product Overview](#1-product-overview)
2. [Business Model & Economy](#2-business-model--economy)
3. [User Flow](#3-user-flow)
4. [Features & Mechanics](#4-features--mechanics)
5. [Navigation Structure](#5-navigation-structure)
6. [Data Models](#6-data-models)
7. [Services & Infrastructure](#7-services--infrastructure)
8. [Backend Requirements (TODO)](#8-backend-requirements-todo)
9. [Frontend Architecture](#9-frontend-architecture)
10. [Push Notifications Strategy](#10-push-notifications-strategy)
11. [Celebration & Dopamine System](#11-celebration--dopamine-system)
12. [Production Checklist (Play Market)](#12-production-checklist-play-market)

---

## 1. Product Overview

**DoomScroll** turns passive social media usage into a rewarded activity. Users accumulate points while scrolling Instagram, TikTok, YouTube, etc. — then watch a rewarded ad to claim those points. Points are redeemed for gift cards, cash out, or raffle entries.

### Core Value Proposition
- **For Users:** "Your doom-scrolling finally pays off"
- **For Business:** Ad revenue from rewarded video ads, with 40% net margin

### Target Audience
- 16–35 year olds
- Heavy social media users (30min–3h/day)
- Interested in free money / gift cards
- Android (primary), iOS (secondary)

### Key Metrics
| Metric | Target |
|--------|--------|
| D1 Retention | >40% |
| D7 Retention | >20% |
| D30 Retention | >10% |
| Daily Sessions | 3–5 per user |
| Ads per DAU | 8–15 per day |
| Monthly ARPU | $0.18–$0.45 |

---

## 2. Business Model & Economy

### Revenue Source
100% ad-funded through rewarded video ads (Google AdMob).

### Revenue Math

```
eCPM Range:        $10–$30 (US market)
Mid eCPM:          $15
Revenue per view:  $0.015
Company margin:    40% → $0.006 per ad
Reward pool:       60% → $0.009 per ad
```

### Points Economy

```
Exchange rate:     50,000 pts = $50  →  1,000 pts = $1  →  1 pt = $0.001
Real value per ad: $0.009 = ~9 points of actual redeemable value
```

**Important:** Points shown to users are "engagement currency" — large numbers for dopamine. The gap between displayed points (2,000 per session) and real ad value (~9 pts) is reconciled through:
- High redemption prices for gift cards
- Raffle probability (most don't win)
- Spin wheel weighted toward low prizes
- Multiple ads per day across features

### Screen Time Accumulation

| Parameter | Value |
|-----------|-------|
| Points per minute | 100 |
| Max session duration | 20 min |
| Max points per session | 2,000 |
| Max sessions per day | 4 |
| Max daily screen time pts | 8,000 |

### Daily User Ad Budget (active user, ~12–15 ads/day)

| Source | Ads | Revenue |
|--------|-----|---------|
| Screen time claims (×4) | 4 | $0.06 |
| Spin wheel (×4) | 4 | $0.06 |
| Referral collection (×2) | 2 | $0.03 |
| Raffle tasks | 2–3 | $0.03–$0.045 |
| Offerwall / other | 1–2 | $0.015–$0.03 |
| **Total** | **12–15** | **$0.18–$0.23** |

### Streak Multipliers

| Streak | Multiplier | Name |
|--------|-----------|------|
| Day 0–2 | 1.0x | Starter |
| Day 3–6 | 1.1x | Warming Up |
| Day 7–13 | 1.2x | On Fire |
| Day 14–29 | 1.3x | Blazing |
| Day 30+ | 1.5x | Legendary |

### Rank System

| Rank | Min Points | Perks |
|------|-----------|-------|
| 🌱 Newcomer | 0 | 4 spins/day |
| ⭐ Explorer | 10,000 | 5 spins/day, +50 session bonus |
| 💎 Achiever | 50,000 | 6 spins/day, +100 session bonus |
| 🏆 Champion | 150,000 | 7 spins/day, +200 session bonus |
| 👑 Legend | 500,000 | 8 spins/day, +500 session bonus |

### Spin Wheel Prizes (weighted)

| Prize | Weight | Probability |
|-------|--------|-------------|
| 10 pts | 25 | 25% |
| 25 pts | 22 | 22% |
| 50 pts | 20 | 20% |
| 100 pts | 15 | 15% |
| 250 pts | 10 | 10% |
| 500 pts | 5 | 5% |
| 1,000 pts | 2 | 2% |
| 5,000 pts | 1 | 1% |

**Expected value per spin: ~95 pts ($0.095 display value, $0.009 real ad value)**

### Redemption Prices

| Item | Cost | Real Value |
|------|------|------------|
| $5 Gift Card | 5,000 pts | $5.00 |
| $10 Gift Card | 10,000 pts | $10.00 |
| $25 Gift Card | 25,000 pts | $25.00 |
| Cash Out Min | 50,000 pts | $50.00 |

### Referral Commissions

| Level | Commission | Unlock |
|-------|-----------|--------|
| Level 1 (Direct) | 10% | Always |
| Level 2 (Indirect) | 5% | 3+ invites |

Collection requires watching 1 rewarded ad per level.

---

## 3. User Flow

### First-Time User Journey

```
App Launch → Auth Screen → Onboarding (6 steps) → Home Screen
```

#### Onboarding Steps (6 total)
1. **Welcome** — Brand intro, "Turn screen time into rewards"
2. **Usage Question** — "How much time do you spend on social media daily?" (4 options)
3. **Earnings Demo** — Animated counter showing potential daily/monthly earnings
4. **Claim Demo** — Simulated accumulation bar + mock ad + confetti celebration
5. **Streaks Intro** — Explain multiplier tiers with visual progression
6. **Ready!** — Summary of earning potential + confetti + "Start Earning" CTA

**Key:** User receives instant reward on onboarding completion.

### Daily Core Loop (Hook Model)

```
TRIGGER:  Push notification ("Points ready!" / "Streak at risk!")
    ↓
ACTION:   Open app → See accumulated points → Tap "Claim"
    ↓
REWARD:   Watch ad → Points added with celebration overlay + streak updated
    ↓
INVEST:   Check daily goals → Spin wheel → Enter raffle → Explore offers
    ↓
(repeat 3-4x daily)
```

### Session Flow

```
1. Open app → See balance + streak banner
2. Accumulation widget shows pending points
3. Tap "Claim" → Watch rewarded ad → Points credited (with multiplier)
4. Complete daily goals (claim, spin, raffle, watch ads)
5. Check raffles → complete tasks for entry
6. Visit store → browse gift cards / cash out
7. Invite friends via Network tab
```

---

## 4. Features & Mechanics

### 4.1 Screen Time Accumulation
- Points accumulate while user uses social media apps (tracked via Screen Time API)
- Visual progress ring shows accumulation (0% → 100%)
- When full: "Ready to Claim" state with golden pulsing button
- **Claim requires watching 1 rewarded ad**
- Streak multiplier applied on claim
- Up to 4 sessions per day (reset at midnight)

### 4.2 Streak System (Duolingo-Level)
- Consecutive daily claims build streak
- Multiplier tiers unlock at days 3, 7, 14, 30
- **Streak Freeze:** User can buy protection (500 pts), auto-used on missed day
- **Streak Recovery:** Watch 3 ads within 24h to recover lost streak
- **Calendar View:** Month view showing claimed days (green fire icons)
- **Milestone Rewards:** Every 5-day streak → Mystery Box
- **Loss Aversion:** Dramatic UI when streak is at risk

### 4.3 Daily Goals
4 daily tasks that reset at midnight:

| Goal | Target | Bonus |
|------|--------|-------|
| Claim Points | 1 session | 200 pts |
| Spin & Win | 1 spin | 200 pts |
| Daily Raffle | Enter 1 raffle | 300 pts |
| Ad Power | Watch 3 ads | 300 pts |

Completing 3/4 → 500 pts bonus. All 4/4 → 1,500 pts bonus.

### 4.4 Spin Wheel
- Each spin requires watching 1 rewarded ad
- 4 spins/day base (increases with rank)
- Weighted prizes (see economy section)
- Animated wheel with haptic feedback + confetti on big wins
- Resets daily at midnight

### 4.5 Raffles
Three tiers:
- **Daily Raffle** — Smaller prizes, easy entry
- **Weekly Raffle** — Medium prizes, more tasks
- **Monthly Raffle** — Large prizes, many requirements

Entry tasks include: Watch ads, complete offers, invite friends, use spin wheel.

### 4.6 Store
Three sections:
- **Partner Offers** — Discounted deals from partner brands
- **Gift Cards** — Amazon, Google Play, Steam, etc. (min 5,000 pts)
- **Cash Out** — Direct cash via PayPal/Crypto (min 50,000 pts)

### 4.7 Referral Network
- 2-level deep referral system
- Level 1: 10% commission on direct referrals' earnings
- Level 2: 5% commission on indirect referrals' earnings (unlock at 3 invites)
- Collection requires watching 1 ad per level
- Viral share includes referral code + download link
- Leaderboard showing top earners for social proof

### 4.8 Offerwall
Three categories:
- **Games** — Install & reach level X
- **Tasks** — Sign up for services, complete registrations
- **Surveys** — Fill out surveys for points

### 4.9 Rank System
- Lifetime points determine rank
- Higher ranks unlock: more spins, session bonuses
- Rank-up triggers celebration overlay
- Rank badge displayed on home screen

---

## 5. Navigation Structure

### 5 Bottom Tabs

| # | Tab | Icon | Screen |
|---|-----|------|--------|
| 1 | Home | `home_rounded` | Dashboard, accumulation, daily goals, earn more |
| 2 | Raffles | `emoji_events_rounded` | Raffle list with entry tasks |
| 3 | Store | `storefront_rounded` | Partner offers, gift cards, cash out |
| 4 | Network | `people_rounded` | Referral program, levels, leaderboard |
| 5 | Profile | `person_rounded` | Stats, streak multiplier, settings, history |

### Sub-Screens (push navigation)

| Screen | Accessed From |
|--------|--------------|
| Spin Wheel | Home → Spin & Win card |
| Streak Detail | Home → Streak banner / Profile |
| Games Screen | Home → Earn More → Games |
| Tasks Screen | Home → Earn More → Tasks |
| Surveys Screen | Home → Earn More → Surveys |
| Offer Detail | Games/Tasks/Surveys → offer tap |
| Gift Card Detail | Store → Gift Cards → card tap |
| My Cards | Store → Gift Cards → "My Cards" |
| Cash Out History | Store → Cash Out → "History" |
| Transaction History | Profile → "History" |
| Edit Profile | Profile → Edit |
| Notifications Settings | Profile → Settings → Notifications |
| Help | Profile → Settings → Help |
| About | Profile → Settings → About |
| Winners History | Raffles → "Past Winners" |

---

## 6. Data Models

### UserModel
```dart
- id: String
- username: String
- displayName: String
- avatarUrl: String?
- referralCode: String
- directInvites: int
- joinedAt: DateTime
- totalPointsEarned: int
- authProvider: String?
```

### WalletModel
```dart
- totalPoints: int
- pendingPoints: int
- todayEarned: int
- ledger: List<TransactionEntry>
```

### TransactionEntry
```dart
- id: String
- description: String
- points: int (positive=earn, negative=spend)
- timestamp: DateTime
- type: TransactionType (screenTimeClaim | spinWheel | offerwall | referral | rafflePrize | giftCardPurchase | cashOut)
```

### ScreenTimeModel
```dart
- accumulatedMinutes: int
- accumulatedPoints: int
- isCapped: bool
- lastTrackingStart: DateTime?
- lastClaimTime: DateTime?
```

### StreakModel
```dart
- currentStreak: int
- longestStreak: int
- lastClaimDate: DateTime?
- freezesOwned: int
- freezeActiveToday: bool
- claimHistory: List<DateTime>  // last 30 days
- streakAtRisk: bool
- streakLostDate: DateTime?
```

### RankModel
```dart
- totalPointsEarned: int
- computed: currentRank, nextRank, progressToNextRank, pointsToNextRank
```

### DailyGoal
```dart
- id: String
- title: String
- subtitle: String
- icon: IconData
- type: DailyGoalType (claimSession | spinWheel | enterRaffle | watchAds)
- targetCount: int
- currentCount: int
- bonusPoints: int
```

### DailyGoalsState
```dart
- goals: List<DailyGoal>
- dailyBonusClaimed: bool
- date: DateTime
```

### RaffleModel
```dart
- id: String
- title: String
- description: String
- prizeDescription: String
- prizePoints: int
- type: RaffleType (daily | weekly | monthly)
- endDate: DateTime
- isEntered: bool
- entryTasks: List<RaffleEntryTask>
```

### ReferralLevelModel
```dart
- level: int
- commissionPercent: double
- activeUsers: int
- pendingPoints: int
- totalCollected: int
- isUnlocked: bool
- requiredInvites: int
```

### GiftCardModel
```dart
- id, brand, description, imageUrl
- costInPoints: int
- denominations: List<int>
- category: String
```

### OfferwallItemModel
```dart
- id, title, description, imageUrl, providerName
- rewardPoints: int
- type: OfferType
- status: OfferStatus
- requirements: String
- estimatedTime: String
```

### CashOutRequest
```dart
- id, amount (points), method, status, createdAt
```

---

## 7. Services & Infrastructure

### Current Services (Frontend Mock)

| Service | File | Purpose | Status |
|---------|------|---------|--------|
| `AdService` | `ad_service.dart` | Rewarded ad display | **MOCK** — auto-rewards after 800ms delay |
| `BackendService` | `backend_service.dart` | API stubs for all server calls | **MOCK** — returns `true` after delay |
| `ScreenTimeService` | `screen_time_service.dart` | Screen time tracking via timer | **MOCK** — simulated accumulation |
| `StorageService` | `storage_service.dart` | Local persistence (SharedPreferences) | **Working** — stores streak, spin, settings |
| `NotificationService` | `notification_service.dart` | Push notification templates & scheduling | **Templates only** — no actual push yet |
| `CelebrationService` | `celebration_service.dart` | Full-screen celebration overlays | **Working** — confetti, animations, haptics |
| `OfferwallService` | `offerwall_service.dart` | Offerwall data generation | **MOCK** — static data |

### State Management (Riverpod)

All state is managed via Riverpod providers in `lib/shared/providers/app_providers.dart`:

| Provider | Type | Purpose |
|----------|------|---------|
| `authProvider` | `StateProvider<bool>` | Auth state |
| `currentTabProvider` | `StateProvider<int>` | Active bottom tab |
| `onboardingCompleteProvider` | `StateProvider<bool>` | Onboarding flag |
| `userProvider` | `StateNotifierProvider` | User profile + rank tracking |
| `walletProvider` | `StateNotifierProvider` | Balance, transactions |
| `streakProvider` | `StateNotifierProvider` | Streak state + freeze logic |
| `screenTimeProvider` | `StateNotifierProvider` | Accumulation state |
| `rafflesProvider` | `StateNotifierProvider` | Raffle list + task completion |
| `referralLevelsProvider` | `StateNotifierProvider` | Referral network levels |
| `giftCardsProvider` | `StateProvider` | Gift card catalog |
| `redeemedCardsProvider` | `StateNotifierProvider` | Redeemed gift cards |
| `partnerOffersProvider` | `StateProvider` | Store partner offers |
| `offerwallProvider` | `StateNotifierProvider` | Offerwall items |
| `cashOutRequestsProvider` | `StateNotifierProvider` | Cash out history |
| `spinsRemainingProvider` | `StateProvider<int>` | Daily spins left |
| `spinResultProvider` | `StateProvider<int?>` | Last spin result |
| `dailyGoalsProvider` | `StateNotifierProvider` | Daily goals state |
| `rankProvider` | `StateProvider` | Current rank |

---

## 8. Backend Requirements (TODO)

### 8.1 Authentication
- [ ] Firebase Auth or Supabase Auth
- [ ] Apple Sign In, Google Sign In, Email/Password
- [ ] JWT token management
- [ ] User profile creation on first sign-in
- [ ] Referral code validation on sign-up

### 8.2 Database Schema (Firestore / Supabase)

#### `users` collection
```
- uid: String (auth ID)
- username: String (unique)
- displayName: String
- avatarUrl: String?
- referralCode: String (generated, 6 chars)
- referredBy: String? (referral code of inviter)
- directInvites: int
- totalPointsEarned: int
- currentRank: String
- createdAt: Timestamp
- lastActiveAt: Timestamp
- authProvider: String
```

#### `wallets` collection
```
- userId: String
- totalPoints: int
- todayEarned: int
- lastResetDate: Date
```

#### `transactions` collection
```
- userId: String
- type: String (enum)
- points: int
- description: String
- createdAt: Timestamp
- metadata: Map (adId, raffleId, etc.)
```

#### `streaks` collection
```
- userId: String
- currentStreak: int
- longestStreak: int
- lastClaimDate: Timestamp?
- freezesOwned: int
- freezeActiveToday: bool
- claimHistory: List<Date>
- streakLostDate: Timestamp?
```

#### `daily_goals` collection
```
- userId: String
- date: Date
- goals: List<{id, currentCount, completed}>
- bonusClaimed: bool
```

#### `raffles` collection
```
- id: String
- title, description, prizeDescription
- prizePoints: int
- type: String (daily/weekly/monthly)
- startDate, endDate: Timestamp
- winnerId: String?
```

#### `raffle_entries` collection
```
- raffleId: String
- userId: String
- completedTasks: List<String>
- enteredAt: Timestamp
```

#### `referral_earnings` collection
```
- userId: String
- fromUserId: String
- level: int (1 or 2)
- points: int
- claimed: bool
- createdAt: Timestamp
```

#### `gift_card_redemptions` collection
```
- userId: String
- cardId: String
- costInPoints: int
- code: String (gift card code)
- status: String
- createdAt: Timestamp
```

#### `cash_out_requests` collection
```
- userId: String
- amount: int (points)
- method: String
- status: String (pending/processing/completed/failed)
- createdAt, processedAt: Timestamp
```

### 8.3 API Endpoints (REST or Cloud Functions)

#### Auth
```
POST /auth/signup          — Create account + validate referral code
POST /auth/signin          — Sign in
POST /auth/signout         — Sign out
```

#### Screen Time
```
POST /screentime/claim     — Validate + claim accumulated points (requires ad verification)
GET  /screentime/status    — Get current accumulation state
```

#### Wallet
```
GET  /wallet               — Get balance + recent transactions
GET  /wallet/history       — Paginated transaction history
```

#### Streak
```
GET  /streak               — Get current streak state
POST /streak/freeze/buy    — Buy a streak freeze
POST /streak/freeze/use    — Activate streak freeze
POST /streak/recover       — Recover lost streak (requires ad verification × 3)
```

#### Spin Wheel
```
POST /spin                 — Spin wheel (requires ad verification)
GET  /spin/status          — Spins remaining today
```

#### Raffles
```
GET  /raffles              — List active raffles
POST /raffles/:id/task     — Complete a raffle task
POST /raffles/:id/enter    — Enter raffle (if all tasks complete)
GET  /raffles/winners      — Past winners
```

#### Referral
```
GET  /referral/levels      — Get referral level stats
POST /referral/collect/:level — Collect pending points (requires ad verification)
GET  /referral/link        — Get shareable referral link
```

#### Store
```
GET  /store/giftcards      — Gift card catalog
POST /store/redeem/:id     — Redeem gift card
GET  /store/my-cards       — User's redeemed cards
POST /store/cashout        — Request cash out
GET  /store/cashout/history — Cash out request history
```

#### Offerwall
```
GET  /offerwall            — Available offers
POST /offerwall/:id/start  — Track offer start
POST /offerwall/:id/complete — Mark offer complete (webhook from provider)
```

#### Daily Goals
```
GET  /goals/today          — Get today's goals with progress
POST /goals/claim-bonus    — Claim daily goal bonus
```

### 8.4 Ad Verification (CRITICAL)

**All point-earning actions must be server-validated:**

1. Client shows rewarded ad via AdMob SDK
2. AdMob sends server-to-server (S2S) callback to backend
3. Backend validates the callback signature
4. Backend credits points to user wallet
5. Client receives confirmation

**Never trust the client for point calculations.**

```
AdMob S2S Callback URL:
https://api.doomscroll.app/admob/callback?user_id={USER_ID}&reward_type={TYPE}&amount={AMOUNT}&signature={SIGNATURE}
```

### 8.5 Anti-Fraud / Anti-Cheat

- [ ] Rate limiting on all earning endpoints
- [ ] AdMob S2S verification for every rewarded ad
- [ ] Screen time verification via Android UsageStatsManager
- [ ] Anomaly detection (too many points in short time)
- [ ] Device fingerprinting to prevent multi-accounting
- [ ] IP-based fraud detection
- [ ] Minimum withdrawal hold period (72h)
- [ ] Manual review for cash-outs > $50

### 8.6 Cloud Functions / Background Jobs

- [ ] **Daily reset** (midnight UTC): Reset daily goals, spin count, today earnings
- [ ] **Raffle drawing**: Select random winner at raffle end time
- [ ] **Streak check**: At midnight, check if user claimed today; if not, break streak or use freeze
- [ ] **Notification scheduler**: Queue daily push notifications per user
- [ ] **Referral commission calculation**: On each point earn, calculate commissions
- [ ] **Rank recalculation**: On point change, check for rank up

---

## 9. Frontend Architecture

### Tech Stack

| Technology | Version | Purpose |
|-----------|---------|---------|
| Flutter | SDK ^3.11.0 | Cross-platform UI |
| Dart | ^3.11.0 | Language |
| flutter_riverpod | ^2.4.9 | State management |
| google_fonts | ^6.1.0 | Typography (Inter) |
| flutter_animate | ^4.3.0 | Animations |
| google_mobile_ads | ^5.3.0 | AdMob integration |
| shared_preferences | ^2.3.0 | Local storage |
| share_plus | ^10.0.0 | Social sharing |
| confetti | ^0.7.0 | Celebration effects |
| percent_indicator | ^4.2.3 | Progress rings |
| intl | ^0.19.0 | Date formatting |
| url_launcher | ^6.3.0 | External links |
| shimmer | ^3.0.0 | Loading skeletons |
| cached_network_image | ^3.3.1 | Image caching |
| flutter_staggered_animations | ^1.1.1 | List animations |

### Project Structure

```
lib/
├── main.dart                           # Entry point
├── app.dart                            # MaterialApp + routing
├── core/
│   ├── constants/
│   │   ├── app_constants.dart          # App-wide constants
│   │   └── economy_constants.dart      # All economy values
│   └── utils/
│       └── formatters.dart             # Number/date formatters
├── design_system/
│   ├── colors/app_colors.dart          # Color palette (dark theme)
│   ├── typography/app_typography.dart   # Text styles
│   ├── theme/app_theme.dart            # ThemeData
│   ├── utils/
│   │   ├── app_bottom_sheet.dart       # Bottom sheet helper
│   │   └── app_page_route.dart         # Custom page transitions
│   └── widgets/
│       ├── app_card.dart
│       ├── app_toast.dart              # Toast notifications
│       ├── coin_badge.dart             # Points badge widget
│       ├── glass_card.dart             # Glassmorphism card
│       ├── gradient_background.dart    # Animated gradient bg
│       ├── primary_button.dart         # Primary CTA button
│       ├── result_sheet.dart           # Result bottom sheet
│       ├── section_header.dart         # Section title + action
│       ├── shimmer_placeholder.dart    # Loading placeholder
│       └── surface_card.dart           # Surface-level card
├── features/
│   ├── auth/auth_screen.dart           # Login/signup
│   ├── onboarding/onboarding_screen.dart # 6-step onboarding
│   ├── shell/app_shell.dart            # Bottom nav + tab switching
│   ├── home/home_screen.dart           # Main dashboard
│   ├── raffles/
│   │   ├── raffles_screen.dart         # Raffle list
│   │   └── winners_history_screen.dart # Past winners
│   ├── store/
│   │   ├── store_screen.dart           # Store tabs
│   │   ├── my_cards_screen.dart        # Redeemed cards
│   │   └── cash_out_history_screen.dart
│   ├── network/network_screen.dart     # Referral program
│   ├── profile/
│   │   ├── profile_screen.dart         # User profile + stats
│   │   ├── edit_profile_screen.dart
│   │   └── transaction_history_screen.dart
│   ├── spin_wheel/spin_wheel_screen.dart # Spin wheel game
│   ├── streak/streak_detail_screen.dart  # Streak calendar + freeze
│   ├── earn/
│   │   ├── games_screen.dart           # Game offers
│   │   ├── tasks_screen.dart           # Task offers
│   │   ├── surveys_screen.dart         # Survey offers
│   │   └── offer_detail_screen.dart    # Individual offer detail
│   └── settings/
│       ├── notifications_screen.dart   # Push notification settings
│       ├── help_screen.dart
│       └── about_screen.dart
├── models/                             # All data models (see section 6)
├── mock_data/mock_data.dart            # Mock data for prototyping
├── services/                           # All services (see section 7)
└── shared/
    └── providers/app_providers.dart    # All Riverpod providers
```

### Design System

**Theme:** Dark-only (background: `#09090B`)

**Color Palette:**
- Primary: `#A78BFA` (violet)
- Accent: `#67E8F9` (cyan)
- Success: `#34D399` (green)
- Warning: `#FBBF24` (amber)
- Error: `#F87171` (red)
- Points: `#FFD700` (gold)

**Typography:** Google Fonts Inter

**Key UI Patterns:**
- Glass cards with subtle border and blur
- Surface cards with dark backgrounds
- Gradient backgrounds with animated meshes
- Haptic feedback on all interactive elements
- Shimmer loading skeletons
- Pull-to-refresh on all list screens
- Toast notifications for feedback
- Full-screen celebration overlays

---

## 10. Push Notifications Strategy

### Channels

| Channel | Priority | When |
|---------|----------|------|
| Streak Alerts | CRITICAL | 8 PM if not claimed today |
| Points Ready | Medium | 2 PM when points accumulated |
| Daily Goals | Medium | 5 PM if goals incomplete |
| Raffles | Medium | Before raffle ends / new raffle |
| Network | Low–High | Referral joins, earnings pending |
| Milestones | High | Near rank up, streak milestone |
| Re-engagement | High | Day 1, 3, 7 of inactivity |
| Morning Motivation | Low | 9 AM daily |

### Daily Schedule (per user)

| Time | Notification |
|------|-------------|
| 9:00 AM | Morning motivation ("New day, new rewards!") |
| 2:00 PM | Points ready ("2,000 points waiting!") |
| 5:00 PM | Daily goals reminder ("1 goal left!") |
| 6:00 PM | Referral earnings ("500 points pending!") |
| 8:00 PM | **STREAK PROTECTION** ("Your 14-day streak is at risk!") |

### Re-engagement Sequence

| Day | Message |
|-----|---------|
| Day 1 | "We miss you! Your points are waiting" |
| Day 3 | "Free spin waiting for you! 🎡" |
| Day 7 | "Your friends are earning without you 😢" |

### Template Rotation
All notifications use randomized templates to avoid banner blindness. Each notification type has 2–3 copy variants.

---

## 11. Celebration & Dopamine System

### Celebration Types

| Event | Animation | Duration |
|-------|-----------|----------|
| Points Claimed | Checkmark + confetti + counter | 2.5s auto-dismiss |
| Streak Milestone (day 5, 10, 15...) | Full-screen fire icon + confetti | Tap to dismiss |
| Rank Up | Full-screen emoji + rank name + perks | Tap to dismiss |
| Daily Goals Complete | Star badge + confetti | 3s auto-dismiss |
| Spin Wheel Big Win (≥500) | Extended confetti | Included in spin animation |
| Mystery Box | Suspenseful reveal | Tap to open |

### Haptic Feedback Map

| Action | Haptic Type |
|--------|------------|
| Button tap | `mediumImpact` |
| Selection change | `selectionClick` |
| Points claimed | `heavyImpact` |
| Big win / milestone | `heavyImpact` |
| Tab switch | `lightImpact` |
| Error | `heavyImpact` |

---

## 12. Production Checklist (Play Market)

### Pre-Release

#### Backend
- [ ] Set up Firebase/Supabase project
- [ ] Implement all API endpoints (section 8.3)
- [ ] Set up AdMob S2S callback verification
- [ ] Implement anti-fraud measures (section 8.5)
- [ ] Set up Cloud Functions for daily resets
- [ ] Implement raffle drawing logic
- [ ] Set up referral commission calculation
- [ ] Implement gift card delivery (partner API integration)
- [ ] Set up cash out processing (PayPal/Crypto API)
- [ ] Load testing (100k+ concurrent users)
- [ ] Set up monitoring & alerting

#### Frontend
- [ ] Replace all mock services with real API calls
- [ ] Replace `AdService` mock with real AdMob SDK integration
- [ ] Implement `google_mobile_ads` rewarded ad loading + display
- [ ] Add proper error handling for all API calls (retry, offline, timeout)
- [ ] Add connectivity monitoring (show offline banner)
- [ ] Implement real Screen Time tracking (Android `UsageStatsManager`)
- [ ] Request `PACKAGE_USAGE_STATS` permission
- [ ] Implement real push notifications (Firebase Cloud Messaging)
- [ ] Request notification permission (Android 13+)
- [ ] Add `flutter_local_notifications` for scheduled local notifications
- [ ] Implement deep linking for referral URLs
- [ ] Implement Firebase Auth (Google, Apple, Email)
- [ ] Add proper loading states for all API calls
- [ ] Add pull-to-refresh on all data screens
- [ ] Implement pagination for transaction history, winners, offers
- [ ] Add analytics tracking (Firebase Analytics / Mixpanel)
- [ ] Add crash reporting (Firebase Crashlytics / Sentry)
- [ ] Remove/hide dev controls in release builds
- [ ] Implement proper image caching for gift cards, offers
- [ ] Test on various screen sizes (phones + tablets)
- [ ] Test on Android 10, 11, 12, 13, 14, 15
- [ ] Optimize app size (tree-shaking, deferred components)
- [ ] Add splash screen (native Android)
- [ ] Set up proper app icons and adaptive icons

#### Play Market Submission
- [ ] App title: "DoomScroll — Earn Rewards for Screen Time"
- [ ] Short description (80 chars)
- [ ] Full description (4000 chars)
- [ ] Feature graphic (1024×500)
- [ ] Screenshots (min 2, recommended 8)
- [ ] App icon (512×512)
- [ ] Privacy policy URL
- [ ] Terms of service URL
- [ ] Data safety form
- [ ] Content rating questionnaire
- [ ] Target audience declaration (NOT for children under 13)
- [ ] Ads declaration (app contains ads)
- [ ] In-app purchases declaration (none — all free)
- [ ] Set up signing key (upload key + app signing key)
- [ ] Configure release track (internal → closed beta → open beta → production)
- [ ] Set up staged rollout (start with 5%)

#### Legal & Compliance
- [ ] Privacy policy covering:
  - Screen time data collection
  - Ad data (AdMob)
  - User profile data
  - Referral data
  - Analytics data
- [ ] Terms of service covering:
  - Points have no cash value until redeemed
  - Company can modify economy at any time
  - Anti-fraud policy (account termination)
  - Cash out processing times
  - Raffle rules and odds
- [ ] GDPR compliance (for EU users)
  - Data export
  - Data deletion
  - Consent management
- [ ] COPPA compliance (age gate or 13+ only)

#### Post-Launch
- [ ] Monitor D1/D7/D30 retention
- [ ] A/B test notification copy
- [ ] A/B test onboarding flow
- [ ] Monitor ad fill rate and eCPM
- [ ] Track daily active users (DAU) and ads per DAU
- [ ] Monitor reward pool vs revenue (ensure 40% margin)
- [ ] Set up user feedback channel
- [ ] Plan v2.1 features: achievements, leaderboards, social feed

---

## Appendix: Key Files Quick Reference

| File | What's In It |
|------|-------------|
| `economy_constants.dart` | All economy values, tiers, prizes |
| `app_providers.dart` | All Riverpod state providers and notifiers |
| `mock_data.dart` | All mock data for prototype |
| `ad_service.dart` | Mock ad service (replace for production) |
| `backend_service.dart` | Mock API stubs (replace for production) |
| `notification_service.dart` | Notification templates and scheduling |
| `celebration_service.dart` | Full-screen celebration overlays |
| `screen_time_service.dart` | Screen time tracking simulation |
| `storage_service.dart` | Local persistence (SharedPreferences) |
