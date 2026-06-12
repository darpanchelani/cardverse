import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/war/models/war_game_state_model.dart';
import 'package:flutter/material.dart';

class WarMultiplayerResultWidget extends StatelessWidget {
  const WarMultiplayerResultWidget({
    required this.state,
    required this.currentUserId,
    super.key,
  });

  final WarGameStateModel state;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final matchOver = state.status == 'match_over';
    final wonMatch = state.matchWinnerId == currentUserId;
    final wonBattle = state.battleResult?.winnerId == currentUserId;
    final message = matchOver
        ? state.matchWinnerId == null
              ? 'War ended in a draw.'
              : wonMatch
              ? 'You won the war!'
              : state.matchMessage ?? '${state.matchWinnerName} won the war!'
        : state.battleResult == null
        ? 'Start the next battle when everyone is ready.'
        : state.battleResult!.winnerId == null
        ? 'Battle draw. Cards split.'
        : wonBattle
        ? 'You won this battle!'
        : state.battleResult!.message;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: Container(
        key: ValueKey('$message-${state.currentBattle}'),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: (wonMatch || wonBattle)
              ? AppColors.gold.withValues(alpha: 0.16)
              : AppColors.cardGreen,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (wonMatch || wonBattle) ? AppColors.gold : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              matchOver
                  ? Icons.emoji_events_rounded
                  : state.battleResult == null
                  ? Icons.style_rounded
                  : Icons.bolt_rounded,
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
