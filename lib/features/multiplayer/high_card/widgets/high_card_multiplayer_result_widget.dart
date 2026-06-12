import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/high_card/models/high_card_game_state_model.dart';
import 'package:flutter/material.dart';

class HighCardMultiplayerResultWidget extends StatelessWidget {
  const HighCardMultiplayerResultWidget({
    required this.state,
    required this.currentUserId,
    super.key,
  });

  final HighCardGameStateModel state;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final matchOver = state.status == 'match_over';
    final wonMatch = state.matchWinnerId == currentUserId;
    final wonRound = state.roundResult?.winnerId == currentUserId;
    final message = matchOver
        ? state.matchWinnerId == null
              ? 'Match ended in a draw.'
              : wonMatch
              ? 'You won the match!'
              : state.matchMessage ?? '${state.matchWinnerName} won the match!'
        : state.roundResult == null
        ? 'Draw cards when everyone is ready.'
        : state.roundResult!.winnerId == null
        ? 'Round draw!'
        : wonRound
        ? 'You won this round!'
        : state.roundResult!.message;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey('$message-${state.currentRound}'),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (wonMatch || wonRound)
              ? AppColors.gold.withValues(alpha: 0.16)
              : AppColors.cardGreen,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (wonMatch || wonRound) ? AppColors.gold : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              matchOver
                  ? state.matchWinnerId == null
                        ? Icons.handshake_outlined
                        : Icons.emoji_events_rounded
                  : state.roundResult == null
                  ? Icons.style_rounded
                  : Icons.auto_awesome_rounded,
              color: AppColors.gold,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
