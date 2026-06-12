import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:cardverse/features/multiplayer/models/room_player_model.dart';
import 'package:cardverse/features/multiplayer/war/models/war_battle_result_model.dart';

class WarGameStateModel {
  const WarGameStateModel({
    required this.roomCode,
    required this.gameType,
    required this.status,
    required this.players,
    required this.currentBattle,
    required this.maxBattles,
    required this.warMode,
    required this.currentBattleCards,
    required this.scores,
    required this.cardCounts,
    required this.warCards,
    required this.battlePileCount,
    required this.warCount,
    required this.battleResult,
    required this.battleHistory,
    required this.matchWinnerId,
    required this.matchWinnerName,
    required this.matchMessage,
    required this.rematchRequests,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WarGameStateModel.fromJson(Map<String, dynamic> json) {
    final winner = Map<String, dynamic>.from(
      json['matchWinner'] as Map? ?? const {},
    );
    final rawCards = Map<String, dynamic>.from(
      json['currentBattleCards'] as Map? ?? const {},
    );
    return WarGameStateModel(
      roomCode: json['roomCode'] as String? ?? '',
      gameType: json['gameType'] as String? ?? 'war',
      status: json['status'] as String? ?? 'waiting',
      players: (json['players'] as List<dynamic>? ?? const [])
          .map(
            (item) => RoomPlayerModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      currentBattle: (json['currentBattle'] as num?)?.toInt() ?? 1,
      maxBattles: (json['maxBattles'] as num?)?.toInt(),
      warMode: json['warMode'] as String? ?? 'classic',
      currentBattleCards: rawCards.map(
        (key, value) => MapEntry(
          key,
          value == null
              ? null
              : PlayingCardModel.fromJson(
                  Map<String, dynamic>.from(value as Map),
                ),
        ),
      ),
      scores: _intMap(json['scores']),
      cardCounts: _intMap(json['cardCounts']),
      warCards: Map<String, dynamic>.from(json['warCards'] as Map? ?? const {}),
      battlePileCount: (json['battlePileCount'] as num?)?.toInt() ?? 0,
      warCount: (json['warCount'] as num?)?.toInt() ?? 0,
      battleResult: json['battleResult'] is Map
          ? WarBattleResultModel.fromJson(
              Map<String, dynamic>.from(json['battleResult'] as Map),
            )
          : null,
      battleHistory: (json['battleHistory'] as List<dynamic>? ?? const [])
          .map(
            (item) => WarBattleResultModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      matchWinnerId: winner['winnerId'] as String?,
      matchWinnerName: winner['winnerName'] as String?,
      matchMessage: winner['message'] as String?,
      rematchRequests: (json['rematchRequests'] as List<dynamic>? ?? const [])
          .map((item) => item.toString())
          .toList(),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  final String roomCode;
  final String gameType;
  final String status;
  final List<RoomPlayerModel> players;
  final int currentBattle;
  final int? maxBattles;
  final String warMode;
  final Map<String, PlayingCardModel?> currentBattleCards;
  final Map<String, int> scores;
  final Map<String, int> cardCounts;
  final Map<String, dynamic> warCards;
  final int battlePileCount;
  final int warCount;
  final WarBattleResultModel? battleResult;
  final List<WarBattleResultModel> battleHistory;
  final String? matchWinnerId;
  final String? matchWinnerName;
  final String? matchMessage;
  final List<String> rematchRequests;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'roomCode': roomCode,
    'gameType': gameType,
    'status': status,
    'players': players.map((player) => player.toJson()).toList(),
    'currentBattle': currentBattle,
    'maxBattles': maxBattles,
    'warMode': warMode,
    'currentBattleCards': currentBattleCards.map(
      (key, value) => MapEntry(key, value?.toJson()),
    ),
    'scores': scores,
    'cardCounts': cardCounts,
    'warCards': warCards,
    'battlePileCount': battlePileCount,
    'warCount': warCount,
    'battleResult': battleResult?.toJson(),
    'battleHistory': battleHistory.map((battle) => battle.toJson()).toList(),
    'matchWinner': {
      'winnerId': matchWinnerId,
      'winnerName': matchWinnerName,
      'message': matchMessage,
    },
    'rematchRequests': rematchRequests,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  WarGameStateModel copyWith({
    String? status,
    List<RoomPlayerModel>? players,
    int? currentBattle,
    int? maxBattles,
    Map<String, PlayingCardModel?>? currentBattleCards,
    Map<String, int>? scores,
    Map<String, int>? cardCounts,
    Map<String, dynamic>? warCards,
    int? battlePileCount,
    int? warCount,
    WarBattleResultModel? battleResult,
    List<WarBattleResultModel>? battleHistory,
    List<String>? rematchRequests,
    DateTime? updatedAt,
  }) => WarGameStateModel(
    roomCode: roomCode,
    gameType: gameType,
    status: status ?? this.status,
    players: players ?? this.players,
    currentBattle: currentBattle ?? this.currentBattle,
    maxBattles: maxBattles ?? this.maxBattles,
    warMode: warMode,
    currentBattleCards: currentBattleCards ?? this.currentBattleCards,
    scores: scores ?? this.scores,
    cardCounts: cardCounts ?? this.cardCounts,
    warCards: warCards ?? this.warCards,
    battlePileCount: battlePileCount ?? this.battlePileCount,
    warCount: warCount ?? this.warCount,
    battleResult: battleResult ?? this.battleResult,
    battleHistory: battleHistory ?? this.battleHistory,
    matchWinnerId: matchWinnerId,
    matchWinnerName: matchWinnerName,
    matchMessage: matchMessage,
    rematchRequests: rematchRequests ?? this.rematchRequests,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static Map<String, int> _intMap(dynamic raw) => Map<String, dynamic>.from(
    raw as Map? ?? const {},
  ).map((key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0));
}
