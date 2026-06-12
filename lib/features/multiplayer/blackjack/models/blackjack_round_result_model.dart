import 'package:cardverse/features/multiplayer/blackjack/models/blackjack_player_result_model.dart';

class BlackjackRoundResultModel {
  const BlackjackRoundResultModel({
    required this.roundNumber,
    required this.dealerScore,
    required this.playerResults,
    required this.createdAt,
  });

  factory BlackjackRoundResultModel.fromJson(Map<String, dynamic> json) =>
      BlackjackRoundResultModel(
        roundNumber: (json['roundNumber'] as num?)?.toInt() ?? 0,
        dealerScore: (json['dealerScore'] as num?)?.toInt() ?? 0,
        playerResults: _results(json['playerResults']),
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  final int roundNumber;
  final int dealerScore;
  final Map<String, BlackjackPlayerResultModel> playerResults;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'roundNumber': roundNumber,
    'dealerScore': dealerScore,
    'playerResults': playerResults.map(
      (key, value) => MapEntry(key, value.toJson()),
    ),
    'createdAt': createdAt.toIso8601String(),
  };

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
