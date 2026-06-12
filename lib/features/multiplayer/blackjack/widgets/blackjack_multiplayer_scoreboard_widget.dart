import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/blackjack/models/blackjack_game_state_model.dart';
import 'package:flutter/material.dart';

class BlackjackMultiplayerScoreboardWidget extends StatelessWidget {
  const BlackjackMultiplayerScoreboardWidget({
    required this.state,
    required this.currentUserId,
    super.key,
  });

  final BlackjackGameStateModel state;
  final String currentUserId;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: state.players.map((player) {
      final current = player.id == currentUserId;
      final chips = state.playerChips[player.id] ?? 0;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        constraints: const BoxConstraints(minWidth: 155),
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: current
              ? AppColors.gold.withValues(alpha: 0.16)
              : AppColors.cardGreen,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: current ? AppColors.gold : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.inputGreen,
              child: Text(
                player.username.isEmpty
                    ? '?'
                    : player.username.characters.first.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.gold,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    current ? 'You' : player.username,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Arial',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '$chips chips · Bet ${state.playerBets[player.id] ?? 0}',
                    style: TextStyle(
                      color: chips == 0 ? AppColors.danger : AppColors.paleGold,
                      fontFamily: 'Arial',
                      fontSize: 11,
                    ),
                  ),
                  Text(
                    _label(state.playerStatuses[player.id] ?? 'waiting'),
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontFamily: 'Arial',
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (player.isBot)
              const Icon(
                Icons.smart_toy_outlined,
                color: AppColors.gold,
                size: 18,
              )
            else
              Icon(
                player.connectionStatus == 'connected'
                    ? Icons.circle
                    : Icons.cloud_off_rounded,
                color: player.connectionStatus == 'connected'
                    ? Colors.greenAccent
                    : AppColors.danger,
                size: player.connectionStatus == 'connected' ? 10 : 17,
              ),
          ],
        ),
      );
    }).toList(),
  );

  String _label(String value) => value
      .split('_')
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
