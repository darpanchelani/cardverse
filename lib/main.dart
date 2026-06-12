import 'package:cardverse/app/app.dart';
import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/progress/services/achievement_service.dart';
import 'package:cardverse/features/progress/services/leaderboard_service.dart';
import 'package:cardverse/features/progress/services/progress_service.dart';
import 'package:cardverse/features/auth/local_auth_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await LocalStorageService.create();
  final authService = LocalAuthService(storage);
  final activeAccountId =
      await storage.getString(StorageKeys.activeAccountId) ?? 'guest';
  await storage.useAccount(activeAccountId);
  final controller = ProgressController(
    progressService: ProgressService(storage),
    achievementService: AchievementService(storage),
    leaderboardService: LeaderboardService(storage),
  );
  ProgressController.globalInstance = controller;
  await controller.initialize();
  if (activeAccountId != 'guest') {
    final accounts = await authService.getAccounts();
    final activeAccounts = accounts.where(
      (account) => account.id == activeAccountId,
    );
    if (activeAccounts.isNotEmpty &&
        controller.profile.username != activeAccounts.first.username) {
      await controller.updateUsername(activeAccounts.first.username);
    }
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
    userId: multiplayerUserId,
    username: controller.profile.username,
    level: controller.profile.level,
    progressController: controller,
  );
  runApp(
    CardVerseApp(
      progressController: controller,
      multiplayerControllers: multiplayerControllers,
    ),
  );
}
