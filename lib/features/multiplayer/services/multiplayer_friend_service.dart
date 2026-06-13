import 'package:cardverse/features/multiplayer/models/friend_model.dart';

abstract interface class MultiplayerFriendService {
  Future<List<FriendModel>> getFriends();
  Future<List<FriendModel>> searchFriends(String query);
  Future<void> sendFriendRequest(String username);
  Future<void> removeFriend(String friendId);
}
