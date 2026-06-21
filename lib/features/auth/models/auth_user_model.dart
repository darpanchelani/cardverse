class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.avatar,
    required this.level,
    required this.xp,
    required this.coins,
    required this.totalGames,
    required this.totalWins,
    required this.totalLosses,
    required this.totalDraws,
    required this.currentStreak,
    required this.bestStreak,
    required this.favoriteGame,
    required this.isOnline,
    required this.lastSeenAt,
    required this.createdAt,
    required this.avatarFrame,
    required this.equippedCardTheme,
    required this.equippedTableTheme,
    required this.unlockedCardThemes,
    required this.unlockedTableThemes,
    required this.unlockedAvatarFrames,
    required this.settings,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) => AuthUserModel(
    id: (json['id'] ?? json['_id'] ?? '').toString(),
    username: json['username'] as String? ?? 'Player',
    email: json['email'] as String? ?? '',
    avatar: json['avatar'] as String? ?? 'default',
    level: (json['level'] as num?)?.toInt() ?? 1,
    xp: (json['xp'] as num?)?.toInt() ?? 0,
    coins: (json['coins'] as num?)?.toInt() ?? 500,
    totalGames: (json['totalGames'] as num?)?.toInt() ?? 0,
    totalWins: (json['totalWins'] as num?)?.toInt() ?? 0,
    totalLosses: (json['totalLosses'] as num?)?.toInt() ?? 0,
    totalDraws: (json['totalDraws'] as num?)?.toInt() ?? 0,
    currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
    bestStreak: (json['bestStreak'] as num?)?.toInt() ?? 0,
    favoriteGame: json['favoriteGame'] as String? ?? 'None',
    isOnline: json['isOnline'] as bool? ?? false,
    lastSeenAt:
        DateTime.tryParse(json['lastSeenAt'] as String? ?? '') ??
        DateTime.now(),
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    avatarFrame: json['avatarFrame'] as String? ?? 'default',
    equippedCardTheme: json['equippedCardTheme'] as String? ?? 'classic',
    equippedTableTheme: json['equippedTableTheme'] as String? ?? 'green_felt',
    unlockedCardThemes: _strings(json['unlockedCardThemes'], 'classic'),
    unlockedTableThemes: _strings(json['unlockedTableThemes'], 'green_felt'),
    unlockedAvatarFrames: _strings(json['unlockedAvatarFrames'], 'default'),
    settings: Map<String, dynamic>.from(
      json['settings'] as Map? ??
          const {
            'soundEnabled': true,
            'vibrationEnabled': true,
            'notificationsEnabled': true,
            'privateProfile': false,
            'showOnlineStatus': true,
          },
    ),
  );

  final String id;
  final String username;
  final String email;
  final String avatar;
  final int level;
  final int xp;
  final int coins;
  final int totalGames;
  final int totalWins;
  final int totalLosses;
  final int totalDraws;
  final int currentStreak;
  final int bestStreak;
  final String favoriteGame;
  final bool isOnline;
  final DateTime lastSeenAt;
  final DateTime createdAt;
  final String avatarFrame;
  final String equippedCardTheme;
  final String equippedTableTheme;
  final List<String> unlockedCardThemes;
  final List<String> unlockedTableThemes;
  final List<String> unlockedAvatarFrames;
  final Map<String, dynamic> settings;

  double get winRate => totalGames == 0 ? 0 : totalWins / totalGames * 100;

  AuthUserModel copyWith({
    String? username,
    String? avatar,
    int? level,
    int? xp,
    int? coins,
    int? totalGames,
    int? totalWins,
    int? totalLosses,
    int? totalDraws,
    int? currentStreak,
    int? bestStreak,
    String? favoriteGame,
    bool? isOnline,
    String? avatarFrame,
    String? equippedCardTheme,
    String? equippedTableTheme,
    List<String>? unlockedCardThemes,
    List<String>? unlockedTableThemes,
    List<String>? unlockedAvatarFrames,
    Map<String, dynamic>? settings,
  }) => AuthUserModel(
    id: id,
    username: username ?? this.username,
    email: email,
    avatar: avatar ?? this.avatar,
    level: level ?? this.level,
    xp: xp ?? this.xp,
    coins: coins ?? this.coins,
    totalGames: totalGames ?? this.totalGames,
    totalWins: totalWins ?? this.totalWins,
    totalLosses: totalLosses ?? this.totalLosses,
    totalDraws: totalDraws ?? this.totalDraws,
    currentStreak: currentStreak ?? this.currentStreak,
    bestStreak: bestStreak ?? this.bestStreak,
    favoriteGame: favoriteGame ?? this.favoriteGame,
    isOnline: isOnline ?? this.isOnline,
    lastSeenAt: lastSeenAt,
    createdAt: createdAt,
    avatarFrame: avatarFrame ?? this.avatarFrame,
    equippedCardTheme: equippedCardTheme ?? this.equippedCardTheme,
    equippedTableTheme: equippedTableTheme ?? this.equippedTableTheme,
    unlockedCardThemes: unlockedCardThemes ?? this.unlockedCardThemes,
    unlockedTableThemes: unlockedTableThemes ?? this.unlockedTableThemes,
    unlockedAvatarFrames: unlockedAvatarFrames ?? this.unlockedAvatarFrames,
    settings: settings ?? this.settings,
  );

  static List<String> _strings(dynamic value, String fallback) {
    final values = (value as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .toList();
    return values.isEmpty ? [fallback] : values;
  }
}
