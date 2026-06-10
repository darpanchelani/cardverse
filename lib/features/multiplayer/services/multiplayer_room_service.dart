import 'package:cardverse/features/multiplayer/models/room_model.dart';

abstract class MultiplayerRoomService {
  bool get isConnected;

  Future<void> connectIfNeeded();

  Future<RoomModel> createRoom({
    required String gameType,
    required String gameName,
    required int maxPlayers,
    required bool isPrivate,
    required bool allowBots,
    required bool allowChat,
    required Map<String, dynamic> settings,
  });

  Future<RoomModel> joinRoom(String roomCode);
  Future<void> leaveRoom(String roomCode);
  Future<List<RoomModel>> getPublicRooms();
  Future<RoomModel> toggleReady(RoomModel room, String playerId);
  Future<RoomModel> addBot(RoomModel room);
  Future<RoomModel> removePlayer(RoomModel room, String playerId);
  Future<RoomModel> startGame(RoomModel room);

  void listenRoomEvents({
    required void Function(RoomModel room) onRoomUpdated,
    required void Function(List<RoomModel> rooms) onPublicRooms,
    required void Function(RoomModel room) onGameStarting,
    required void Function(String message) onError,
  });

  void disposeListeners();
}
