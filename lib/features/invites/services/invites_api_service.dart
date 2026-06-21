import 'package:cardverse/core/network/api_client.dart';
import 'package:cardverse/core/network/api_endpoints.dart';
import 'package:cardverse/features/invites/models/room_invite_model.dart';

class InvitesApiService {
  InvitesApiService(this._api);

  final ApiClient _api;

  Future<({List<RoomInviteModel> incoming, List<RoomInviteModel> outgoing})>
  load() async {
    final response = await _api.get(ApiEndpoints.invites);
    final data = Map<String, dynamic>.from(
      response['data'] as Map? ?? const {},
    );
    List<RoomInviteModel> parse(String key) =>
        (data[key] as List<dynamic>? ?? const [])
            .map(
              (item) => RoomInviteModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList();
    return (incoming: parse('incoming'), outgoing: parse('outgoing'));
  }

  Future<RoomInviteModel> send(String friendId, String roomCode) =>
      _action('', data: {'toUserId': friendId, 'roomCode': roomCode});

  Future<RoomInviteModel> accept(String id) => _action('/$id/accept');
  Future<RoomInviteModel> decline(String id) => _action('/$id/decline');
  Future<RoomInviteModel> cancel(String id) => _action('/$id/cancel');

  Future<RoomInviteModel> _action(
    String suffix, {
    Map<String, dynamic>? data,
  }) async {
    final response = await _api.post(
      '${ApiEndpoints.invites}$suffix',
      data: data,
    );
    final body = Map<String, dynamic>.from(
      response['data'] as Map? ?? const {},
    );
    return RoomInviteModel.fromJson(
      Map<String, dynamic>.from(body['invite'] as Map? ?? const {}),
    );
  }
}
