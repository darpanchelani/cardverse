import 'package:cardverse/app/app.dart';
import 'package:cardverse/core/network/api_client.dart';
import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/core/storage/secure_storage_service.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/auth/services/auth_api_service.dart';
import 'package:cardverse/features/profile/services/profile_api_service.dart';
import 'package:cardverse/features/friends/services/friends_api_service.dart';
import 'package:cardverse/features/history/services/match_history_api_service.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/progress/services/achievement_service.dart';
import 'package:cardverse/features/progress/services/leaderboard_service.dart';
import 'package:cardverse/features/progress/services/progress_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await LocalStorageService.create();
  final secureStorage = SecureStorageService();
  final apiClient = ApiClient(tokenProvider: secureStorage.getToken);
  ApiClient.globalInstance = apiClient;
  final authController = AuthController(
    authService: AuthApiService(apiClient),
    profileService: ProfileApiService(apiClient),
    secureStorage: secureStorage,
    localStorage: storage,
  );
  await authController.initializeAuth();
  final activeAccountId = authController.isAuthenticated
      ? authController.user!.id
      : 'guest';
  await storage.useAccount(activeAccountId);
  final controller = ProgressController(
    progressService: ProgressService(storage),
    achievementService: AchievementService(storage),
    leaderboardService: LeaderboardService(storage),
  );
  ProgressController.globalInstance = controller;
  await controller.initialize();
  if (authController.isAuthenticated &&
      controller.profile.username != authController.user!.username) {
    await controller.updateUsername(authController.user!.username);
  }
  var multiplayerUserId = await storage.getString(
    StorageKeys.multiplayerUserId,
  );
  if (multiplayerUserId == null) {
    multiplayerUserId =
        'guest_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}';
    await storage.saveString(StorageKeys.multiplayerUserId, multiplayerUserId);
  }
  final multiplayerControllers = MultiplayerControllers.create(
    userId: authController.isAuthenticated
        ? authController.user!.id
        : multiplayerUserId,
    username: authController.identityUsername,
    level: authController.isAuthenticated
        ? authController.identityLevel
        : controller.profile.level,
    token: authController.token,
    progressController: controller,
    friendService: FriendsApiService(apiClient, authController),
    cloudMatchService: MatchHistoryApiService(apiClient, authController),
  );
  runApp(
    CardVerseApp(
      progressController: controller,
      multiplayerControllers: multiplayerControllers,
      authController: authController,
    ),
  );
}
