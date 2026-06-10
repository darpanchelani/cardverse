class GameStatsModel {
  const GameStatsModel({
    required this.gameType,
    required this.gamesPlayed,
    required this.wins,
    required this.losses,
    required this.draws,
    required this.bestScore,
    required this.currentStreak,
    required this.bestStreak,
    required this.xpEarned,
    required this.coinsEarned,
    required this.lastPlayedAt,
  });

  factory GameStatsModel.empty(String gameType) => GameStatsModel(
    gameType: gameType,
    gamesPlayed: 0,
    wins: 0,
    losses: 0,
    draws: 0,
    bestScore: 0,
    currentStreak: 0,
    bestStreak: 0,
    xpEarned: 0,
    coinsEarned: 0,
    lastPlayedAt: null,
  );

  factory GameStatsModel.fromJson(Map<String, dynamic> json) {
    return GameStatsModel(
      gameType: json['gameType'] as String? ?? 'unknown',
      gamesPlayed: _int(json['gamesPlayed']),
      wins: _int(json['wins']),
      losses: _int(json['losses']),
      draws: _int(json['draws']),
      bestScore: _int(json['bestScore']),
      currentStreak: _int(json['currentStreak']),
      bestStreak: _int(json['bestStreak']),
      xpEarned: _int(json['xpEarned']),
      coinsEarned: _int(json['coinsEarned']),
      lastPlayedAt: DateTime.tryParse(json['lastPlayedAt'] as String? ?? ''),
    );
  }

  final String gameType;
  final int gamesPlayed;
  final int wins;
  final int losses;
  final int draws;
  final int bestScore;
  final int currentStreak;
  final int bestStreak;
  final int xpEarned;
  final int coinsEarned;
  final DateTime? lastPlayedAt;

  double get winRate => gamesPlayed == 0 ? 0 : wins / gamesPlayed * 100;

  Map<String, dynamic> toJson() => {
    'gameType': gameType,
    'gamesPlayed': gamesPlayed,
    'wins': wins,
    'losses': losses,
    'draws': draws,
    'bestScore': bestScore,
    'currentStreak': currentStreak,
    'bestStreak': bestStreak,
    'xpEarned': xpEarned,
    'coinsEarned': coinsEarned,
    'lastPlayedAt': lastPlayedAt?.toIso8601String(),
  };

  GameStatsModel copyWith({
    String? gameType,
    int? gamesPlayed,
    int? wins,
    int? losses,
    int? draws,
    int? bestScore,
    int? currentStreak,
    int? bestStreak,
    int? xpEarned,
    int? coinsEarned,
    DateTime? lastPlayedAt,
  }) {
    return GameStatsModel(
      gameType: gameType ?? this.gameType,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      bestScore: bestScore ?? this.bestScore,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      xpEarned: xpEarned ?? this.xpEarned,
      coinsEarned: coinsEarned ?? this.coinsEarned,
      lastPlayedAt: lastPlayedAt ?? this.lastPlayedAt,
    );
  }

  static int _int(dynamic value) => value is num ? value.toInt() : 0;
}
