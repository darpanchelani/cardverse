import 'package:cardverse/features/multiplayer/models/friend_model.dart';
import 'package:cardverse/features/multiplayer/services/multiplayer_friend_service.dart';
import 'package:flutter/foundation.dart';

class FriendsController extends ChangeNotifier {
  FriendsController(this._service);

  final MultiplayerFriendService _service;

  List<FriendModel> friends = [];
  List<FriendModel> searchResults = [];
  bool isLoading = false;
  bool hasLoaded = false;
  String? errorMessage;
  String? actionMessage;

  Future<void> loadFriends() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      friends = await _service.getFriends();
      searchResults = List.of(friends);
    } catch (_) {
      errorMessage = 'Could not load friends.';
    } finally {
      hasLoaded = true;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchFriends(String query) async {
    searchResults = await _service.searchFriends(query);
    notifyListeners();
  }

  Future<void> sendFriendRequest(String username) async {
    await _service.sendFriendRequest(username);
    actionMessage = 'Friend request sent to $username.';
    notifyListeners();
  }

  Future<void> removeFriend(String friendId) async {
    await _service.removeFriend(friendId);
    friends.removeWhere((friend) => friend.id == friendId);
    searchResults.removeWhere((friend) => friend.id == friendId);
    actionMessage = 'Friend removed.';
    notifyListeners();
  }

  Future<void> refreshFriends() => loadFriends();

  void consumeActionMessage() {
    actionMessage = null;
  }
}
