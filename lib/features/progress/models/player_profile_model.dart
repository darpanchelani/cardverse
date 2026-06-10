class PlayerProfileModel {
  const PlayerProfileModel({
    required this.username,
    required this.avatar,
    required this.level,
    required this.xp,
    required this.coins,
    required this.totalGames,
    required this.totalWins,
    required this.totalLosses,
    required this.totalDraws,
    required this.winRate,
    required this.favoriteGame,
    required this.currentStreak,
    required this.bestStreak,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PlayerProfileModel.defaults({DateTime? now}) {
    final timestamp = now ?? DateTime.now();
    return PlayerProfileModel(
      username: 'Guest Player',
      avatar: 'default',
      level: 1,
      xp: 0,
      coins: 500,
      totalGames: 0,
      totalWins: 0,
      totalLosses: 0,
      totalDraws: 0,
      winRate: 0,
      favoriteGame: 'None',
      currentStreak: 0,
      bestStreak: 0,
      createdAt: timestamp,
      updatedAt: timestamp,
    );
  }

  factory PlayerProfileModel.fromJson(Map<String, dynamic> json) {
    final defaults = PlayerProfileModel.defaults();
    return PlayerProfileModel(
      username: json['username'] as String? ?? defaults.username,
      avatar: json['avatar'] as String? ?? defaults.avatar,
      level: _int(json['level'], defaults.level),
      xp: _int(json['xp'], defaults.xp),
      coins: _int(json['coins'], defaults.coins),
      totalGames: _int(json['totalGames'], 0),
      totalWins: _int(json['totalWins'], 0),
      totalLosses: _int(json['totalLosses'], 0),
      totalDraws: _int(json['totalDraws'], 0),
      winRate: (json['winRate'] as num?)?.toDouble() ?? 0,
      favoriteGame: json['favoriteGame'] as String? ?? 'None',
      currentStreak: _int(json['currentStreak'], 0),
      bestStreak: _int(json['bestStreak'], 0),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          defaults.createdAt,
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          defaults.updatedAt,
    );
  }

  final String username;
  final String avatar;
  final int level;
  final int xp;
  final int coins;
  final int totalGames;
  final int totalWins;
  final int totalLosses;
  final int totalDraws;
  final double winRate;
  final String favoriteGame;
  final int currentStreak;
  final int bestStreak;
  final DateTime createdAt;
  final DateTime updatedAt;

  static double calculateWinRate(int wins, int games) {
    return games <= 0 ? 0 : wins / games * 100;
  }

  Map<String, dynamic> toJson() => {
    'username': username,
    'avatar': avatar,
    'level': level,
    'xp': xp,
    'coins': coins,
    'totalGames': totalGames,
    'totalWins': totalWins,
    'totalLosses': totalLosses,
    'totalDraws': totalDraws,
    'winRate': winRate,
    'favoriteGame': favoriteGame,
    'currentStreak': currentStreak,
    'bestStreak': bestStreak,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  PlayerProfileModel copyWith({
    String? username,
    String? avatar,
    int? level,
    int? xp,
    int? coins,
    int? totalGames,
    int? totalWins,
    int? totalLosses,
    int? totalDraws,
    double? winRate,
    String? favoriteGame,
    int? currentStreak,
    int? bestStreak,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlayerProfileModel(
      username: username ?? this.username,
      avatar: avatar ?? this.avatar,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      coins: coins ?? this.coins,
      totalGames: totalGames ?? this.totalGames,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      totalDraws: totalDraws ?? this.totalDraws,
      winRate: winRate ?? this.winRate,
      favoriteGame: favoriteGame ?? this.favoriteGame,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  static int _int(dynamic value, int fallback) =>
      value is num ? value.toInt() : fallback;
}
