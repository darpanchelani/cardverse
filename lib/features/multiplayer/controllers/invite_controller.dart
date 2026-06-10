import 'package:cardverse/features/multiplayer/models/friend_model.dart';
import 'package:cardverse/features/multiplayer/models/invite_model.dart';
import 'package:cardverse/features/multiplayer/models/room_model.dart';
import 'package:flutter/foundation.dart';

class InviteController extends ChangeNotifier {
  List<InviteModel> invites = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadInvites() async {
    isLoading = true;
    notifyListeners();
    final now = DateTime.now();
    if (invites.isEmpty) {
      invites = [
        InviteModel(
          id: 'invite_ali',
          roomCode: 'AL12CD',
          fromUserId: 'friend_ali',
          fromUsername: 'Ali',
          toUserId: 'current_user',
          toUsername: 'Guest Player',
          gameName: 'War',
          status: 'pending',
          createdAt: now.subtract(const Duration(minutes: 4)),
        ),
        InviteModel(
          id: 'invite_meera',
          roomCode: 'ME34RA',
          fromUserId: 'friend_meera',
          fromUsername: 'Meera',
          toUserId: 'current_user',
          toUsername: 'Guest Player',
          gameName: 'Blackjack',
          status: 'pending',
          createdAt: now.subtract(const Duration(minutes: 18)),
        ),
        InviteModel(
          id: 'invite_sara',
          roomCode: 'SA56RA',
          fromUserId: 'friend_sara',
          fromUsername: 'Sara',
          toUserId: 'current_user',
          toUsername: 'Guest Player',
          gameName: 'High Card',
          status: 'declined',
          createdAt: now.subtract(const Duration(hours: 2)),
        ),
      ];
    }
    isLoading = false;
    notifyListeners();
  }

  Future<InviteModel> sendInvite(FriendModel friend, RoomModel room) async {
    final invite = InviteModel(
      id: 'sent_${DateTime.now().microsecondsSinceEpoch}',
      roomCode: room.roomCode,
      fromUserId: 'current_user',
      fromUsername: 'Guest Player',
      toUserId: friend.id,
      toUsername: friend.username,
      gameName: room.gameName,
      status: 'pending',
      createdAt: DateTime.now(),
    );
    invites = [invite, ...invites];
    notifyListeners();
    return invite;
  }

  Future<InviteModel> acceptInvite(InviteModel invite) async {
    final updated = invite.copyWith(status: 'accepted');
    _replace(updated);
    return updated;
  }

  Future<void> declineInvite(InviteModel invite) async {
    _replace(invite.copyWith(status: 'declined'));
  }

  void _replace(InviteModel updated) {
    invites = invites
        .map((invite) => invite.id == updated.id ? updated : invite)
        .toList();
    notifyListeners();
  }
}
