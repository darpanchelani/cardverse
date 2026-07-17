import 'package:cardverse/core/network/api_client.dart';
import 'package:cardverse/core/network/api_endpoints.dart';
import 'package:cardverse/features/progress/models/leaderboard_entry_model.dart';

class LeaderboardApiService {
  LeaderboardApiService(this._api);

  final ApiClient _api;

  Future<List<LeaderboardEntryModel>> getLeaderboard(
    String type, {
    String period = 'overall',
  }) async {
    final response = await _api.get(
      ApiEndpoints.leaderboard,
      query: {'type': type, 'period': period},
    );
    final data = Map<String, dynamic>.from(
      response['data'] as Map? ?? const {},
    );
    return (data['leaderboard'] as List<dynamic>? ?? const [])
        .map(
          (item) => LeaderboardEntryModel.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }
}
