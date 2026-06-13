import 'package:cardverse/core/network/api_client.dart';
import 'package:cardverse/core/network/api_endpoints.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/friends/models/friend_request_model.dart';
import 'package:cardverse/features/multiplayer/models/friend_model.dart';
import 'package:cardverse/features/multiplayer/services/multiplayer_friend_service.dart';

class FriendsApiService implements MultiplayerFriendService {
  FriendsApiService(this._api, this._auth);

  final ApiClient _api;
  final AuthController _auth;

  @override
  Future<List<FriendModel>> getFriends() async {
    if (!_auth.isAuthenticated) return [];
    final response = await _api.get(ApiEndpoints.friends);
    final data = Map<String, dynamic>.from(
      response['data'] as Map? ?? const {},
    );
    return (data['friends'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              FriendModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<List<FriendModel>> searchFriends(String query) async {
    if (!_auth.isAuthenticated || query.trim().isEmpty) return getFriends();
    final response = await _api.get(
      ApiEndpoints.userSearch,
      query: {'query': query.trim()},
    );
    final data = Map<String, dynamic>.from(
      response['data'] as Map? ?? const {},
    );
    return (data['users'] as List<dynamic>? ?? const [])
        .map(
          (item) =>
              FriendModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<void> sendFriendRequest(String username) async {
    final results = await searchFriends(username);
    final exact = results.where(
      (user) => user.username.toLowerCase() == username.toLowerCase(),
    );
    if (exact.isEmpty) throw StateError('User not found.');
    await _api.post(
      '${ApiEndpoints.friends}/request',
      data: {'toUserId': exact.first.id},
    );
  }

  Future<void> sendFriendRequestById(String userId) async {
    await _api.post(
      '${ApiEndpoints.friends}/request',
      data: {'toUserId': userId},
    );
  }

  Future<
    ({List<FriendRequestModel> incoming, List<FriendRequestModel> outgoing})
  >
  getRequests() async {
    final response = await _api.get(ApiEndpoints.friendRequests);
    final data = Map<String, dynamic>.from(
      response['data'] as Map? ?? const {},
    );
    List<FriendRequestModel> parse(String key) =>
        (data[key] as List<dynamic>? ?? const [])
            .map(
              (item) => FriendRequestModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
    return (incoming: parse('incoming'), outgoing: parse('outgoing'));
  }

  Future<void> accept(String requestId) => _api
      .post('${ApiEndpoints.friendRequests}/$requestId/accept')
      .then((_) {});

  Future<void> decline(String requestId) => _api
      .post('${ApiEndpoints.friendRequests}/$requestId/decline')
      .then((_) {});

  @override
  Future<void> removeFriend(String friendId) =>
      _api.delete('${ApiEndpoints.friends}/$friendId').then((_) {});
}
