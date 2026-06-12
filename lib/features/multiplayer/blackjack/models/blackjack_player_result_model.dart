class BlackjackPlayerResultModel {
  const BlackjackPlayerResultModel({
    required this.playerId,
    required this.result,
    required this.message,
    required this.playerScore,
    required this.dealerScore,
    required this.chipsChange,
  });

  factory BlackjackPlayerResultModel.fromJson(Map<String, dynamic> json) =>
      BlackjackPlayerResultModel(
        playerId: json['playerId'] as String? ?? '',
        result: json['result'] as String? ?? 'push',
        message: json['message'] as String? ?? '',
        playerScore: (json['playerScore'] as num?)?.toInt() ?? 0,
        dealerScore: (json['dealerScore'] as num?)?.toInt() ?? 0,
        chipsChange: (json['chipsChange'] as num?)?.toInt() ?? 0,
      );

  final String playerId;
  final String result;
  final String message;
  final int playerScore;
  final int dealerScore;
  final int chipsChange;

  Map<String, dynamic> toJson() => {
    'playerId': playerId,
    'result': result,
    'message': message,
    'playerScore': playerScore,
    'dealerScore': dealerScore,
    'chipsChange': chipsChange,
  };
}
