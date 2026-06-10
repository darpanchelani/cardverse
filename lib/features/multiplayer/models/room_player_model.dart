class RoomPlayerModel {
  const RoomPlayerModel({
    required this.id,
    required this.username,
    required this.avatar,
    required this.isHost,
    required this.isReady,
    required this.isBot,
    required this.seatIndex,
    required this.connectionStatus,
  });

  factory RoomPlayerModel.fromJson(Map<String, dynamic> json) =>
      RoomPlayerModel(
        id: json['id'] as String? ?? '',
        username: json['username'] as String? ?? 'Player',
        avatar: json['avatar'] as String? ?? 'default',
        isHost: json['isHost'] as bool? ?? false,
        isReady: json['isReady'] as bool? ?? false,
        isBot: json['isBot'] as bool? ?? false,
        seatIndex: (json['seatIndex'] as num?)?.toInt() ?? 0,
        connectionStatus: json['connectionStatus'] as String? ?? 'waiting',
      );

  final String id;
  final String username;
  final String avatar;
  final bool isHost;
  final bool isReady;
  final bool isBot;
  final int seatIndex;
  final String connectionStatus;

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'avatar': avatar,
    'isHost': isHost,
    'isReady': isReady,
    'isBot': isBot,
    'seatIndex': seatIndex,
    'connectionStatus': connectionStatus,
  };

  RoomPlayerModel copyWith({
    String? id,
    String? username,
    String? avatar,
    bool? isHost,
    bool? isReady,
    bool? isBot,
    int? seatIndex,
    String? connectionStatus,
  }) => RoomPlayerModel(
    id: id ?? this.id,
    username: username ?? this.username,
    avatar: avatar ?? this.avatar,
    isHost: isHost ?? this.isHost,
    isReady: isReady ?? this.isReady,
    isBot: isBot ?? this.isBot,
    seatIndex: seatIndex ?? this.seatIndex,
    connectionStatus: connectionStatus ?? this.connectionStatus,
  );
}
