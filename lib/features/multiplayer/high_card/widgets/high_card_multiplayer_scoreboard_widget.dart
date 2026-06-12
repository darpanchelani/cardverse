import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/high_card/models/high_card_game_state_model.dart';
import 'package:flutter/material.dart';

class HighCardMultiplayerScoreboardWidget extends StatelessWidget {
  const HighCardMultiplayerScoreboardWidget({
    required this.state,
    required this.currentUserId,
    super.key,
  });

  final HighCardGameStateModel state;
  final String currentUserId;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 8,
    runSpacing: 8,
    children: state.players.map((player) {
      final current = player.id == currentUserId;
      return Container(
        constraints: const BoxConstraints(minWidth: 132),
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
                    '${state.scores[player.id] ?? 0} points',
                    style: const TextStyle(
                      color: AppColors.paleGold,
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
