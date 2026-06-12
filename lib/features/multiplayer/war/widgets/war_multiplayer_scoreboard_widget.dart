import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/war/models/war_game_state_model.dart';
import 'package:flutter/material.dart';

class WarMultiplayerScoreboardWidget extends StatelessWidget {
  const WarMultiplayerScoreboardWidget({
    required this.state,
    required this.currentUserId,
    super.key,
  });

  final WarGameStateModel state;
  final String currentUserId;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: state.players.map((player) {
      final current = player.id == currentUserId;
      final cards = state.cardCounts[player.id] ?? 0;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        constraints: const BoxConstraints(minWidth: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: current
              ? AppColors.gold.withValues(alpha: 0.16)
              : AppColors.cardGreen,
          borderRadius: BorderRadius.circular(16),
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
                player.username.characters.first.toUpperCase(),
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
                    '${state.scores[player.id] ?? 0} wins · $cards cards',
                    style: TextStyle(
                      color: cards == 0 ? AppColors.danger : AppColors.paleGold,
                      fontFamily: 'Arial',
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(
              player.isBot
                  ? Icons.smart_toy_outlined
                  : player.connectionStatus == 'connected'
                  ? Icons.circle
                  : Icons.cloud_off_rounded,
              color: player.connectionStatus == 'connected'
                  ? Colors.greenAccent
                  : AppColors.danger,
              size: player.isBot ? 18 : 10,
            ),
          ],
        ),
      );
    }).toList(),
  );
}
