# CardVerse

CardVerse is a modern card games hub built with Flutter. It brings classic
card games into one mobile-friendly experience where players can explore
games, practice against computer opponents, create private rooms, join
friends, track their profile, and view leaderboard rankings.

The application currently provides the complete interface and navigation
foundation. Gameplay, account services, and online connectivity are represented
by interactive screens and will be connected to production services as the
application develops.

## Features

- Branded splash screen and guided onboarding experience
- Login, account registration, and guest access
- Responsive home dashboard with quick access to every section
- Computer game catalog with available and coming-soon titles
- Private room creation with game and player-count options
- Room-code display, copy action, and join-room interface
- Player leaderboard with rankings and win totals
- Profile dashboard with level, coins, games, wins, losses, and win rate
- Responsive game grid designed for mobile and wider displays
- Reusable buttons, text fields, game cards, colors, and strings
- Dark card-table visual theme with green surfaces and gold accents
- Centralized declarative navigation using `go_router`

## Available Games

Available in the game selection catalog:

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
│   │   ├── app_colors.dart
│   │   └── app_strings.dart
│   └── widgets/
│       ├── custom_button.dart
│       ├── custom_text_field.dart
│       └── game_card.dart
└── features/
    ├── auth/
    ├── games/
    ├── home/
    ├── leaderboard/
    ├── onboarding/
    ├── profile/
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
```

Login, registration, and guest actions currently navigate directly to the
home screen without validating credentials.

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

The current project focuses on the user interface and navigation experience.
The following systems are not connected yet:

- Real authentication and user accounts
- Backend APIs and persistent storage
- Firebase integration
- Computer opponent intelligence
- Card game rules and playable game sessions
- Online rooms and multiplayer networking
- Real leaderboard and profile statistics

User data, leaderboard entries, room codes, and player statistics currently use
sample values to demonstrate the complete application flow.
