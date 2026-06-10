import 'package:cardverse/features/multiplayer/models/multiplayer_game_config_model.dart';
import 'package:cardverse/features/multiplayer/models/room_model.dart';
import 'package:cardverse/features/multiplayer/services/dummy_room_service.dart';
import 'package:flutter/foundation.dart';

class RoomController extends ChangeNotifier {
  RoomController(this._service);

  final DummyRoomService _service;
  bool _isActing = false;

  RoomModel? currentRoom;
  List<RoomModel> publicRooms = [];
  bool isLoading = false;
  String? errorMessage;

  bool get isCurrentUserHost =>
      currentRoom?.players.any(
        (player) => player.id == 'current_user' && player.isHost,
      ) ??
      false;

  bool get canStartGame {
    final room = currentRoom;
    return room != null &&
        isCurrentUserHost &&
        room.players.length >= 2 &&
        room.allPlayersReady;
  }

  Future<RoomModel?> createRoom({
    required String gameType,
    required String gameName,
    required int maxPlayers,
    required bool isPrivate,
    required bool allowBots,
    required bool allowChat,
    required Map<String, dynamic> settings,
  }) async {
    if (_isActing) return currentRoom;
    _isActing = true;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      currentRoom = await _service.createRoom(
        gameType: gameType,
        gameName: gameName,
        maxPlayers: maxPlayers,
        isPrivate: isPrivate,
        allowBots: allowBots,
        allowChat: allowChat,
        settings: settings,
      );
      return currentRoom;
    } catch (_) {
      errorMessage = 'Could not create the room.';
      return null;
    } finally {
      _isActing = false;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<RoomModel?> joinRoom(String roomCode) async {
    if (_isActing) return currentRoom;
    _isActing = true;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      currentRoom = await _service.joinRoom(roomCode);
      return currentRoom;
    } on StateError catch (error) {
      errorMessage = error.message;
      return null;
    } catch (_) {
      errorMessage = 'Could not join this room.';
      return null;
    } finally {
      _isActing = false;
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> leaveRoom() async {
    final room = currentRoom;
    if (room == null || _isActing) return;
    _isActing = true;
    try {
      await _service.leaveRoom(room.roomCode);
      currentRoom = null;
    } finally {
      _isActing = false;
      notifyListeners();
    }
  }

  Future<void> loadPublicRooms() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      publicRooms = await _service.getPublicRooms();
    } catch (_) {
      errorMessage = 'Could not load public rooms.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleReady() async {
    final room = currentRoom;
    if (room == null || _isActing) return false;
    _isActing = true;
    try {
      currentRoom = await _service.toggleReady(room, 'current_user');
      return true;
    } finally {
      _isActing = false;
      notifyListeners();
    }
  }

  Future<bool> addBot() async {
    final room = currentRoom;
    if (room == null || _isActing) return false;
    _isActing = true;
    errorMessage = null;
    try {
      currentRoom = await _service.addBot(room);
      return true;
    } on StateError catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      _isActing = false;
      notifyListeners();
    }
  }

  Future<void> removePlayer(String playerId) async {
    final room = currentRoom;
    if (room == null || _isActing) return;
    _isActing = true;
    try {
      currentRoom = await _service.removePlayer(room, playerId);
    } finally {
      _isActing = false;
      notifyListeners();
    }
  }

  MultiplayerGameConfigModel? startGame() {
    final room = currentRoom;
    if (room == null || !canStartGame) return null;
    currentRoom = room.copyWith(status: 'playing');
    notifyListeners();
    return MultiplayerGameConfigModel(
      roomCode: room.roomCode,
      gameType: room.gameType,
      gameName: room.gameName,
      maxPlayers: room.maxPlayers,
      players: room.players,
      settings: room.settings,
    );
  }

  void clearRoom() {
    currentRoom = null;
    errorMessage = null;
    notifyListeners();
  }
}
