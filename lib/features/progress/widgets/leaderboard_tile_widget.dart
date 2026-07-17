import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/core/utils/number_format_utils.dart';
import 'package:cardverse/features/progress/models/leaderboard_entry_model.dart';
import 'package:flutter/material.dart';

class LeaderboardTileWidget extends StatelessWidget {
  const LeaderboardTileWidget({
    required this.rank,
    required this.entry,
    required this.isCurrentUser,
    this.metric = 'wins',
    super.key,
  });

  final int rank;
  final LeaderboardEntryModel entry;
  final bool isCurrentUser;
  final String metric;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          'Rank $rank, ${entry.username}, ${_metricValue(entry, metric)} ${_metricLabel(metric)}',
      child: Container(
        color: isCurrentUser
            ? AppColors.gold.withValues(alpha: 0.1)
            : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        child: Row(
          children: [
            SizedBox(
              width: 38,
              child: Text(
                '#$rank',
                style: TextStyle(
                  color: isCurrentUser ? AppColors.gold : AppColors.mutedText,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.inputGreen,
              foregroundColor: AppColors.paleGold,
              child: Text(
                _initials(entry.username),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          entry.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                      if (isCurrentUser) ...[
                        const SizedBox(width: 6),
                        const Text(
                          'You',
                          style: TextStyle(
                            color: AppColors.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Level ${entry.level}  |  ${entry.totalGames} games',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _metricValue(entry, metric),
                  style: const TextStyle(
                    color: AppColors.paleGold,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  _metricLabel(metric),
                  style: const TextStyle(
                    color: AppColors.mutedText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

String _metricValue(LeaderboardEntryModel entry, String metric) {
  return switch (metric) {
    'xp' => NumberFormatUtils.compact(entry.xp),
    'coins' => NumberFormatUtils.compact(entry.coins),
    'winRate' => NumberFormatUtils.percentage(entry.winRate),
    _ => NumberFormatUtils.compact(entry.wins),
  };
}

String _metricLabel(String metric) => switch (metric) {
  'xp' => 'XP',
  'coins' => 'coins',
  'winRate' => 'win rate',
  _ => 'wins',
};

String _initials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'CV';
  if (parts.length == 1) {
    return parts.first
        .substring(0, parts.first.length.clamp(1, 2))
        .toUpperCase();
  }
  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}
