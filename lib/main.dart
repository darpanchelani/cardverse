import 'package:cardverse/app/app.dart';
import 'package:cardverse/app/app_services_scope.dart';
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
import 'package:cardverse/features/notifications/controllers/notifications_controller.dart';
import 'package:cardverse/features/notifications/services/notifications_api_service.dart';
import 'package:cardverse/features/notifications/services/socket_notifications_service.dart';
import 'package:cardverse/features/invites/controllers/invites_controller.dart';
import 'package:cardverse/features/invites/services/invites_api_service.dart';
import 'package:cardverse/features/invites/services/socket_invites_service.dart';
import 'package:cardverse/features/customization/controllers/customization_controller.dart';
import 'package:cardverse/features/customization/services/themes_api_service.dart';
import 'package:cardverse/features/settings/controllers/settings_controller.dart';
import 'package:cardverse/features/settings/services/settings_api_service.dart';
import 'dart:async';

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
  final appServices = AppServices(
    notifications: NotificationsController(
      api: NotificationsApiService(apiClient),
      socket: SocketNotificationsService(multiplayerControllers.socket),
      auth: authController,
    ),
    invites: InvitesController(
      api: InvitesApiService(apiClient),
      socket: SocketInvitesService(multiplayerControllers.socket),
      auth: authController,
    ),
    customization: CustomizationController(
      service: ThemesApiService(apiClient),
      auth: authController,
    ),
    settings: SettingsController(
      storage: storage,
      api: SettingsApiService(apiClient),
      auth: authController,
    ),
  );
  await appServices.settings.initialize();
  if (authController.isAuthenticated) {
    unawaited(appServices.notifications.loadNotifications());
    unawaited(appServices.invites.loadInvites());
    unawaited(appServices.customization.loadThemes());
    unawaited(multiplayerControllers.connection.connect());
  }
  runApp(
    CardVerseApp(
      progressController: controller,
      multiplayerControllers: multiplayerControllers,
      authController: authController,
      appServices: appServices,
    ),
  );
}
