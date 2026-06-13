import 'package:cardverse/features/multiplayer/models/multiplayer_game_config_model.dart';
import 'package:cardverse/features/multiplayer/models/room_model.dart';
import 'package:cardverse/features/multiplayer/services/multiplayer_room_service.dart';
import 'package:flutter/foundation.dart';

class RoomController extends ChangeNotifier {
  RoomController(this._service, {this.localUserId = 'current_user'}) {
    _service.listenRoomEvents(
      onRoomUpdated: _onRoomUpdated,
      onPublicRooms: _onPublicRooms,
      onGameStarting: _onGameStarting,
      onError: _onError,
    );
  }

  final MultiplayerRoomService _service;
  String localUserId;
  bool _isActing = false;

  RoomModel? currentRoom;
  List<RoomModel> publicRooms = [];
  bool isLoading = false;
  String? errorMessage;
  MultiplayerGameConfigModel? gameStartingConfig;
  int gameStartRevision = 0;

  bool get isConnected => _service.isConnected;

  void updateIdentity(String userId) {
    localUserId = userId;
    clearRoom();
  }

  bool get isCurrentUserHost =>
      currentRoom?.players.any(
        (player) => player.id == localUserId && player.isHost,
      ) ??
      false;

  bool get canStartGame {
    final room = currentRoom;
    return room != null &&
        isCurrentUserHost &&
        room.players.length >= 2 &&
        room.players
            .where((player) => !player.isBot)
            .every((player) => player.isReady);
  }

  Future<bool> connectIfNeeded() async {
    try {
      await _service.connectIfNeeded();
      notifyListeners();
      return isConnected;
    } catch (error) {
      errorMessage = _message(error, 'Backend is unavailable.');
      notifyListeners();
      return false;
    }
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
    _beginAction();
    try {
      await _service.connectIfNeeded();
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
    } catch (error) {
      errorMessage = _message(error, 'Could not create the room.');
      return null;
    } finally {
      _endAction();
    }
  }

  Future<RoomModel?> joinRoom(String roomCode) async {
    if (_isActing) return currentRoom;
    _beginAction();
    try {
      await _service.connectIfNeeded();
      currentRoom = await _service.joinRoom(roomCode);
      return currentRoom;
    } catch (error) {
      errorMessage = _message(error, 'Could not join this room.');
      return null;
    } finally {
      _endAction();
    }
  }

  Future<void> leaveRoom() async {
    final room = currentRoom;
    if (room == null || _isActing) return;
    _isActing = true;
    try {
      await _service.leaveRoom(room.roomCode);
      currentRoom = null;
    } catch (error) {
      errorMessage = _message(error, 'Could not leave the room.');
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
      await _service.connectIfNeeded();
      publicRooms = await _service.getPublicRooms();
    } catch (error) {
      errorMessage = _message(error, 'Could not load public rooms.');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleReady() async {
    final room = currentRoom;
    if (room == null || _isActing || !isConnected) return false;
    _isActing = true;
    try {
      currentRoom = await _service.toggleReady(room, localUserId);
      return true;
    } catch (error) {
      errorMessage = _message(error, 'Could not update ready status.');
      return false;
    } finally {
      _isActing = false;
      notifyListeners();
    }
  }

  Future<bool> addBot() async {
    final room = currentRoom;
    if (room == null || _isActing || !isConnected) return false;
    _isActing = true;
    errorMessage = null;
    try {
      currentRoom = await _service.addBot(room);
      return true;
    } catch (error) {
      errorMessage = _message(error, 'Could not add a bot.');
      return false;
    } finally {
      _isActing = false;
      notifyListeners();
    }
  }

  Future<void> removePlayer(String playerId) async {
    final room = currentRoom;
    if (room == null || _isActing || !isConnected) return;
    _isActing = true;
    try {
      currentRoom = await _service.removePlayer(room, playerId);
    } catch (error) {
      errorMessage = _message(error, 'Could not remove the bot.');
    } finally {
      _isActing = false;
      notifyListeners();
    }
  }

  Future<bool> startGame() async {
    final room = currentRoom;
    if (room == null || _isActing || !isConnected) return false;
    _isActing = true;
    final revisionBeforeRequest = gameStartRevision;
    try {
      currentRoom = await _service.startGame(room);
      if (gameStartRevision == revisionBeforeRequest && currentRoom != null) {
        _onGameStarting(currentRoom!);
      }
      return true;
    } catch (error) {
      errorMessage = _message(error, 'Could not start the game.');
      return false;
    } finally {
      _isActing = false;
      notifyListeners();
    }
  }

  void clearRoom() {
    currentRoom = null;
    errorMessage = null;
    gameStartingConfig = null;
    notifyListeners();
  }

  void _onRoomUpdated(RoomModel room) {
    if (currentRoom == null || currentRoom!.roomCode == room.roomCode) {
      currentRoom = room;
      notifyListeners();
    }
  }

  void _onPublicRooms(List<RoomModel> rooms) {
    publicRooms = rooms;
    notifyListeners();
  }

  void _onGameStarting(RoomModel room) {
    currentRoom = room;
    gameStartingConfig = _config(room);
    gameStartRevision++;
    notifyListeners();
  }

  void _onError(String message) {
    errorMessage = message;
    notifyListeners();
  }

  MultiplayerGameConfigModel _config(RoomModel room) =>
      MultiplayerGameConfigModel(
        roomCode: room.roomCode,
        gameType: room.gameType,
        gameName: room.gameName,
        maxPlayers: room.maxPlayers,
        players: room.players,
        settings: room.settings,
      );

  void _beginAction() {
    _isActing = true;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
  }

  void _endAction() {
    _isActing = false;
    isLoading = false;
    notifyListeners();
  }

  String _message(Object error, String fallback) {
    if (error is StateError) return error.message;
    return error.toString().replaceFirst('Exception: ', '').trim().isEmpty
        ? fallback
        : error.toString().replaceFirst('Exception: ', '');
  }

  @override
  void dispose() {
    _service.disposeListeners();
    super.dispose();
  }
}
