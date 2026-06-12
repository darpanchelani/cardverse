import 'package:cardverse/features/multiplayer/war/models/war_game_state_model.dart';
import 'package:cardverse/features/multiplayer/war/widgets/war_multiplayer_player_area_widget.dart';
import 'package:flutter/material.dart';

class WarMultiplayerTableWidget extends StatelessWidget {
  const WarMultiplayerTableWidget({
    required this.state,
    required this.currentUserId,
    super.key,
  });

  final WarGameStateModel state;
  final String currentUserId;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 680
          ? state.players.length.clamp(2, 4)
          : 2;
      final ratio = constraints.maxWidth < 380 ? 0.57 : 0.63;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.players.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: ratio,
        ),
        itemBuilder: (context, index) {
          final player = state.players[index];
          return WarMultiplayerPlayerAreaWidget(
            player: player,
            card: state.currentBattleCards[player.id],
            score: state.scores[player.id] ?? 0,
            cardCount: state.cardCounts[player.id] ?? 0,
            isCurrentUser: player.id == currentUserId,
            isBattleWinner: state.battleResult?.winnerId == player.id,
          );
        },
      );
    },
  );
}
