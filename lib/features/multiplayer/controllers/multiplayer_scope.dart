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
import 'package:cardverse/features/multiplayer/high_card/controllers/high_card_multiplayer_controller.dart';
import 'package:cardverse/features/multiplayer/high_card/services/socket_high_card_service.dart';
import 'package:cardverse/features/multiplayer/war/controllers/war_multiplayer_controller.dart';
import 'package:cardverse/features/multiplayer/war/services/socket_war_service.dart';
import 'package:cardverse/features/multiplayer/blackjack/controllers/blackjack_multiplayer_controller.dart';
import 'package:cardverse/features/multiplayer/blackjack/services/socket_blackjack_service.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:flutter/widgets.dart';

class MultiplayerControllers {
  MultiplayerControllers({
    required this.friends,
    required this.room,
    required this.chat,
    required this.invites,
    required this.connection,
    required this.highCard,
    required this.war,
    required this.blackjack,
  });

  factory MultiplayerControllers.create({
    String userId = 'guest_local_user',
    String username = 'Guest Player',
    int level = 1,
    ProgressController? progressController,
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
      highCard: HighCardMultiplayerController(
        service: SocketHighCardService(socket),
        currentUserId: userId,
        progressController: progressController,
      ),
      war: WarMultiplayerController(
        service: SocketWarService(socket),
        currentUserId: userId,
        progressController: progressController,
      ),
      blackjack: BlackjackMultiplayerController(
        service: SocketBlackjackService(socket),
        currentUserId: userId,
        progressController: progressController,
      ),
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
  final HighCardMultiplayerController highCard;
  final WarMultiplayerController war;
  final BlackjackMultiplayerController blackjack;

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
      highCard: HighCardMultiplayerController(
        service: SocketHighCardService(socket),
        currentUserId: 'current_user',
      ),
      war: WarMultiplayerController(
        service: SocketWarService(socket),
        currentUserId: 'current_user',
      ),
      blackjack: BlackjackMultiplayerController(
        service: SocketBlackjackService(socket),
        currentUserId: 'current_user',
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
