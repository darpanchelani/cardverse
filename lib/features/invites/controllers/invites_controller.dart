import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/invites/models/room_invite_model.dart';
import 'package:cardverse/features/invites/services/invites_api_service.dart';
import 'package:cardverse/features/invites/services/socket_invites_service.dart';
import 'package:flutter/foundation.dart';

class InvitesController extends ChangeNotifier {
  InvitesController({
    required InvitesApiService api,
    required SocketInvitesService socket,
    required AuthController auth,
  }) : _api = api,
       _socket = socket,
       _auth = auth {
    _socket.listen(
      onReceived: handleIncomingInvite,
      onAccepted: (json) => _replace(RoomInviteModel.fromJson(json)),
      onDeclined: (json) => _replace(RoomInviteModel.fromJson(json)),
      onCancelled: (json) => _replace(RoomInviteModel.fromJson(json)),
    );
  }

  final InvitesApiService _api;
  final SocketInvitesService _socket;
  final AuthController _auth;

  List<RoomInviteModel> incomingInvites = [];
  List<RoomInviteModel> outgoingInvites = [];
  bool isLoading = false;
  String? errorMessage;
  RoomInviteModel? latestIncomingInvite;

  List<RoomInviteModel> get invites => [...incomingInvites, ...outgoingInvites];

  Future<void> loadInvites() async {
    if (!_auth.isAuthenticated) {
      incomingInvites = [];
      outgoingInvites = [];
      notifyListeners();
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _api.load();
      incomingInvites = result.incoming;
      outgoingInvites = result.outgoing;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<RoomInviteModel?> sendInvite(String friendId, String roomCode) async {
    if (!_auth.isAuthenticated) {
      errorMessage = 'Login to invite friends.';
      notifyListeners();
      return null;
    }
    try {
      final invite = await _api.send(friendId, roomCode);
      outgoingInvites = [invite, ...outgoingInvites];
      errorMessage = null;
      notifyListeners();
      return invite;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      return null;
    }
  }

  Future<RoomInviteModel> acceptInvite(RoomInviteModel invite) async {
    final updated = await _api.accept(invite.id);
    _replace(updated);
    return updated;
  }

  Future<void> declineInvite(RoomInviteModel invite) async {
    _replace(await _api.decline(invite.id));
  }

  Future<void> cancelInvite(RoomInviteModel invite) async {
    _replace(await _api.cancel(invite.id));
  }

  void handleIncomingInvite(Map<String, dynamic> json) {
    final invite = RoomInviteModel.fromJson(json);
    if (incomingInvites.any((item) => item.id == invite.id)) return;
    incomingInvites = [invite, ...incomingInvites];
    latestIncomingInvite = invite;
    notifyListeners();
  }

  void keepForLater() {
    latestIncomingInvite = null;
  }

  void _replace(RoomInviteModel updated) {
    incomingInvites = incomingInvites
        .map((item) => item.id == updated.id ? updated : item)
        .toList();
    outgoingInvites = outgoingInvites
        .map((item) => item.id == updated.id ? updated : item)
        .toList();
    if (latestIncomingInvite?.id == updated.id) latestIncomingInvite = null;
    notifyListeners();
  }

  void clear() {
    incomingInvites = [];
    outgoingInvites = [];
    latestIncomingInvite = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _socket.disposeListeners();
    super.dispose();
  }
}
