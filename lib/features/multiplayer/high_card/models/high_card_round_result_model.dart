import 'package:cardverse/features/games/models/playing_card_model.dart';

class HighCardRoundResultModel {
  const HighCardRoundResultModel({
    required this.roundNumber,
    required this.winnerId,
    required this.winnerName,
    required this.result,
    required this.message,
    required this.cards,
    required this.createdAt,
  });

  factory HighCardRoundResultModel.fromJson(Map<String, dynamic> json) {
    final rawCards = Map<String, dynamic>.from(
      json['cards'] as Map? ?? json['playerCards'] as Map? ?? const {},
    );
    return HighCardRoundResultModel(
      roundNumber: (json['roundNumber'] as num?)?.toInt() ?? 0,
      winnerId: json['winnerId'] as String?,
      winnerName: json['winnerName'] as String?,
      result: json['result'] as String? ?? 'draw',
      message: json['message'] as String? ?? 'Round draw!',
      cards: rawCards.map(
        (key, value) => MapEntry(
          key,
          PlayingCardModel.fromJson(Map<String, dynamic>.from(value as Map)),
        ),
      ),
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  final int roundNumber;
  final String? winnerId;
  final String? winnerName;
  final String result;
  final String message;
  final Map<String, PlayingCardModel> cards;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'roundNumber': roundNumber,
    'winnerId': winnerId,
    'winnerName': winnerName,
    'result': result,
    'message': message,
    'cards': cards.map((key, value) => MapEntry(key, value.toJson())),
    'createdAt': createdAt.toIso8601String(),
  };
}
