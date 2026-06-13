import 'package:cardverse/core/network/api_client.dart';
import 'package:cardverse/core/network/api_endpoints.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/progress/models/match_history_model.dart';

class MatchHistoryApiService {
  MatchHistoryApiService(this._api, this._auth);

  final ApiClient _api;
  final AuthController _auth;

  Future<void> saveOnlineMatch(Map<String, dynamic> payload) async {
    if (!_auth.isAuthenticated) return;
    await _api.post(ApiEndpoints.matches, data: payload);
    await _auth.loadMe();
  }

  Future<List<MatchHistoryModel>> getMyMatches({String? gameType}) async {
    if (!_auth.isAuthenticated) return [];
    final response = await _api.get(
      ApiEndpoints.myMatches,
      query: {'gameType': ?gameType, 'limit': 100},
    );
    final data = Map<String, dynamic>.from(
      response['data'] as Map? ?? const {},
    );
    return (data['matches'] as List<dynamic>? ?? const [])
        .map(
          (item) => _fromCloud(
            Map<String, dynamic>.from(item as Map),
            _auth.user!.id,
          ),
        )
        .toList();
  }

  MatchHistoryModel _fromCloud(
    Map<String, dynamic> json,
    String currentUserId,
  ) {
    final players = (json['players'] as List<dynamic>? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    final current = players.where(
      (player) => (player['userId'] ?? '').toString() == currentUserId,
    );
    final player = current.isEmpty ? <String, dynamic>{} : current.first;
    final opponent = players.where(
      (item) => (item['userId'] ?? '').toString() != currentUserId,
    );
    final opponentScore = opponent.isEmpty
        ? 0
        : opponent
              .map((item) => (item['score'] as num?)?.toInt() ?? 0)
              .reduce((a, b) => a > b ? a : b);
    return MatchHistoryModel(
      id: (json['_id'] ?? '').toString(),
      gameType: json['gameType'] as String? ?? 'online',
      gameName: json['gameName'] as String? ?? 'Online Match',
      result: player['result'] as String? ?? 'draw',
      opponent: opponent.isEmpty
          ? 'Multiplayer'
          : opponent.map((item) => item['username']).join(', '),
      playerScore: (player['score'] as num?)?.toInt() ?? 0,
      opponentScore: opponentScore,
      coinsEarned: (player['coinsEarned'] as num?)?.toInt() ?? 0,
      xpEarned: (player['xpEarned'] as num?)?.toInt() ?? 0,
      durationSeconds: (json['durationSeconds'] as num?)?.toInt() ?? 0,
      playedAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      extraData: {'roomCode': json['roomCode']},
    );
  }
}
