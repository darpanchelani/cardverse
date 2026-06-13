class LeaderboardEntryModel {
  const LeaderboardEntryModel({
    required this.username,
    required this.gameType,
    required this.wins,
    required this.totalGames,
    required this.winRate,
    required this.coins,
    required this.xp,
    required this.level,
    required this.updatedAt,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      username: json['username'] as String? ?? 'Player',
      gameType: json['gameType'] as String? ?? 'overall',
      wins:
          (json['wins'] as num?)?.toInt() ??
          (json['totalWins'] as num?)?.toInt() ??
          0,
      totalGames: (json['totalGames'] as num?)?.toInt() ?? 0,
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0,
      coins: (json['coins'] as num?)?.toInt() ?? 0,
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      level: (json['level'] as num?)?.toInt() ?? 1,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  final String username;
  final String gameType;
  final int wins;
  final int totalGames;
  final double winRate;
  final int coins;
  final int xp;
  final int level;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'username': username,
    'gameType': gameType,
    'wins': wins,
    'totalGames': totalGames,
    'winRate': winRate,
    'coins': coins,
    'xp': xp,
    'level': level,
    'updatedAt': updatedAt.toIso8601String(),
  };
}
