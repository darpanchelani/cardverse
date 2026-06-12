import 'package:cardverse/features/games/models/playing_card_model.dart';

class WarBattleResultModel {
  const WarBattleResultModel({
    required this.battleNumber,
    required this.winnerId,
    required this.winnerName,
    required this.result,
    required this.message,
    required this.cards,
    required this.warCards,
    required this.pileCount,
    required this.createdAt,
  });

  factory WarBattleResultModel.fromJson(Map<String, dynamic> json) {
    final rawCards = Map<String, dynamic>.from(
      json['cards'] as Map? ?? const {},
    );
    return WarBattleResultModel(
      battleNumber: (json['battleNumber'] as num?)?.toInt() ?? 0,
      winnerId: json['winnerId'] as String?,
      winnerName: json['winnerName'] as String?,
      result: json['result'] as String? ?? 'draw',
      message: json['message'] as String? ?? 'Battle draw.',
      cards: rawCards.map(
        (key, value) => MapEntry(
          key,
          PlayingCardModel.fromJson(Map<String, dynamic>.from(value as Map)),
        ),
      ),
      warCards: Map<String, dynamic>.from(json['warCards'] as Map? ?? const {}),
      pileCount: (json['pileCount'] as num?)?.toInt() ?? 0,
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  final int battleNumber;
  final String? winnerId;
  final String? winnerName;
  final String result;
  final String message;
  final Map<String, PlayingCardModel> cards;
  final Map<String, dynamic> warCards;
  final int pileCount;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'battleNumber': battleNumber,
    'winnerId': winnerId,
    'winnerName': winnerName,
    'result': result,
    'message': message,
    'cards': cards.map((key, value) => MapEntry(key, value.toJson())),
    'warCards': warCards,
    'pileCount': pileCount,
    'createdAt': createdAt.toIso8601String(),
  };
}
