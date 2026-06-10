import 'package:cardverse/features/auth/login_screen.dart';
import 'package:cardverse/features/auth/register_screen.dart';
import 'package:cardverse/features/games/game_selection_screen.dart';
import 'package:cardverse/features/games/high_card/high_card_screen.dart';
import 'package:cardverse/features/games/war/war_screen.dart';
import 'package:cardverse/features/home/home_screen.dart';
import 'package:cardverse/features/leaderboard/leaderboard_screen.dart';
import 'package:cardverse/features/onboarding/onboarding_screen.dart';
import 'package:cardverse/features/profile/profile_screen.dart';
import 'package:cardverse/features/rooms/create_room_screen.dart';
import 'package:cardverse/features/rooms/join_room_screen.dart';
import 'package:cardverse/features/splash/splash_screen.dart';
import 'package:go_router/go_router.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const home = '/home';
  static const games = '/games';
  static const highCard = '/high-card';
  static const war = '/war';
  static const createRoom = '/rooms/create';
  static const joinRoom = '/rooms/join';
  static const leaderboard = '/leaderboard';
  static const profile = '/profile';

  static final router = GoRouter(
    initialLocation: splash,
    routes: [
      GoRoute(path: splash, builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(path: home, builder: (context, state) => const HomeScreen()),
      GoRoute(
        path: '$games/:mode',
        builder: (context, state) => GameSelectionScreen(
          mode: state.pathParameters['mode'] ?? 'computer',
        ),
      ),
      GoRoute(
        path: highCard,
        builder: (context, state) => const HighCardScreen(),
      ),
      GoRoute(path: war, builder: (context, state) => const WarScreen()),
      GoRoute(
        path: createRoom,
        builder: (context, state) => const CreateRoomScreen(),
      ),
      GoRoute(
        path: joinRoom,
        builder: (context, state) => const JoinRoomScreen(),
      ),
      GoRoute(
        path: leaderboard,
        builder: (context, state) => const LeaderboardScreen(),
      ),
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfileScreen(),
      ),
    ],
  );
}
