import 'package:cardverse/features/multiplayer/models/room_player_model.dart';
import 'package:cardverse/features/multiplayer/models/chat_message_model.dart';

class RoomModel {
  const RoomModel({
    required this.roomCode,
    required this.roomName,
    required this.gameType,
    required this.gameName,
    required this.roomType,
    required this.maxPlayers,
    required this.players,
    required this.allowBots,
    required this.allowChat,
    required this.isPrivate,
    required this.status,
    required this.createdAt,
    required this.settings,
    this.chatMessages = const [],
  });

  factory RoomModel.fromJson(Map<String, dynamic> json) => RoomModel(
    roomCode: json['roomCode'] as String? ?? '',
    roomName: json['roomName'] as String? ?? 'CardVerse Room',
    gameType: json['gameType'] as String? ?? 'high_card',
    gameName: json['gameName'] as String? ?? 'High Card',
    roomType: json['roomType'] as String? ?? 'private',
    maxPlayers: (json['maxPlayers'] as num?)?.toInt() ?? 2,
    players: (json['players'] as List<dynamic>? ?? const [])
        .map(
          (player) => RoomPlayerModel.fromJson(
            Map<String, dynamic>.from(player as Map),
          ),
        )
        .toList(),
    allowBots: json['allowBots'] as bool? ?? true,
    allowChat: json['allowChat'] as bool? ?? true,
    isPrivate: json['isPrivate'] as bool? ?? true,
    status: json['status'] as String? ?? 'waiting',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    settings: Map<String, dynamic>.from(json['settings'] as Map? ?? const {}),
    chatMessages: (json['chatMessages'] as List<dynamic>? ?? const [])
        .map(
          (message) => ChatMessageModel.fromJson(
            Map<String, dynamic>.from(message as Map),
          ),
        )
        .toList(),
  );

  final String roomCode;
  final String roomName;
  final String gameType;
  final String gameName;
  final String roomType;
  final int maxPlayers;
  final List<RoomPlayerModel> players;
  final bool allowBots;
  final bool allowChat;
  final bool isPrivate;
  final String status;
  final DateTime createdAt;
  final Map<String, dynamic> settings;
  final List<ChatMessageModel> chatMessages;

  bool get hasEmptySeats => players.length < maxPlayers;
  bool get isFull => players.length >= maxPlayers;
  bool get allPlayersReady =>
      players.isNotEmpty && players.every((player) => player.isReady);
  int get currentPlayerCount => players.length;

  Map<String, dynamic> toJson() => {
    'roomCode': roomCode,
    'roomName': roomName,
    'gameType': gameType,
    'gameName': gameName,
    'roomType': roomType,
    'maxPlayers': maxPlayers,
    'players': players.map((player) => player.toJson()).toList(),
    'allowBots': allowBots,
    'allowChat': allowChat,
    'isPrivate': isPrivate,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
    'settings': settings,
    'chatMessages': chatMessages.map((message) => message.toJson()).toList(),
  };

  RoomModel copyWith({
    String? roomCode,
    String? roomName,
    String? gameType,
    String? gameName,
    String? roomType,
    int? maxPlayers,
    List<RoomPlayerModel>? players,
    bool? allowBots,
    bool? allowChat,
    bool? isPrivate,
    String? status,
    DateTime? createdAt,
    Map<String, dynamic>? settings,
    List<ChatMessageModel>? chatMessages,
  }) => RoomModel(
    roomCode: roomCode ?? this.roomCode,
    roomName: roomName ?? this.roomName,
    gameType: gameType ?? this.gameType,
    gameName: gameName ?? this.gameName,
    roomType: roomType ?? this.roomType,
    maxPlayers: maxPlayers ?? this.maxPlayers,
    players: players ?? this.players,
    allowBots: allowBots ?? this.allowBots,
    allowChat: allowChat ?? this.allowChat,
    isPrivate: isPrivate ?? this.isPrivate,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    settings: settings ?? this.settings,
    chatMessages: chatMessages ?? this.chatMessages,
  );
}
