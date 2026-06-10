import 'package:cardverse/features/multiplayer/models/friend_model.dart';

class DummyFriendService {
  DummyFriendService() : _friends = _buildFriends();

  // TODO: Replace with the backend friend API in a later phase.
  final List<FriendModel> _friends;

  Future<List<FriendModel>> getFriends() async => List.of(_friends);

  Future<List<FriendModel>> searchFriends(String query) async {
    final normalized = query.trim().toLowerCase();
    if (normalized.isEmpty) return getFriends();
    return _friends
        .where((friend) => friend.username.toLowerCase().contains(normalized))
        .toList();
  }

  Future<void> sendFriendRequest(String username) async {}

  Future<void> removeFriend(String friendId) async {
    _friends.removeWhere((friend) => friend.id == friendId);
  }

  static List<FriendModel> _buildFriends() {
    final now = DateTime.now();
    return [
      FriendModel(
        id: 'friend_ali',
        username: 'Ali',
        avatar: 'A',
        isOnline: true,
        status: 'online',
        level: 7,
        wins: 95,
        coins: 2500,
        lastSeenAt: now,
      ),
      FriendModel(
        id: 'friend_sara',
        username: 'Sara',
        avatar: 'S',
        isOnline: true,
        status: 'in_game',
        level: 6,
        wins: 80,
        coins: 2100,
        lastSeenAt: now,
      ),
      FriendModel(
        id: 'friend_ahmed',
        username: 'Ahmed',
        avatar: 'A',
        isOnline: false,
        status: 'offline',
        level: 5,
        wins: 60,
        coins: 1600,
        lastSeenAt: now.subtract(const Duration(hours: 3)),
      ),
      FriendModel(
        id: 'friend_meera',
        username: 'Meera',
        avatar: 'M',
        isOnline: true,
        status: 'online',
        level: 4,
        wins: 42,
        coins: 1250,
        lastSeenAt: now,
      ),
      FriendModel(
        id: 'friend_zain',
        username: 'Zain',
        avatar: 'Z',
        isOnline: true,
        status: 'away',
        level: 3,
        wins: 28,
        coins: 900,
        lastSeenAt: now.subtract(const Duration(minutes: 18)),
      ),
    ];
  }
}
