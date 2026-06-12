# CardVerse

CardVerse is a Flutter card games hub with offline games, persistent local
progress, and real-time multiplayer room infrastructure. Players can compete
against computer opponents, earn rewards, unlock achievements, review match
history, and create synchronized Socket.IO rooms with live chat and ready
states.

## Features

- Branded splash screen and guided onboarding experience
- Onboarding completion saved locally
- Multiple validated local accounts, login, and guest access
- Locally hashed passwords and persistent player identity
- Profile logout with confirmation while preserving account progress
- Responsive home dashboard with player progress summary
- Computer game catalog with available and coming-soon titles
- Playable High Card game against a computer opponent
- Playable War game with card ownership, battles, repeated wars, and win tracking
- Playable Blackjack with dealer rules, Ace-aware scoring, betting, and chips
- Real online High Card matches for 2 to 4 players and bots
- Server-owned deck, card draws, round scoring, match results, and rematches
- Configurable 3, 5, or 10-round online High Card rooms
- Real online War matches for 2 to 4 players and bots
- Server-owned War decks, battle piles, recursive ties, eliminations, and rematches
- Classic and Quick War modes with optional 25, 50, or 100-battle limits
- Real online Blackjack tables for 2 to 4 players and bots
- Server-owned Blackjack deck, dealer logic, hand scoring, bets, chips, and payouts
- Configurable rounds, starting chips, minimum bets, and dealer soft-17 rules
- Shared playing-card model, deck engine, rules, and card widgets
- Persistent profile statistics, coins, XP, levels, and win streaks
- Per-game statistics for High Card, War, and Blackjack
- Match history with game filters and clear-history controls
- Eight unlockable achievements with one-time coin and XP rewards
- Offline leaderboard with overall and per-game filters
- Automatic game-result recording with duplicate-save protection
- Corrupt or missing local data fallback to safe defaults
- Private and public room creation with game, timer, difficulty, chat, and bot settings
- Validated six-character room codes with copy and join flows
- Public room browser with live backend room data and game filters
- Friends list with search, presence status, removal, and room invites
- Local invitation inbox with accept and decline actions
- Real-time multiplayer room lobby with synchronized player slots and ready states
- Live room chat, typing indicators, and system messages through Socket.IO
- Host-controlled bot simulation and synchronized start-game events
- In-memory Node.js room, player, and chat services
- Connection, reconnection, offline-state, and backend-error UI
- Dummy friends and invitation data retained until account APIs are added
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
- Online High Card
- Online War
- Online Blackjack

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
- Node.js and Express
- Socket.IO and `socket_io_client`

## Prerequisites

Install the following before running the project:

- Flutter SDK compatible with Dart `^3.10.8`
- Xcode for macOS and iOS development
- Android Studio and Android SDK for Android development
- Chrome for web development
- Node.js 18 or newer and npm for multiplayer development

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

### Start the Backend

Open a separate Terminal window:

```bash
cd /Users/darpanchelani/Downloads/Softotic/cardverse/backend
npm install
npm run dev
```

The server runs at `http://localhost:5050`. Verify it with:

```bash
curl http://localhost:5050/health
```

CardVerse uses port `5050` by default because macOS AirPlay Receiver commonly
occupies port `5000`.

### Run on macOS

```bash
flutter run -d macos \
  --dart-define=SOCKET_BASE_URL=http://localhost:5050
```

### Run on iOS Simulator

```bash
open -a Simulator
flutter run \
  --dart-define=SOCKET_BASE_URL=http://localhost:5050
```

To target a specific simulator:

```bash
flutter devices
flutter run -d <device-id> \
  --dart-define=SOCKET_BASE_URL=http://localhost:5050
```

### Run on Android

Start an Android emulator from Android Studio or connect a physical device,
then run:

```bash
flutter devices
flutter run -d <device-id> \
  --dart-define=SOCKET_BASE_URL=http://10.0.2.2:5050
```

For a physical Android or iOS device, replace the URL with the Mac's local
network IP, for example `http://192.168.1.20:5050`. The device and Mac must be
on the same network.

### Run in Chrome

```bash
flutter run -d chrome \
  --dart-define=SOCKET_BASE_URL=http://localhost:5050
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
    ├── multiplayer/
    │   ├── controllers/
    │   ├── high_card/
    │   ├── models/
    │   ├── screens/
    │   ├── services/
    │   ├── war/
    │   └── widgets/
    ├── onboarding/
    ├── profile/
    ├── progress/
    ├── rooms/
    └── splash/
```

The Node.js backend lives in `backend/` and contains Express routes, Socket.IO
handlers, in-memory room/chat services, validators, and integration tests.

## Navigation Flow

```text
Splash
  -> Onboarding
  -> Login or Register
  -> Home
     -> Game Selection
     -> Create Room
        -> Room Lobby
           -> Online High Card
           -> Online War
           -> Online Blackjack
     -> Join Room
        -> Room Lobby
     -> Public Rooms
        -> Room Lobby
     -> Friends
     -> Invites
     -> Leaderboard
     -> Profile
        -> Achievements
        -> Match History
     -> Match History
```

Registration saves local accounts on the device. Login accepts any saved email
or username and verifies the password before opening the home screen. Guest
access remains available as a separate action.

## Local Progress

CardVerse stores profile data, game statistics, achievements, match history,
Blackjack chips, leaderboard snapshots, and onboarding status on the device
using `shared_preferences`. Structured records are encoded as JSON.

Each saved account and the Guest profile has isolated coins, XP, game stats,
achievements, match history, leaderboard data, and Blackjack chips.

Local account credentials are device-only. Passwords are stored as SHA-256
hashes, but this is not a replacement for backend authentication.

Game rewards:

- Win: 50 coins and 25 XP
- Loss: 10 coins and 10 XP
- Draw or push: 20 coins and 15 XP

Blackjack betting chips remain separate from profile reward coins.

## Multiplayer

Rooms and chat use the Node.js Socket.IO backend. Active data is kept in server
memory, so restarting the backend clears rooms and messages. The app supports:

- Creating private or public rooms
- Joining rooms by code
- Browsing public rooms
- Synchronized player slots, bots, and readiness across clients
- Inviting local dummy friends
- Accepting or declining dummy invites
- Sending real-time room chat messages
- Playing synchronized High Card matches with backend-controlled card draws
- Tracking shared scores and round history across all connected clients
- Playing synchronized War battles with server-owned decks and battle piles
- Resolving classic or quick ties, eliminations, card counts, and battle limits
- Playing synchronized Blackjack rounds against a server-controlled dealer
- Placing bets, hitting, standing, resolving payouts, and requesting rematches
- Requesting a rematch after all human players accept

Friends and invites still use local dummy data. Authentication remains
device-local. No Firebase or database is used.

Online High Card rewards are saved to local progress:

- Win: 100 coins and 50 XP
- Loss: 25 coins and 20 XP
- Draw: 40 coins and 30 XP

Online War rewards are saved to local progress:

- Win: 150 coins and 75 XP
- Loss: 35 coins and 25 XP
- Draw: 60 coins and 40 XP

Online Blackjack rewards are saved to local progress:

- Win: 200 coins and 100 XP
- Loss: 50 coins and 35 XP
- Draw: 80 coins and 50 XP

### Test With Multiple Clients

1. Start the backend.
2. Run CardVerse on two emulators, simulators, devices, or browser origins.
3. Create a room on the first client.
4. Join with the six-character code on the second client.
5. Toggle ready and start from the host client.
6. For High Card, draw synchronized cards and complete the configured rounds.
7. For War, run synchronized battles and resolve ties until the match ends.
8. For Blackjack, place bets, hit or stand, and complete the configured rounds.
9. Request a rematch from both clients.

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

The app supports offline play, local progress, and real-time room/lobby
synchronization. The following systems are intentionally not included:

- Server-backed authentication and synchronized user accounts
- Backend APIs and cloud synchronization
- Firebase integration
- Database persistence for server rooms and chat
- Playable sessions for the remaining card games

Leaderboard opponents, friends, and invites use local sample data. Profile
rewards, statistics, achievements, and match history are persistent local
records. Active rooms, public room listings, readiness, bots, start events, and
chat are synchronized through the Socket.IO backend. Online High Card, War,
and Blackjack use server-owned game state and remain in memory until the
backend restarts.
