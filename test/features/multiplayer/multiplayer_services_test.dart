import 'package:cardverse/features/multiplayer/controllers/chat_controller.dart';
import 'package:cardverse/features/multiplayer/controllers/friends_controller.dart';
import 'package:cardverse/features/multiplayer/controllers/invite_controller.dart';
import 'package:cardverse/features/multiplayer/controllers/room_controller.dart';
import 'package:cardverse/features/multiplayer/services/dummy_chat_service.dart';
import 'package:cardverse/features/multiplayer/services/dummy_friend_service.dart';
import 'package:cardverse/features/multiplayer/services/dummy_room_service.dart';
import 'package:cardverse/features/multiplayer/services/room_code_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoomCodeService', () {
    test('generates valid six-character room codes', () {
      final service = RoomCodeService();

      for (var index = 0; index < 50; index++) {
        final code = service.generateRoomCode();
        expect(code, hasLength(6));
        expect(service.isValidRoomCode(code), isTrue);
      }
    });

    test('rejects malformed room codes', () {
      final service = RoomCodeService();

      expect(service.isValidRoomCode('ABC12'), isFalse);
      expect(service.isValidRoomCode('ABC-12'), isFalse);
      expect(service.isValidRoomCode('abcdef'), isTrue);
    });
  });

  test('room lifecycle supports bots, readiness, and game config', () async {
    final controller = RoomController(DummyRoomService(RoomCodeService()));

    final room = await controller.createRoom(
      gameType: 'war',
      gameName: 'War',
      maxPlayers: 2,
      isPrivate: true,
      allowBots: true,
      allowChat: true,
      settings: const {'turnTimeSeconds': 30, 'difficulty': 'Normal'},
    );

    expect(room, isNotNull);
    expect(room!.roomCode, hasLength(6));
    expect(room.players.single.isHost, isTrue);
    expect(controller.canStartGame, isFalse);

    expect(await controller.addBot(), isTrue);
    expect(controller.currentRoom?.isFull, isTrue);
    expect(await controller.addBot(), isFalse);

    await controller.toggleReady();
    expect(controller.canStartGame, isTrue);

    expect(await controller.startGame(), isTrue);
    expect(controller.gameStartingConfig?.gameType, 'war');
    expect(controller.gameStartingConfig?.players, hasLength(2));
    expect(controller.currentRoom?.status, 'playing');
  });

  test('chat blocks empty messages and keeps room messages', () async {
    final controller = ChatController(DummyChatService());
    await controller.loadMessages('AB12CD');

    expect(await controller.sendMessage('   '), isFalse);
    expect(controller.messages, isEmpty);

    expect(await controller.sendMessage('Ready to play?'), isTrue);
    expect(await controller.sendMessage('Second message'), isTrue);

    expect(controller.messages, hasLength(2));
    expect(controller.messages.last.message, 'Second message');
  });

  test('friend search and removal update local controller state', () async {
    final controller = FriendsController(DummyFriendService());
    await controller.loadFriends();

    expect(controller.friends, hasLength(5));
    await controller.searchFriends('mee');
    expect(controller.searchResults.single.username, 'Meera');

    await controller.removeFriend('friend_meera');
    expect(
      controller.friends.any((friend) => friend.id == 'friend_meera'),
      isFalse,
    );
  });

  test('invite controller accepts and declines local invites', () async {
    final controller = InviteController();
    await controller.loadInvites();
    final pending = controller.invites
        .where((invite) => invite.status == 'pending')
        .toList();

    await controller.acceptInvite(pending.first);
    await controller.declineInvite(pending.last);

    expect(
      controller.invites
          .firstWhere((invite) => invite.id == pending.first.id)
          .status,
      'accepted',
    );
    expect(
      controller.invites
          .firstWhere((invite) => invite.id == pending.last.id)
          .status,
      'declined',
    );
  });
}
