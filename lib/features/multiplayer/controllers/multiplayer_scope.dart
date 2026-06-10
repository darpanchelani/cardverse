import 'dart:async';

import 'package:cardverse/features/multiplayer/controllers/chat_controller.dart';
import 'package:cardverse/features/multiplayer/controllers/friends_controller.dart';
import 'package:cardverse/features/multiplayer/controllers/invite_controller.dart';
import 'package:cardverse/features/multiplayer/controllers/room_controller.dart';
import 'package:cardverse/features/multiplayer/services/dummy_chat_service.dart';
import 'package:cardverse/features/multiplayer/services/dummy_friend_service.dart';
import 'package:cardverse/features/multiplayer/services/dummy_room_service.dart';
import 'package:cardverse/features/multiplayer/services/room_code_service.dart';
import 'package:flutter/widgets.dart';

class MultiplayerControllers {
  MultiplayerControllers({
    required this.friends,
    required this.room,
    required this.chat,
    required this.invites,
  });

  factory MultiplayerControllers.create() {
    final controllers = MultiplayerControllers(
      friends: FriendsController(DummyFriendService()),
      room: RoomController(DummyRoomService(RoomCodeService())),
      chat: ChatController(DummyChatService()),
      invites: InviteController(),
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
