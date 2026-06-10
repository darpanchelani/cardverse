import 'package:cardverse/features/multiplayer/controllers/multiplayer_scope.dart';
import 'package:cardverse/features/multiplayer/screens/friends_screen.dart';
import 'package:cardverse/features/multiplayer/screens/room_lobby_screen.dart';
import 'package:cardverse/features/rooms/join_room_screen.dart';
import 'package:cardverse/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MultiplayerControllers controllers;

  setUp(() async {
    controllers = MultiplayerControllers.dummy();
    await controllers.friends.loadFriends();
    await controllers.invites.loadInvites();
  });

  testWidgets('join room validates empty and malformed codes', (tester) async {
    await tester.pumpWidget(_app(const JoinRoomScreen(), controllers));

    final joinButton = find.widgetWithText(CustomButton, 'Join Room');
    await tester.ensureVisible(joinButton);
    await tester.tap(joinButton);
    await tester.pump();
    expect(find.text('Room code is required.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField), 'ABC');
    await tester.tap(joinButton);
    await tester.pump();
    expect(find.text('Enter a valid 6-character room code.'), findsOneWidget);
  });

  testWidgets('friends screen filters dummy friends', (tester) async {
    await tester.pumpWidget(_app(const FriendsScreen(), controllers));

    expect(find.text('Ali'), findsWidgets);
    expect(find.text('Meera'), findsWidgets);

    await tester.enterText(find.byType(TextField), 'Zain');
    await tester.pump();

    expect(find.text('Zain'), findsWidgets);
    expect(find.text('Meera'), findsNothing);
  });

  testWidgets('lobby adds a bot and toggles current player ready', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(800, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final room = await controllers.room.createRoom(
      gameType: 'high_card',
      gameName: 'High Card',
      maxPlayers: 2,
      isPrivate: true,
      allowBots: true,
      allowChat: true,
      settings: const {'turnTimeSeconds': 30, 'difficulty': 'Normal'},
    );
    await controllers.chat.loadMessages(room!.roomCode);

    await tester.pumpWidget(
      _app(RoomLobbyScreen(roomCode: room.roomCode), controllers),
    );
    await tester.pumpAndSettle();

    expect(find.text('Waiting for player...'), findsOneWidget);
    final lobbyList = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(
      find.text('Mark Ready'),
      250,
      scrollable: lobbyList,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mark Ready'));
    await tester.pumpAndSettle();
    expect(controllers.room.canStartGame, isFalse);

    await tester.scrollUntilVisible(
      find.text('Add Bot'),
      200,
      scrollable: lobbyList,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Bot'));
    await tester.pumpAndSettle();
    expect(controllers.room.currentRoom?.players, hasLength(2));
    expect(controllers.room.currentRoom?.players.last.isBot, isTrue);
    expect(controllers.room.canStartGame, isTrue);
    expect(
      controllers.room.currentRoom?.players
          .firstWhere((player) => player.id == 'current_user')
          .isReady,
      isTrue,
    );
  });
}

Widget _app(Widget child, MultiplayerControllers controllers) {
  return MultiplayerScope(
    controllers: controllers,
    child: MaterialApp(theme: ThemeData.dark(useMaterial3: true), home: child),
  );
}
