import 'package:cardverse/features/games/blackjack/blackjack_rules.dart';
import 'package:cardverse/features/multiplayer/blackjack/models/blackjack_game_state_model.dart';
import 'package:cardverse/features/multiplayer/blackjack/widgets/blackjack_multiplayer_player_hand_widget.dart';
import 'package:flutter/material.dart';

class BlackjackMultiplayerTableWidget extends StatelessWidget {
  const BlackjackMultiplayerTableWidget({
    required this.state,
    required this.currentUserId,
    super.key,
  });

  final BlackjackGameStateModel state;
  final String currentUserId;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final columns = constraints.maxWidth >= 650 ? 2 : 1;
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: state.players.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          mainAxisExtent: 190,
        ),
        itemBuilder: (context, index) {
          final player = state.players[index];
          final hand = state.playerHands[player.id] ?? const [];
          return BlackjackMultiplayerPlayerHandWidget(
            player: player,
            hand: hand,
            score: BlackjackRules.calculateHandValue(hand),
            chips: state.playerChips[player.id] ?? 0,
            bet: state.playerBets[player.id] ?? 0,
            status: state.playerStatuses[player.id] ?? 'waiting',
            isCurrentUser: player.id == currentUserId,
          );
        },
      );
    },
  );
}
