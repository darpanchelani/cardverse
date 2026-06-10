import 'dart:async';

import 'package:cardverse/core/network/socket_service.dart';
import 'package:cardverse/features/multiplayer/controllers/socket_connection_controller.dart';
import 'package:cardverse/features/multiplayer/models/room_model.dart';
import 'package:cardverse/features/multiplayer/services/multiplayer_room_service.dart';

class SocketRoomService implements MultiplayerRoomService {
  SocketRoomService(this._socket, this._connection) {
    _wasConnected = _connection.isConnected;
    _connection.addListener(_handleConnectionChange);
  }

  final SocketService _socket;
  final SocketConnectionController _connection;
  String? _activeRoomCode;
  bool _wasConnected = false;

  @override
  bool get isConnected => _connection.isConnected;

  @override
  Future<void> connectIfNeeded() async {
    if (!isConnected) await _connection.connect();
    if (!isConnected) throw StateError('Backend is unavailable.');
  }

  @override
  Future<RoomModel> createRoom({
    required String gameType,
    required String gameName,
    required int maxPlayers,
    required bool isPrivate,
    required bool allowBots,
    required bool allowChat,
    required Map<String, dynamic> settings,
  }) async {
    await connectIfNeeded();
    final response = await _socket.request(SocketEvents.roomCreate, {
      'gameType': gameType,
      'gameName': gameName,
      'maxPlayers': maxPlayers,
      'isPrivate': isPrivate,
      'allowBots': allowBots,
      'allowChat': allowChat,
      'settings': settings,
    });
    final room = _room(response['room']);
    _activeRoomCode = room.roomCode;
    return room;
  }

  @override
  Future<RoomModel> joinRoom(String roomCode) async {
    await connectIfNeeded();
    final response = await _socket.request(SocketEvents.roomJoin, {
      'roomCode': roomCode,
    });
    final room = _room(response['room']);
    _activeRoomCode = room.roomCode;
    return room;
  }

  @override
  Future<void> leaveRoom(String roomCode) async {
    if (isConnected) {
      await _socket.request(SocketEvents.roomLeave, {'roomCode': roomCode});
    }
    _activeRoomCode = null;
  }

  @override
  Future<List<RoomModel>> getPublicRooms() async {
    await connectIfNeeded();
    final response = await _socket.request(SocketEvents.roomGetPublic, {});
    return _rooms(response['rooms']);
  }

  @override
  Future<RoomModel> toggleReady(RoomModel room, String playerId) async {
    final response = await _socket.request(SocketEvents.roomToggleReady, {
      'roomCode': room.roomCode,
    });
    return _room(response['room']);
  }

  @override
  Future<RoomModel> addBot(RoomModel room) async {
    final response = await _socket.request(SocketEvents.roomAddBot, {
      'roomCode': room.roomCode,
    });
    return _room(response['room']);
  }

  @override
  Future<RoomModel> removePlayer(RoomModel room, String playerId) async {
    final response = await _socket.request(SocketEvents.roomRemoveBot, {
      'roomCode': room.roomCode,
      'botId': playerId,
    });
    return _room(response['room']);
  }

  @override
  Future<RoomModel> startGame(RoomModel room) async {
    final response = await _socket.request(SocketEvents.roomStartGame, {
      'roomCode': room.roomCode,
    });
    return _room(response['room']);
  }

  @override
  void listenRoomEvents({
    required void Function(RoomModel room) onRoomUpdated,
    required void Function(List<RoomModel> rooms) onPublicRooms,
    required void Function(RoomModel room) onGameStarting,
    required void Function(String message) onError,
  }) {
    _removeSocketListeners();
    _socket.on(SocketEvents.roomUpdated, (data) {
      onRoomUpdated(_room(data));
    });
    _socket.on(SocketEvents.roomPublicList, (data) {
      onPublicRooms(_rooms(data));
    });
    _socket.on(SocketEvents.roomGameStarting, (data) {
      onGameStarting(_room(data));
    });
    _socket.on(SocketEvents.roomError, (data) {
      onError(_error(data));
    });
  }

  @override
  void disposeListeners() {
    _removeSocketListeners();
    _connection.removeListener(_handleConnectionChange);
  }

  void _removeSocketListeners() {
    _socket.off(SocketEvents.roomUpdated);
    _socket.off(SocketEvents.roomPublicList);
    _socket.off(SocketEvents.roomGameStarting);
    _socket.off(SocketEvents.roomError);
  }

  void _handleConnectionChange() {
    final connected = _connection.isConnected;
    final shouldRestore =
        connected && !_wasConnected && _activeRoomCode != null;
    _wasConnected = connected;
    if (shouldRestore) unawaited(_restoreRoom());
  }

  Future<void> _restoreRoom() async {
    final roomCode = _activeRoomCode;
    if (roomCode == null) return;
    try {
      await _socket.request(SocketEvents.roomJoin, {'roomCode': roomCode});
    } catch (_) {
      // The room may have expired while this client was disconnected.
    }
  }

  RoomModel _room(dynamic data) => RoomModel.fromJson(_map(data));

  List<RoomModel> _rooms(dynamic data) {
    if (data is! List) return [];
    return data.map((item) => _room(item)).toList();
  }

  String _error(dynamic data) =>
      _map(data)['message'] as String? ?? 'Room request failed.';

  Map<String, dynamic> _map(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
