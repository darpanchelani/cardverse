import 'package:cardverse/core/widgets/custom_button.dart';
import 'package:cardverse/features/games/blackjack/blackjack_state.dart';
import 'package:flutter/material.dart';

class BlackjackActionButtonsWidget extends StatelessWidget {
  const BlackjackActionButtonsWidget({
    required this.state,
    required this.onStartRound,
    required this.onHit,
    required this.onStand,
    required this.onNewGame,
    super.key,
  });

  final BlackjackState state;
  final VoidCallback onStartRound;
  final VoidCallback onHit;
  final VoidCallback onStand;
  final VoidCallback onNewGame;

  @override
  Widget build(BuildContext context) {
    if (state.isGameOver) {
      return CustomButton(
        label: 'Start New Game',
        icon: Icons.refresh_rounded,
        onPressed: onNewGame,
      );
    }

    if (!state.isRoundStarted) {
      return CustomButton(
        label: 'Start Round',
        icon: Icons.play_arrow_rounded,
        onPressed: onStartRound,
      );
    }

    if (state.isRoundOver) {
      return Row(
        children: [
          Expanded(
            child: CustomButton(
              label: 'Next Round',
              icon: Icons.skip_next_rounded,
              onPressed: onStartRound,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              label: 'New Game',
              icon: Icons.refresh_rounded,
              isOutlined: true,
              onPressed: onNewGame,
            ),
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: CustomButton(
            label: 'Hit',
            icon: Icons.add_card_rounded,
            onPressed: state.isPlayerTurn ? onHit : null,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            label: 'Stand',
            icon: Icons.pan_tool_alt_rounded,
            isOutlined: true,
            onPressed: state.isPlayerTurn ? onStand : null,
          ),
        ),
      ],
    );
  }
}
