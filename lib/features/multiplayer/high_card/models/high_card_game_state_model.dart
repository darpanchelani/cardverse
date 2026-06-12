import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:cardverse/features/multiplayer/high_card/models/high_card_round_result_model.dart';
import 'package:cardverse/features/multiplayer/models/room_player_model.dart';

class HighCardGameStateModel {
  const HighCardGameStateModel({
    required this.roomCode,
    required this.gameType,
    required this.status,
    required this.players,
    required this.currentRound,
    required this.maxRounds,
    required this.currentCards,
    required this.scores,
    required this.roundResult,
    required this.roundHistory,
    required this.matchWinnerId,
    required this.matchWinnerName,
    required this.matchMessage,
    required this.rematchRequests,
    required this.createdAt,
    required this.updatedAt,
  });

  factory HighCardGameStateModel.fromJson(Map<String, dynamic> json) {
    final matchWinner = Map<String, dynamic>.from(
      json['matchWinner'] as Map? ?? const {},
    );
    final rawCards = Map<String, dynamic>.from(
      json['currentCards'] as Map? ?? const {},
    );
    final rawScores = Map<String, dynamic>.from(
      json['scores'] as Map? ?? const {},
    );
    return HighCardGameStateModel(
      roomCode: json['roomCode'] as String? ?? '',
      gameType: json['gameType'] as String? ?? 'high_card',
      status: json['status'] as String? ?? 'waiting',
      players: (json['players'] as List<dynamic>? ?? const [])
          .map(
            (item) => RoomPlayerModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      currentRound: (json['currentRound'] as num?)?.toInt() ?? 1,
      maxRounds: (json['maxRounds'] as num?)?.toInt() ?? 5,
      currentCards: rawCards.map(
        (key, value) => MapEntry(
          key,
          value == null
              ? null
              : PlayingCardModel.fromJson(
                  Map<String, dynamic>.from(value as Map),
                ),
        ),
      ),
      scores: rawScores.map(
        (key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0),
      ),
      roundResult: json['roundResult'] is Map
          ? HighCardRoundResultModel.fromJson(
              Map<String, dynamic>.from(json['roundResult'] as Map),
            )
          : null,
      roundHistory: (json['roundHistory'] as List<dynamic>? ?? const [])
          .map(
            (item) => HighCardRoundResultModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      matchWinnerId: matchWinner['winnerId'] as String?,
      matchWinnerName: matchWinner['winnerName'] as String?,
      matchMessage: matchWinner['message'] as String?,
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
  final int currentRound;
  final int maxRounds;
  final Map<String, PlayingCardModel?> currentCards;
  final Map<String, int> scores;
  final HighCardRoundResultModel? roundResult;
  final List<HighCardRoundResultModel> roundHistory;
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
    'players': players.map((item) => item.toJson()).toList(),
    'currentRound': currentRound,
    'maxRounds': maxRounds,
    'currentCards': currentCards.map(
      (key, value) => MapEntry(key, value?.toJson()),
    ),
    'scores': scores,
    'roundResult': roundResult?.toJson(),
    'roundHistory': roundHistory.map((item) => item.toJson()).toList(),
    'matchWinner': {
      'winnerId': matchWinnerId,
      'winnerName': matchWinnerName,
      'message': matchMessage,
    },
    'rematchRequests': rematchRequests,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  HighCardGameStateModel copyWith({
    String? status,
    List<RoomPlayerModel>? players,
    int? currentRound,
    int? maxRounds,
    Map<String, PlayingCardModel?>? currentCards,
    Map<String, int>? scores,
    HighCardRoundResultModel? roundResult,
    List<HighCardRoundResultModel>? roundHistory,
    String? matchWinnerId,
    String? matchWinnerName,
    String? matchMessage,
    List<String>? rematchRequests,
    DateTime? updatedAt,
  }) => HighCardGameStateModel(
    roomCode: roomCode,
    gameType: gameType,
    status: status ?? this.status,
    players: players ?? this.players,
    currentRound: currentRound ?? this.currentRound,
    maxRounds: maxRounds ?? this.maxRounds,
    currentCards: currentCards ?? this.currentCards,
    scores: scores ?? this.scores,
    roundResult: roundResult ?? this.roundResult,
    roundHistory: roundHistory ?? this.roundHistory,
    matchWinnerId: matchWinnerId ?? this.matchWinnerId,
    matchWinnerName: matchWinnerName ?? this.matchWinnerName,
    matchMessage: matchMessage ?? this.matchMessage,
    rematchRequests: rematchRequests ?? this.rematchRequests,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
