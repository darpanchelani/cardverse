import 'package:cardverse/app/app.dart';
import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/progress/services/achievement_service.dart';
import 'package:cardverse/features/progress/services/leaderboard_service.dart';
import 'package:cardverse/features/progress/services/progress_service.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = await LocalStorageService.create();
  final controller = ProgressController(
    progressService: ProgressService(storage),
    achievementService: AchievementService(storage),
    leaderboardService: LeaderboardService(storage),
  );
  ProgressController.globalInstance = controller;
  await controller.initialize();
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
  );
  runApp(
    CardVerseApp(
      progressController: controller,
      multiplayerControllers: multiplayerControllers,
    ),
  );
}
