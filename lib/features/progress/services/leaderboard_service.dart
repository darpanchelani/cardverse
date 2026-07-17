import 'dart:convert';

import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/features/progress/models/game_stats_model.dart';
import 'package:cardverse/features/progress/models/leaderboard_entry_model.dart';
import 'package:cardverse/features/progress/models/match_history_model.dart';
import 'package:cardverse/features/progress/models/player_profile_model.dart';

class LeaderboardService {
  LeaderboardService(this._storage);

  final LocalStorageService _storage;

  Future<List<LeaderboardEntryModel>> getLeaderboard({
    String? gameType,
    PlayerProfileModel? profile,
    Map<String, GameStatsModel>? stats,
    List<MatchHistoryModel> matchHistory = const [],
    String period = 'overall',
    String metric = 'wins',
  }) async {
    final currentProfile = profile ?? PlayerProfileModel.defaults();
    final currentStats = stats ?? const {};
    final selectedType = gameType ?? 'overall';
    final selectedStats = currentStats[selectedType];
    final now = DateTime.now();
    final playerStats = _currentPeriodStats(
      period,
      selectedType,
      currentProfile,
      selectedStats,
      matchHistory,
    );

    final entries = [
      _dummy('Darpan', selectedType, 120, 160, 3200, 2600, 8, now, period),
      _dummy('Ali', selectedType, 95, 140, 2500, 2100, 7, now, period),
      _dummy('Sara', selectedType, 80, 125, 2100, 1700, 6, now, period),
      _dummy('Ahmed', selectedType, 60, 105, 1600, 1250, 5, now, period),
      LeaderboardEntryModel(
        username: currentProfile.username,
        gameType: selectedType,
        wins: playerStats.$1,
        totalGames: playerStats.$2,
        winRate: playerStats.$3,
        coins: playerStats.$4,
        xp: playerStats.$5,
        level: currentProfile.level,
        updatedAt: currentProfile.updatedAt,
      ),
    ];
    entries.sort((a, b) {
      final primary = switch (metric) {
        'xp' => b.xp.compareTo(a.xp),
        'coins' => b.coins.compareTo(a.coins),
        'winRate' => b.winRate.compareTo(a.winRate),
        _ => b.wins.compareTo(a.wins),
      };
      if (primary != 0) return primary;
      return b.totalGames.compareTo(a.totalGames);
    });
    return entries;
  }

  Future<void> refreshLeaderboard(List<LeaderboardEntryModel> entries) async {
    await _storage.saveString(
      _storage.scopedKey(StorageKeys.leaderboard),
      jsonEncode(entries.map((entry) => entry.toJson()).toList()),
    );
  }

  LeaderboardEntryModel _dummy(
    String username,
    String gameType,
    int wins,
    int totalGames,
    int coins,
    int xp,
    int level,
    DateTime now,
    String period,
  ) {
    final gameMultiplier = switch (gameType) {
      'high_card' => 0.45,
      'high_card_online' => 0.2,
      'war' => 0.3,
      'war_online' => 0.18,
      'blackjack' => 0.25,
      _ => 1.0,
    };
    final periodMultiplier = switch (period) {
      'daily' => 0.06,
      'weekly' => 0.24,
      _ => 1.0,
    };
    final combinedMultiplier = gameMultiplier * periodMultiplier;
    final filteredWins = (wins * combinedMultiplier).round();
    final filteredGames = (totalGames * combinedMultiplier).round();
    return LeaderboardEntryModel(
      username: username,
      gameType: gameType,
      wins: filteredWins,
      totalGames: filteredGames,
      winRate: filteredGames == 0 ? 0 : filteredWins / filteredGames * 100,
      coins: (coins * periodMultiplier).round(),
      xp: (xp * periodMultiplier).round(),
      level: level,
      updatedAt: now,
    );
  }

  (int, int, double, int, int) _currentPeriodStats(
    String period,
    String selectedType,
    PlayerProfileModel profile,
    GameStatsModel? selectedStats,
    List<MatchHistoryModel> history,
  ) {
    if (period == 'overall') {
      final wins = selectedType == 'overall'
          ? profile.totalWins
          : selectedStats?.wins ?? 0;
      final games = selectedType == 'overall'
          ? profile.totalGames
          : selectedStats?.gamesPlayed ?? 0;
      final rate = games == 0 ? 0.0 : wins / games * 100;
      return (wins, games, rate, profile.coins, profile.xp);
    }

    final now = DateTime.now();
    final cutoff = period == 'daily'
        ? DateTime(now.year, now.month, now.day)
        : DateTime(
            now.year,
            now.month,
            now.day,
          ).subtract(Duration(days: now.weekday - DateTime.monday));
    final matches = history.where((match) {
      final inPeriod = !match.playedAt.isBefore(cutoff);
      final matchesGame =
          selectedType == 'overall' || match.gameType == selectedType;
      return inPeriod && matchesGame;
    }).toList();
    final wins = matches.where((match) => match.result == 'win').length;
    final games = matches.length;
    final rate = games == 0 ? 0.0 : wins / games * 100;
    final coins = matches.fold<int>(0, (sum, match) => sum + match.coinsEarned);
    final xp = matches.fold<int>(0, (sum, match) => sum + match.xpEarned);
    return (wins, games, rate, coins, xp);
  }
}
