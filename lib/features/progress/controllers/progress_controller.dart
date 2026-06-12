import 'dart:async';

import 'package:cardverse/features/progress/models/achievement_model.dart';
import 'package:cardverse/features/progress/models/game_stats_model.dart';
import 'package:cardverse/features/progress/models/leaderboard_entry_model.dart';
import 'package:cardverse/features/progress/models/match_history_model.dart';
import 'package:cardverse/features/progress/models/player_profile_model.dart';
import 'package:cardverse/features/progress/services/achievement_service.dart';
import 'package:cardverse/features/progress/services/leaderboard_service.dart';
import 'package:cardverse/features/progress/services/progress_service.dart';
import 'package:flutter/widgets.dart';

class ProgressController extends ChangeNotifier {
  ProgressController({
    required ProgressService progressService,
    required AchievementService achievementService,
    required LeaderboardService leaderboardService,
  }) : _progressService = progressService,
       _achievementService = achievementService,
       _leaderboardService = leaderboardService;

  static ProgressController? _instance;
  static ProgressController? get maybeInstance => _instance;
  static set globalInstance(ProgressController controller) {
    _instance = controller;
  }

  final ProgressService _progressService;
  final AchievementService _achievementService;
  final LeaderboardService _leaderboardService;
  final Set<String> _recordingIds = {};

  PlayerProfileModel profile = PlayerProfileModel.defaults();
  Map<String, GameStatsModel> gameStats = {
    'high_card': GameStatsModel.empty('high_card'),
    'high_card_online': GameStatsModel.empty('high_card_online'),
    'war': GameStatsModel.empty('war'),
    'blackjack': GameStatsModel.empty('blackjack'),
  };
  List<MatchHistoryModel> matchHistory = [];
  List<AchievementModel> achievements = [];
  List<LeaderboardEntryModel> leaderboard = [];
  bool isLoading = false;
  String? errorMessage;
  String? achievementNotice;

  Future<void> initialize() => refreshProgress();

  Future<void> refreshProgress() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      profile = await _progressService.getProfile();
      gameStats = await _progressService.getAllGameStats();
      matchHistory = await _progressService.getMatchHistory();
      achievements = await _achievementService.getAchievements();
      leaderboard = await _leaderboardService.getLeaderboard(
        profile: profile,
        stats: gameStats,
      );
    } catch (_) {
      errorMessage = 'Could not load local progress.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> recordGameResult({
    required String recordId,
    required String gameType,
    required String gameName,
    required String result,
    required String opponent,
    required int playerScore,
    required int opponentScore,
    required Map<String, dynamic> extraData,
    int durationSeconds = 0,
    int? rewardCoins,
    int? rewardXp,
  }) async {
    if (_recordingIds.contains(recordId) ||
        matchHistory.any((match) => match.id == recordId)) {
      return;
    }
    _recordingIds.add(recordId);
    try {
      final record = await _progressService.recordGameResult(
        gameType: gameType,
        gameName: gameName,
        result: result,
        opponent: opponent,
        playerScore: playerScore,
        opponentScore: opponentScore,
        extraData: extraData,
        matchId: recordId,
        durationSeconds: durationSeconds,
        rewardCoins: rewardCoins,
        rewardXp: rewardXp,
      );
      profile = record.profile;
      gameStats = record.stats;
      matchHistory = [record.match, ...matchHistory];

      final rewardedAchievementIds = {
        for (final item in achievements)
          if (item.isUnlocked) item.id,
      };
      var checked = await _achievementService.checkAndUnlockAchievements(
        profile: profile,
        stats: gameStats,
      );
      final unlockedTitles = <String>[];
      while (true) {
        final newlyUnlocked = checked
            .where(
              (item) =>
                  item.isUnlocked && !rewardedAchievementIds.contains(item.id),
            )
            .toList();
        if (newlyUnlocked.isEmpty) break;

        rewardedAchievementIds.addAll(newlyUnlocked.map((item) => item.id));
        unlockedTitles.addAll(newlyUnlocked.map((item) => item.title));
        final bonusCoins = newlyUnlocked.fold<int>(
          0,
          (sum, item) => sum + item.rewardCoins,
        );
        final bonusXp = newlyUnlocked.fold<int>(
          0,
          (sum, item) => sum + item.rewardXp,
        );
        final xp = profile.xp + bonusXp;
        profile = profile.copyWith(
          coins: profile.coins + bonusCoins,
          xp: xp,
          level: ProgressService.calculateLevel(xp),
          updatedAt: DateTime.now(),
        );
        await _progressService.saveProfile(profile);
        checked = await _achievementService.checkAndUnlockAchievements(
          profile: profile,
          stats: gameStats,
        );
      }
      achievementNotice = unlockedTitles.isEmpty
          ? null
          : unlockedTitles.join(', ');
      achievements = checked;
      leaderboard = await _leaderboardService.getLeaderboard(
        profile: profile,
        stats: gameStats,
      );
      await _leaderboardService.refreshLeaderboard(leaderboard);
      notifyListeners();
    } catch (_) {
      errorMessage = 'Could not save this result.';
      notifyListeners();
    } finally {
      _recordingIds.remove(recordId);
    }
  }

  Future<List<LeaderboardEntryModel>> leaderboardFor(String? gameType) async {
    return _leaderboardService.getLeaderboard(
      gameType: gameType,
      profile: profile,
      stats: gameStats,
    );
  }

  Future<void> clearHistory() async {
    await _progressService.clearMatchHistory();
    matchHistory = [];
    notifyListeners();
  }

  Future<int?> getBlackjackChips() => _progressService.getBlackjackChips();

  Future<void> saveBlackjackChips(int chips) {
    return _progressService.saveBlackjackChips(chips);
  }

  Future<void> clearProgress() async {
    await _progressService.clearProgress();
    achievementNotice = null;
    await refreshProgress();
  }

  void consumeAchievementNotice() {
    achievementNotice = null;
  }
}

class ProgressScope extends InheritedNotifier<ProgressController> {
  const ProgressScope({
    required ProgressController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static ProgressController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<ProgressScope>();
    assert(scope != null, 'ProgressScope is missing above this context.');
    return scope!.notifier!;
  }

  static ProgressController? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ProgressScope>()
        ?.notifier;
  }
}
