import 'dart:async';

import 'package:cardverse/features/multiplayer/controllers/chat_controller.dart';
import 'package:cardverse/features/multiplayer/controllers/friends_controller.dart';
import 'package:cardverse/features/multiplayer/controllers/invite_controller.dart';
import 'package:cardverse/features/multiplayer/controllers/room_controller.dart';
import 'package:cardverse/features/multiplayer/controllers/socket_connection_controller.dart';
import 'package:cardverse/core/network/socket_service.dart';
import 'package:cardverse/features/multiplayer/services/dummy_chat_service.dart';
import 'package:cardverse/features/multiplayer/services/dummy_friend_service.dart';
import 'package:cardverse/features/multiplayer/services/dummy_room_service.dart';
import 'package:cardverse/features/multiplayer/services/room_code_service.dart';
import 'package:cardverse/features/multiplayer/services/socket_chat_service.dart';
import 'package:cardverse/features/multiplayer/services/socket_room_service.dart';
import 'package:flutter/widgets.dart';

class MultiplayerControllers {
  MultiplayerControllers({
    required this.friends,
    required this.room,
    required this.chat,
    required this.invites,
    required this.connection,
  });

  factory MultiplayerControllers.create({
    String userId = 'guest_local_user',
    String username = 'Guest Player',
    int level = 1,
  }) {
    final socket = SocketService();
    final connection = SocketConnectionController(
      socketService: socket,
      userId: userId,
      username: username,
      level: level,
    );
    final controllers = MultiplayerControllers(
      friends: FriendsController(DummyFriendService()),
      room: RoomController(
        SocketRoomService(socket, connection),
        localUserId: userId,
      ),
      chat: ChatController(SocketChatService(socket)),
      invites: InviteController(),
      connection: connection,
    );
    unawaited(controllers.friends.loadFriends());
    unawaited(controllers.invites.loadInvites());
    return controllers;
  }

  static final MultiplayerControllers instance =
      MultiplayerControllers.create();

  final FriendsController friends;
  final RoomController room;
  final ChatController chat;
  final InviteController invites;
  final SocketConnectionController connection;

  factory MultiplayerControllers.dummy() {
    final socket = SocketService();
    return MultiplayerControllers(
      friends: FriendsController(DummyFriendService()),
      room: RoomController(
        DummyRoomService(RoomCodeService()),
        localUserId: 'current_user',
      ),
      chat: ChatController(DummyChatService()),
      invites: InviteController(),
      connection: SocketConnectionController(
        socketService: socket,
        userId: 'current_user',
        username: 'Guest Player',
      ),
    );
  }
}

class MultiplayerScope extends InheritedWidget {
  const MultiplayerScope({
    required this.controllers,
    required super.child,
    super.key,
  });

  final MultiplayerControllers controllers;

  static MultiplayerControllers of(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<MultiplayerScope>();
    assert(scope != null, 'MultiplayerScope is missing above this context.');
    return scope!.controllers;
  }

  @override
  bool updateShouldNotify(MultiplayerScope oldWidget) =>
      controllers != oldWidget.controllers;
}
