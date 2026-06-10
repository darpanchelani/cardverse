import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class WarScoreBoardWidget extends StatelessWidget {
  const WarScoreBoardWidget({
    required this.playerCards,
    required this.computerCards,
    required this.roundNumber,
    required this.warCount,
    required this.playerRoundsWon,
    required this.computerRoundsWon,
    super.key,
  });

  final int playerCards;
  final int computerCards;
  final int roundNumber;
  final int warCount;
  final int playerRoundsWon;
  final int computerRoundsWon;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _WarStat('Your cards', playerCards, Icons.style_rounded),
      _WarStat('Computer', computerCards, Icons.layers_rounded),
      _WarStat('Round', roundNumber, Icons.replay_rounded),
      _WarStat('Wars', warCount, Icons.local_fire_department_rounded),
      _WarStat('You won', playerRoundsWon, Icons.person_rounded),
      _WarStat('CPU won', computerRoundsWon, Icons.smart_toy_rounded),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final columns = constraints.maxWidth >= 610 ? 3 : 2;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final stat in stats)
              SizedBox(
                width: itemWidth,
                child: _WarStatTile(stat: stat),
              ),
          ],
        );
      },
    );
  }
}

class _WarStatTile extends StatelessWidget {
  const _WarStatTile({required this.stat});

  final _WarStat stat;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardGreen,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(stat.icon, color: AppColors.gold, size: 20),
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

class _WarStat {
  const _WarStat(this.label, this.value, this.icon);

  final String label;
  final int value;
  final IconData icon;
}
