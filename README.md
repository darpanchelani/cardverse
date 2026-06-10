# CardVerse

CardVerse is an offline-first Flutter card games hub with a dark card-table
interface. Players can play classic games against computer opponents, earn
rewards, unlock achievements, build persistent profile statistics, review match
history, and compare their progress on a local leaderboard.

## Features

- Branded splash screen and guided onboarding experience
- Onboarding completion saved locally
- Login, account registration, and guest access
- Responsive home dashboard with player progress summary
- Computer game catalog with available and coming-soon titles
- Playable High Card game against a computer opponent
- Playable War game with card ownership, battles, repeated wars, and win tracking
- Playable Blackjack with dealer rules, Ace-aware scoring, betting, and chips
- Shared playing-card model, deck engine, rules, and card widgets
- Persistent profile statistics, coins, XP, levels, and win streaks
- Per-game statistics for High Card, War, and Blackjack
- Match history with game filters and clear-history controls
- Eight unlockable achievements with one-time coin and XP rewards
- Offline leaderboard with overall and per-game filters
- Automatic game-result recording with duplicate-save protection
- Corrupt or missing local data fallback to safe defaults
- Private room creation with game and player-count options
- Room-code display, copy action, and join-room interface
- Profile reset with confirmation
- Responsive game grid designed for mobile and wider displays
- Reusable buttons, text fields, game cards, colors, and strings
- Dark card-table visual theme with green surfaces and gold accents
- Centralized declarative navigation using `go_router`

## Available Games

Playable:

- High Card
- War
- Blackjack

Coming soon:

- Rummy
- Teen Patti
- Poker
- Crazy Eights
- Bluff
- Spades
- Hearts
- Solitaire

## Tech Stack

- Flutter
- Dart
- Material 3
- `go_router` for navigation
- `shared_preferences` for local JSON persistence

## Prerequisites

Install the following before running the project:

- Flutter SDK compatible with Dart `^3.10.8`
- Xcode for macOS and iOS development
- Android Studio and Android SDK for Android development
- Chrome for web development

Verify your environment:

```bash
flutter doctor
```

On this Mac, Flutter is installed at:

```text
/Users/darpanchelani/flutter/bin/flutter
```

If `flutter` is not available in your terminal, add it to `PATH`:

```bash
echo 'export PATH="$PATH:/Users/darpanchelani/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

## Getting Started

Open Terminal and move into the project:

```bash
cd /Users/darpanchelani/Downloads/Softotic/cardverse
flutter pub get
flutter devices
```

### Run on macOS

```bash
flutter run -d macos
```

### Run on iOS Simulator

```bash
open -a Simulator
flutter run
```

To target a specific simulator:

```bash
flutter devices
flutter run -d <device-id>
```

### Run on Android

Start an Android emulator from Android Studio or connect a physical device,
then run:

```bash
flutter devices
flutter run -d <device-id>
```

### Run in Chrome

```bash
flutter run -d chrome
```

If Flutter has not been added to `PATH`, replace `flutter` in these commands
with:

```text
/Users/darpanchelani/flutter/bin/flutter
```

## Project Structure

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── routes.dart
│   └── theme.dart
├── core/
│   ├── constants/
│   ├── storage/
│   ├── utils/
│   └── widgets/
└── features/
    ├── auth/
    ├── games/
    ├── history/
    ├── home/
    ├── leaderboard/
    ├── onboarding/
    ├── profile/
    ├── progress/
    ├── rooms/
    └── splash/
```

## Navigation Flow

```text
Splash
  -> Onboarding
  -> Login or Register
  -> Home
     -> Game Selection
     -> Create Room
     -> Join Room
     -> Leaderboard
     -> Profile
        -> Achievements
        -> Match History
     -> Match History
```

Login, registration, and guest actions currently navigate directly to the
home screen without validating credentials.

## Local Progress

CardVerse stores profile data, game statistics, achievements, match history,
Blackjack chips, leaderboard snapshots, and onboarding status on the device
using `shared_preferences`. Structured records are encoded as JSON.

Game rewards:

- Win: 50 coins and 25 XP
- Loss: 10 coins and 10 XP
- Draw or push: 20 coins and 15 XP

Blackjack betting chips remain separate from profile reward coins.

## Quality Checks

Format the project:

```bash
dart format lib test
```

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## Implementation Status

The app currently supports offline play and local progress. The following
systems are intentionally not included:

- Real authentication and user accounts
- Backend APIs and cloud synchronization
- Firebase integration
- Playable sessions for the remaining card games
- Online rooms and multiplayer networking

Leaderboard opponents and room codes use local sample data. The current user's
profile, rewards, statistics, achievements, and match history are real local
records created by gameplay.
