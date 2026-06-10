import 'package:cardverse/app/app.dart';
import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
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
  runApp(CardVerseApp(progressController: controller));
}
