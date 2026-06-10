import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/utils/date_time_utils.dart';
import 'package:cardverse/features/progress/models/match_history_model.dart';
import 'package:flutter/material.dart';

class MatchHistoryTileWidget extends StatelessWidget {
  const MatchHistoryTileWidget({required this.match, super.key});

  final MatchHistoryModel match;

  @override
  Widget build(BuildContext context) {
    final color = switch (match.result) {
      'win' => AppColors.gold,
      'loss' => AppColors.danger,
      _ => AppColors.paleGold,
    };
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: color.withValues(alpha: 0.14),
            child: Icon(_gameIcon(match.gameType), color: color),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        match.gameName,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(
                      match.result.toUpperCase(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontFamily: 'Arial',
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  'vs ${match.opponent} • ${match.playerScore} - ${match.opponentScore}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedText,
                    fontFamily: 'Arial',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '+${match.coinsEarned} coins • +${match.xpEarned} XP • '
                  '${DateTimeUtils.formatDateTime(match.playedAt)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.gold,
                    fontFamily: 'Arial',
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _gameIcon(String gameType) => switch (gameType) {
    'high_card' => Icons.filter_1_rounded,
    'war' => Icons.local_fire_department_rounded,
    'blackjack' => Icons.casino_rounded,
    _ => Icons.style_rounded,
  };
}
