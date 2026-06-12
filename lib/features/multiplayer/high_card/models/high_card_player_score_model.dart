import 'package:cardverse/features/multiplayer/models/room_player_model.dart';

class HighCardPlayerScoreModel {
  const HighCardPlayerScoreModel({required this.player, required this.score});

  final RoomPlayerModel player;
  final int score;
}
