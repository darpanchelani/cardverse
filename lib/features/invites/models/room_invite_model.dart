class RoomInviteModel {
  const RoomInviteModel({
    required this.id,
    required this.roomCode,
    required this.fromUserId,
    required this.fromUsername,
    required this.toUserId,
    required this.toUsername,
    required this.gameType,
    required this.gameName,
    required this.status,
    required this.expiresAt,
    required this.createdAt,
  });

  factory RoomInviteModel.fromJson(Map<String, dynamic> json) =>
      RoomInviteModel(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        roomCode: json['roomCode'] as String? ?? '',
        fromUserId: (json['fromUserId'] ?? '').toString(),
        fromUsername: json['fromUsername'] as String? ?? 'Player',
        toUserId: (json['toUserId'] ?? '').toString(),
        toUsername: json['toUsername'] as String? ?? 'Player',
        gameType: json['gameType'] as String? ?? 'high_card',
        gameName: json['gameName'] as String? ?? 'Card Game',
        status: json['status'] as String? ?? 'pending',
        expiresAt:
            DateTime.tryParse(json['expiresAt'] as String? ?? '') ??
            DateTime.now().add(const Duration(minutes: 30)),
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  final String id;
  final String roomCode;
  final String fromUserId;
  final String fromUsername;
  final String toUserId;
  final String toUsername;
  final String gameType;
  final String gameName;
  final String status;
  final DateTime expiresAt;
  final DateTime createdAt;

  RoomInviteModel copyWith({String? status}) => RoomInviteModel(
    id: id,
    roomCode: roomCode,
    fromUserId: fromUserId,
    fromUsername: fromUsername,
    toUserId: toUserId,
    toUsername: toUsername,
    gameType: gameType,
    gameName: gameName,
    status: status ?? this.status,
    expiresAt: expiresAt,
    createdAt: createdAt,
  );
}
