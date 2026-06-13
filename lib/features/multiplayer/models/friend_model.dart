class FriendModel {
  const FriendModel({
    required this.id,
    required this.username,
    required this.avatar,
    required this.isOnline,
    required this.status,
    required this.level,
    required this.wins,
    required this.coins,
    required this.lastSeenAt,
  });

  factory FriendModel.fromJson(Map<String, dynamic> json) => FriendModel(
    id: (json['id'] ?? json['_id'] ?? '').toString(),
    username: json['username'] as String? ?? 'Player',
    avatar: json['avatar'] as String? ?? 'default',
    isOnline: json['isOnline'] as bool? ?? false,
    status: json['status'] as String? ?? 'offline',
    level: (json['level'] as num?)?.toInt() ?? 1,
    wins:
        (json['wins'] as num?)?.toInt() ??
        (json['totalWins'] as num?)?.toInt() ??
        0,
    coins: (json['coins'] as num?)?.toInt() ?? 0,
    lastSeenAt:
        DateTime.tryParse(json['lastSeenAt'] as String? ?? '') ??
        DateTime.now(),
  );

  final String id;
  final String username;
  final String avatar;
  final bool isOnline;
  final String status;
  final int level;
  final int wins;
  final int coins;
  final DateTime lastSeenAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'avatar': avatar,
    'isOnline': isOnline,
    'status': status,
    'level': level,
    'wins': wins,
    'coins': coins,
    'lastSeenAt': lastSeenAt.toIso8601String(),
  };

  FriendModel copyWith({
    String? id,
    String? username,
    String? avatar,
    bool? isOnline,
    String? status,
    int? level,
    int? wins,
    int? coins,
    DateTime? lastSeenAt,
  }) => FriendModel(
    id: id ?? this.id,
    username: username ?? this.username,
    avatar: avatar ?? this.avatar,
    isOnline: isOnline ?? this.isOnline,
    status: status ?? this.status,
    level: level ?? this.level,
    wins: wins ?? this.wins,
    coins: coins ?? this.coins,
    lastSeenAt: lastSeenAt ?? this.lastSeenAt,
  );
}
