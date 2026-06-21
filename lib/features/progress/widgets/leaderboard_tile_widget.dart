import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/utils/number_format_utils.dart';
import 'package:cardverse/features/progress/models/leaderboard_entry_model.dart';
import 'package:flutter/material.dart';

class LeaderboardTileWidget extends StatelessWidget {
  const LeaderboardTileWidget({
    required this.rank,
    required this.entry,
    required this.isCurrentUser,
    super.key,
  });

  final int rank;
  final LeaderboardEntryModel entry;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final emphasized = rank == 1 || isCurrentUser;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: rank == 1 ? AppColors.gold : AppColors.cardGreen,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: emphasized ? AppColors.paleGold : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: _frameColor(entry.avatarFrame),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              backgroundColor: rank == 1
                  ? AppColors.ink.withValues(alpha: 0.12)
                  : AppColors.inputGreen,
              child: Text(
                '$rank',
                style: TextStyle(
                  color: rank == 1 ? AppColors.ink : AppColors.paleGold,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.username,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: rank == 1
                                  ? AppColors.ink
                                  : AppColors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: rank == 1 ? AppColors.ink : AppColors.gold,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Level ${entry.level} • ${entry.wins} wins • '
                  '${NumberFormatUtils.percentage(entry.winRate)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: rank == 1
                        ? AppColors.ink.withValues(alpha: 0.72)
                        : AppColors.mutedText,
                    fontFamily: 'Arial',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                NumberFormatUtils.compact(entry.coins),
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: rank == 1 ? AppColors.ink : AppColors.gold,
                ),
              ),
              Text(
                'coins',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: rank == 1
                      ? AppColors.ink.withValues(alpha: 0.65)
                      : AppColors.mutedText,
                  fontFamily: 'Arial',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _frameColor(String frame) => switch (frame) {
    'bronze' => const Color(0xFFB87333),
    'silver' => const Color(0xFFC0C0C0),
    'gold' || 'champion' => AppColors.gold,
    _ => AppColors.border,
  };
}
