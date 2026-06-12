import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:cardverse/features/multiplayer/blackjack/models/blackjack_player_result_model.dart';
import 'package:cardverse/features/multiplayer/blackjack/models/blackjack_round_result_model.dart';
import 'package:cardverse/features/multiplayer/models/room_player_model.dart';

class BlackjackDealerModel {
  const BlackjackDealerModel({
    required this.hand,
    required this.score,
    required this.isHidden,
  });

  factory BlackjackDealerModel.fromJson(Map<String, dynamic> json) =>
      BlackjackDealerModel(
        hand: (json['hand'] as List<dynamic>? ?? const [])
            .map(
              (item) => item == null
                  ? null
                  : PlayingCardModel.fromJson(
                      Map<String, dynamic>.from(item as Map),
                    ),
            )
            .toList(),
        score: (json['score'] as num?)?.toInt() ?? 0,
        isHidden: json['isHidden'] as bool? ?? true,
      );

  final List<PlayingCardModel?> hand;
  final int score;
  final bool isHidden;

  Map<String, dynamic> toJson() => {
    'hand': hand.map((card) => card?.toJson()).toList(),
    'score': score,
    'isHidden': isHidden,
  };
}

class BlackjackMatchResultModel {
  const BlackjackMatchResultModel({
    required this.winnerId,
    required this.winnerName,
    required this.message,
    required this.rankings,
  });

  factory BlackjackMatchResultModel.fromJson(Map<String, dynamic> json) =>
      BlackjackMatchResultModel(
        winnerId: json['winnerId'] as String?,
        winnerName: json['winnerName'] as String?,
        message: json['message'] as String? ?? '',
        rankings: (json['rankings'] as List<dynamic>? ?? const [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList(),
      );

  final String? winnerId;
  final String? winnerName;
  final String message;
  final List<Map<String, dynamic>> rankings;

  Map<String, dynamic> toJson() => {
    'winnerId': winnerId,
    'winnerName': winnerName,
    'message': message,
    'rankings': rankings,
  };
}

class BlackjackGameStateModel {
  const BlackjackGameStateModel({
    required this.roomCode,
    required this.gameType,
    required this.status,
    required this.players,
    required this.dealer,
    required this.playerHands,
    required this.playerBets,
    required this.playerChips,
    required this.playerStatuses,
    required this.currentRound,
    required this.maxRounds,
    required this.startingChips,
    required this.minimumBet,
    required this.dealerRule,
    required this.currentTurnPlayerId,
    required this.roundResults,
    required this.matchResults,
    required this.roundHistory,
    required this.rematchRequests,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BlackjackGameStateModel.fromJson(
    Map<String, dynamic> json,
  ) => BlackjackGameStateModel(
    roomCode: json['roomCode'] as String? ?? '',
    gameType: json['gameType'] as String? ?? 'blackjack',
    status: json['status'] as String? ?? 'waiting',
    players: (json['players'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              RoomPlayerModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(),
    dealer: BlackjackDealerModel.fromJson(
      Map<String, dynamic>.from(json['dealer'] as Map? ?? const {}),
    ),
    playerHands: _hands(json['playerHands']),
    playerBets: _intMap(json['playerBets']),
    playerChips: _intMap(json['playerChips']),
    playerStatuses: _stringMap(json['playerStatuses']),
    currentRound: (json['currentRound'] as num?)?.toInt() ?? 1,
    maxRounds: (json['maxRounds'] as num?)?.toInt(),
    startingChips: (json['startingChips'] as num?)?.toInt() ?? 1000,
    minimumBet: (json['minimumBet'] as num?)?.toInt() ?? 10,
    dealerRule: json['dealerRule'] as String? ?? 'stand_on_17',
    currentTurnPlayerId: json['currentTurnPlayerId'] as String?,
    roundResults: _results(json['roundResults']),
    matchResults: json['matchResults'] is Map
        ? BlackjackMatchResultModel.fromJson(
            Map<String, dynamic>.from(json['matchResults'] as Map),
          )
        : null,
    roundHistory: (json['roundHistory'] as List<dynamic>? ?? const [])
        .map(
          (item) => BlackjackRoundResultModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(),
    rematchRequests: (json['rematchRequests'] as List<dynamic>? ?? const [])
        .map((item) => item.toString())
        .toList(),
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
  );

  final String roomCode;
  final String gameType;
  final String status;
  final List<RoomPlayerModel> players;
  final BlackjackDealerModel dealer;
  final Map<String, List<PlayingCardModel>> playerHands;
  final Map<String, int> playerBets;
  final Map<String, int> playerChips;
  final Map<String, String> playerStatuses;
  final int currentRound;
  final int? maxRounds;
  final int startingChips;
  final int minimumBet;
  final String dealerRule;
  final String? currentTurnPlayerId;
  final Map<String, BlackjackPlayerResultModel> roundResults;
  final BlackjackMatchResultModel? matchResults;
  final List<BlackjackRoundResultModel> roundHistory;
  final List<String> rematchRequests;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
    'roomCode': roomCode,
    'gameType': gameType,
    'status': status,
    'players': players.map((player) => player.toJson()).toList(),
    'dealer': dealer.toJson(),
    'playerHands': playerHands.map(
      (key, value) =>
          MapEntry(key, value.map((card) => card.toJson()).toList()),
    ),
    'playerBets': playerBets,
    'playerChips': playerChips,
    'playerStatuses': playerStatuses,
    'currentRound': currentRound,
    'maxRounds': maxRounds,
    'startingChips': startingChips,
    'minimumBet': minimumBet,
    'dealerRule': dealerRule,
    'currentTurnPlayerId': currentTurnPlayerId,
    'roundResults': roundResults.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
    'matchResults': matchResults?.toJson(),
    'roundHistory': roundHistory.map((round) => round.toJson()).toList(),
    'rematchRequests': rematchRequests,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  BlackjackGameStateModel copyWith({
    String? status,
    List<RoomPlayerModel>? players,
    BlackjackDealerModel? dealer,
    Map<String, List<PlayingCardModel>>? playerHands,
    Map<String, int>? playerBets,
    Map<String, int>? playerChips,
    Map<String, String>? playerStatuses,
    int? currentRound,
    Map<String, BlackjackPlayerResultModel>? roundResults,
    BlackjackMatchResultModel? matchResults,
    List<BlackjackRoundResultModel>? roundHistory,
    List<String>? rematchRequests,
    DateTime? updatedAt,
  }) => BlackjackGameStateModel(
    roomCode: roomCode,
    gameType: gameType,
    status: status ?? this.status,
    players: players ?? this.players,
    dealer: dealer ?? this.dealer,
    playerHands: playerHands ?? this.playerHands,
    playerBets: playerBets ?? this.playerBets,
    playerChips: playerChips ?? this.playerChips,
    playerStatuses: playerStatuses ?? this.playerStatuses,
    currentRound: currentRound ?? this.currentRound,
    maxRounds: maxRounds,
    startingChips: startingChips,
    minimumBet: minimumBet,
    dealerRule: dealerRule,
    currentTurnPlayerId: currentTurnPlayerId,
    roundResults: roundResults ?? this.roundResults,
    matchResults: matchResults ?? this.matchResults,
    roundHistory: roundHistory ?? this.roundHistory,
    rematchRequests: rematchRequests ?? this.rematchRequests,
    createdAt: createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  static Map<String, List<PlayingCardModel>> _hands(dynamic raw) =>
      Map<String, dynamic>.from(raw as Map? ?? const {}).map(
        (key, value) => MapEntry(
          key,
          (value as List<dynamic>? ?? const [])
              .whereType<Map>()
              .map(
                (card) =>
                    PlayingCardModel.fromJson(Map<String, dynamic>.from(card)),
              )
              .toList(),
        ),
      );

  static Map<String, int> _intMap(dynamic raw) => Map<String, dynamic>.from(
    raw as Map? ?? const {},
  ).map((key, value) => MapEntry(key, (value as num?)?.toInt() ?? 0));

  static Map<String, String> _stringMap(dynamic raw) =>
      Map<String, dynamic>.from(
        raw as Map? ?? const {},
      ).map((key, value) => MapEntry(key, value?.toString() ?? 'waiting'));

  static Map<String, BlackjackPlayerResultModel> _results(dynamic raw) =>
      Map<String, dynamic>.from(raw as Map? ?? const {}).map(
        (key, value) => MapEntry(
          key,
          BlackjackPlayerResultModel.fromJson(
            Map<String, dynamic>.from(value as Map),
          ),
        ),
      );
}
