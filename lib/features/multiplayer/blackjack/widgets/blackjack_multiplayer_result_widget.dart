import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/blackjack/models/blackjack_game_state_model.dart';
import 'package:flutter/material.dart';

class BlackjackMultiplayerResultWidget extends StatelessWidget {
  const BlackjackMultiplayerResultWidget({
    required this.state,
    required this.currentUserId,
    super.key,
  });

  final BlackjackGameStateModel state;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    final result = state.roundResults[currentUserId];
    final match = state.matchResults;
    final message = match != null
        ? match.winnerId == currentUserId
              ? 'You won the Blackjack table!'
              : match.message
        : result?.message ??
              (state.status == 'betting'
                  ? 'Place your bet and wait for the host to deal.'
                  : 'Beat the dealer without going over 21.');
    final positive =
        match?.winnerId == currentUserId || (result?.chipsChange ?? 0) > 0;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      child: Container(
        key: ValueKey('$message-${state.currentRound}'),
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: positive
              ? AppColors.gold.withValues(alpha: 0.16)
              : AppColors.cardGreen,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: positive ? AppColors.gold : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Icon(
              positive
                  ? Icons.auto_awesome_rounded
                  : result?.result == 'bust'
                  ? Icons.warning_amber_rounded
                  : Icons.casino_outlined,
              color: positive ? AppColors.gold : AppColors.paleGold,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
