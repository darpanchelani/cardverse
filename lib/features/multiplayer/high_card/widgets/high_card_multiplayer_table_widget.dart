import 'package:cardverse/features/multiplayer/high_card/models/high_card_game_state_model.dart';
import 'package:cardverse/features/multiplayer/high_card/widgets/high_card_multiplayer_player_card_widget.dart';
import 'package:flutter/material.dart';

class HighCardMultiplayerTableWidget extends StatelessWidget {
  const HighCardMultiplayerTableWidget({
    required this.state,
    required this.currentUserId,
    super.key,
  });

  final HighCardGameStateModel state;
  final String currentUserId;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 680
          ? state.players.length.clamp(2, 4)
          : 2;
      final ratio = constraints.maxWidth < 380 ? 0.58 : 0.64;
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
          return HighCardMultiplayerPlayerCardWidget(
            player: player,
            card: state.currentCards[player.id],
            score: state.scores[player.id] ?? 0,
            isCurrentUser: player.id == currentUserId,
            isRoundWinner: state.roundResult?.winnerId == player.id,
          );
        },
      );
    },
  );
}
