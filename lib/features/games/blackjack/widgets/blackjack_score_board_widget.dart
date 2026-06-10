import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BlackjackScoreBoardWidget extends StatelessWidget {
  const BlackjackScoreBoardWidget({
    required this.chips,
    required this.currentBet,
    required this.roundNumber,
    required this.wins,
    required this.losses,
    required this.pushes,
    super.key,
  });

  final int chips;
  final int currentBet;
  final int roundNumber;
  final int wins;
  final int losses;
  final int pushes;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _BlackjackStat('Chips', chips, Icons.monetization_on_rounded),
      _BlackjackStat('Bet', currentBet, Icons.casino_rounded),
      _BlackjackStat('Round', roundNumber, Icons.replay_rounded),
      _BlackjackStat('Wins', wins, Icons.emoji_events_rounded),
      _BlackjackStat('Losses', losses, Icons.close_rounded),
      _BlackjackStat('Pushes', pushes, Icons.sync_rounded),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final columns = constraints.maxWidth >= 610 ? 3 : 2;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final stat in stats)
              SizedBox(
                width: width,
                child: _BlackjackStatTile(stat: stat),
              ),
          ],
        );
      },
    );
  }
}

class _BlackjackStatTile extends StatelessWidget {
  const _BlackjackStatTile({required this.stat});

  final _BlackjackStat stat;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardGreen,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(stat.icon, size: 20, color: AppColors.gold),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stat.value}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.paleGold,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.mutedText,
                    fontFamily: 'Arial',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BlackjackStat {
  const _BlackjackStat(this.label, this.value, this.icon);

  final String label;
  final int value;
  final IconData icon;
}
