import 'package:cardverse/features/multiplayer/models/room_player_model.dart';

class MultiplayerGameConfigModel {
  const MultiplayerGameConfigModel({
    required this.roomCode,
    required this.gameType,
    required this.gameName,
    required this.maxPlayers,
    required this.players,
    required this.settings,
  });

  final String roomCode;
  final String gameType;
  final String gameName;
  final int maxPlayers;
  final List<RoomPlayerModel> players;
  final Map<String, dynamic> settings;
}
