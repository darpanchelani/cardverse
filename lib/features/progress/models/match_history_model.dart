class MatchHistoryModel {
  const MatchHistoryModel({
    required this.id,
    required this.gameType,
    required this.gameName,
    required this.result,
    required this.opponent,
    required this.playerScore,
    required this.opponentScore,
    required this.coinsEarned,
    required this.xpEarned,
    required this.durationSeconds,
    required this.playedAt,
    required this.extraData,
  });

  factory MatchHistoryModel.fromJson(Map<String, dynamic> json) {
    return MatchHistoryModel(
      id: json['id'] as String? ?? '',
      gameType: json['gameType'] as String? ?? 'unknown',
      gameName: json['gameName'] as String? ?? 'Card Game',
      result: json['result'] as String? ?? 'draw',
      opponent: json['opponent'] as String? ?? 'Computer',
      playerScore: _int(json['playerScore']),
      opponentScore: _int(json['opponentScore']),
      coinsEarned: _int(json['coinsEarned']),
      xpEarned: _int(json['xpEarned']),
      durationSeconds: _int(json['durationSeconds']),
      playedAt:
          DateTime.tryParse(json['playedAt'] as String? ?? '') ??
          DateTime.now(),
      extraData: Map<String, dynamic>.from(
        json['extraData'] as Map? ?? const {},
      ),
    );
  }

  final String id;
  final String gameType;
  final String gameName;
  final String result;
  final String opponent;
  final int playerScore;
  final int opponentScore;
  final int coinsEarned;
  final int xpEarned;
  final int durationSeconds;
  final DateTime playedAt;
  final Map<String, dynamic> extraData;

  Map<String, dynamic> toJson() => {
    'id': id,
    'gameType': gameType,
    'gameName': gameName,
    'result': result,
    'opponent': opponent,
    'playerScore': playerScore,
    'opponentScore': opponentScore,
    'coinsEarned': coinsEarned,
    'xpEarned': xpEarned,
    'durationSeconds': durationSeconds,
    'playedAt': playedAt.toIso8601String(),
    'extraData': extraData,
  };

  static int _int(dynamic value) => value is num ? value.toInt() : 0;
}
