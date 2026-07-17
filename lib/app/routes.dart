import 'package:cardverse/features/auth/login_screen.dart';
import 'package:cardverse/core/widgets/app_navigation.dart';
import 'package:cardverse/features/games/blackjack/blackjack_screen.dart';
import 'package:cardverse/features/games/game_selection_screen.dart';
import 'package:cardverse/features/games/high_card/high_card_screen.dart';
import 'package:cardverse/features/games/war/war_screen.dart';
import 'package:cardverse/features/history/match_history_screen.dart';
import 'package:cardverse/features/home/home_screen.dart';
import 'package:cardverse/features/leaderboard/leaderboard_screen.dart';
import 'package:cardverse/features/multiplayer/screens/friends_screen.dart';
import 'package:cardverse/features/friends/screens/friend_requests_screen.dart';
import 'package:cardverse/features/friends/screens/user_search_screen.dart';
import 'package:cardverse/features/multiplayer/screens/invites_screen.dart';
import 'package:cardverse/features/multiplayer/screens/multiplayer_game_placeholder_screen.dart';
import 'package:cardverse/features/multiplayer/screens/public_rooms_screen.dart';
import 'package:cardverse/features/multiplayer/screens/room_lobby_screen.dart';
import 'package:cardverse/features/multiplayer/high_card/screens/high_card_multiplayer_screen.dart';
import 'package:cardverse/features/multiplayer/war/screens/war_multiplayer_screen.dart';
import 'package:cardverse/features/multiplayer/blackjack/screens/blackjack_multiplayer_screen.dart';
import 'package:cardverse/features/onboarding/onboarding_screen.dart';
import 'package:cardverse/features/profile/profile_screen.dart';
import 'package:cardverse/features/progress/achievements_screen.dart';
import 'package:cardverse/features/rooms/create_room_screen.dart';
import 'package:cardverse/features/rooms/join_room_screen.dart';
import 'package:cardverse/features/splash/splash_screen.dart';
import 'package:cardverse/features/notifications/screens/notifications_screen.dart';
import 'package:cardverse/features/customization/screens/customization_screen.dart';
import 'package:cardverse/features/settings/screens/account_settings_screen.dart';
import 'package:cardverse/features/settings/screens/app_settings_screen.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const home = '/home';
  static const games = '/games';
  static const highCard = '/high-card';
  static const war = '/war';
  static const blackjack = '/blackjack';
  static const createRoom = '/create-room';
  static const joinRoom = '/join-room';
  static const publicRooms = '/public-rooms';
  static const friends = '/friends';
  static const friendRequests = '/friend-requests';
  static const userSearch = '/user-search';
  static const invites = '/invites';
  static const roomLobby = '/room-lobby';
  static const multiplayerPlaceholder = '/multiplayer-placeholder';
  static const multiplayerHighCard = '/multiplayer/high-card';
  static const multiplayerWar = '/multiplayer/war';
  static const multiplayerBlackjack = '/multiplayer/blackjack';
  static const leaderboard = '/leaderboard';
  static const profile = '/profile';
  static const matchHistory = '/match-history';
  static const achievements = '/achievements';
  static const notifications = '/notifications';
  static const customization = '/customization';
  static const accountSettings = '/account-settings';
  static const appSettings = '/app-settings';

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      StatefulShellRoute(
        builder: (context, state, navigationShell) =>
            CardVerseNavigationShell(navigationShell: navigationShell),
        navigatorContainerBuilder: (context, navigationShell, children) =>
            CardVerseBranchContainer(
              currentIndex: navigationShell.currentIndex,
              children: children,
            ),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: home,
                builder: (context, state) => const HomeScreen(embedded: true),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '$games/computer',
                builder: (context, state) =>
                    const GameSelectionScreen(mode: 'computer', embedded: true),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: friends,
                builder: (context, state) =>
                    const FriendsScreen(embedded: true),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: leaderboard,
                builder: (context, state) =>
                    const LeaderboardScreen(embedded: true),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: profile,
                builder: (context, state) =>
                    const ProfileScreen(embedded: true),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: highCard,
        builder: (context, state) => const HighCardScreen(),
      ),
      GoRoute(path: war, builder: (context, state) => const WarScreen()),
      GoRoute(
        path: blackjack,
        builder: (context, state) => const BlackjackScreen(),
      ),
      GoRoute(
        path: createRoom,
        builder: (context, state) => const CreateRoomScreen(),
      ),
      GoRoute(
        path: joinRoom,
        builder: (context, state) => const JoinRoomScreen(),
      ),
      GoRoute(
        path: '/rooms/create',
        builder: (context, state) => const CreateRoomScreen(),
      ),
      GoRoute(
        path: '/rooms/join',
        builder: (context, state) => const JoinRoomScreen(),
      ),
      GoRoute(
        path: publicRooms,
        builder: (context, state) => const PublicRoomsScreen(),
      ),
      GoRoute(
        path: friendRequests,
        builder: (context, state) => const FriendRequestsScreen(),
      ),
      GoRoute(
        path: userSearch,
        builder: (context, state) => const UserSearchScreen(),
      ),
      GoRoute(
        path: invites,
        builder: (context, state) => const InvitesScreen(),
      ),
      GoRoute(
        path: '$roomLobby/:roomCode',
        builder: (context, state) =>
            RoomLobbyScreen(roomCode: state.pathParameters['roomCode'] ?? ''),
      ),
      GoRoute(
        path: '$multiplayerPlaceholder/:roomCode',
        builder: (context, state) => MultiplayerGamePlaceholderScreen(
          roomCode: state.pathParameters['roomCode'] ?? '',
        ),
      ),
      GoRoute(
        path: '$multiplayerHighCard/:roomCode',
        builder: (context, state) => HighCardMultiplayerScreen(
          roomCode: state.pathParameters['roomCode'] ?? '',
        ),
      ),
      GoRoute(
        path: '$multiplayerWar/:roomCode',
        builder: (context, state) => WarMultiplayerScreen(
          roomCode: state.pathParameters['roomCode'] ?? '',
        ),
      ),
      GoRoute(
        path: '$multiplayerBlackjack/:roomCode',
        builder: (context, state) => BlackjackMultiplayerScreen(
          roomCode: state.pathParameters['roomCode'] ?? '',
        ),
      ),
      GoRoute(
        path: matchHistory,
        builder: (context, state) => const MatchHistoryScreen(),
      ),
      GoRoute(
        path: achievements,
        builder: (context, state) => const AchievementsScreen(),
      ),
      GoRoute(
        path: notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: customization,
        builder: (context, state) => const CustomizationScreen(),
      ),
      GoRoute(
        path: accountSettings,
        builder: (context, state) => const AccountSettingsScreen(),
      ),
      GoRoute(
        path: appSettings,
        builder: (context, state) => const AppSettingsScreen(),
      ),
    ],
  );
}
