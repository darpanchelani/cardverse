import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class ScoreBoardWidget extends StatelessWidget {
  const ScoreBoardWidget({
    required this.playerScore,
    required this.computerScore,
    required this.drawScore,
    required this.roundNumber,
    required this.remainingCards,
    super.key,
  });

  final int playerScore;
  final int computerScore;
  final int drawScore;
  final int roundNumber;
  final int remainingCards;

  @override
  Widget build(BuildContext context) {
    final stats = [
      _ScoreData('You', playerScore, Icons.person_rounded),
      _ScoreData('Computer', computerScore, Icons.smart_toy_rounded),
      _ScoreData('Draws', drawScore, Icons.balance_rounded),
      _ScoreData('Round', roundNumber, Icons.replay_rounded),
      _ScoreData('Cards Left', remainingCards, Icons.style_rounded),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = 10.0;
        final itemWidth = constraints.maxWidth >= 560
            ? (constraints.maxWidth - spacing * 4) / 5
            : (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          alignment: WrapAlignment.center,
          children: [
            for (final stat in stats)
              SizedBox(
                width: itemWidth,
                child: _ScoreTile(data: stat),
              ),
          ],
        );
      },
    );
  }
}

class _ScoreTile extends StatelessWidget {
  const _ScoreTile({required this.data});

  final _ScoreData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 78,
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.cardGreen,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(data.icon, size: 20, color: AppColors.gold),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${data.value}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.paleGold,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  data.label,
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

class _ScoreData {
  const _ScoreData(this.label, this.value, this.icon);

  final String label;
  final int value;
  final IconData icon;
}
