import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/games/high_card/widgets/playing_card_widget.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:flutter/material.dart';

class BlackjackHandWidget extends StatelessWidget {
  const BlackjackHandWidget({
    required this.label,
    required this.cards,
    required this.scoreLabel,
    super.key,
    this.hiddenCardIndex,
  });

  final String label;
  final List<PlayingCardModel> cards;
  final String scoreLabel;
  final int? hiddenCardIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.tableGreen,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(color: AppColors.paleGold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: AppColors.inputGreen,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  'Score: $scoreLabel',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge?.copyWith(color: AppColors.gold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (cards.isEmpty)
            const SizedBox(
              height: 150,
              child: Center(
                child: Text(
                  'Cards will appear here',
                  style: TextStyle(
                    color: AppColors.mutedText,
                    fontFamily: 'Arial',
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 166,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: cards.length,
                separatorBuilder: (context, index) => const SizedBox(width: 11),
                itemBuilder: (context, index) {
                  final isHidden = hiddenCardIndex == index;
                  return SizedBox(
                    width: 106,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(scale: animation, child: child),
                      ),
                      child: PlayingCardWidget(
                        key: ValueKey(
                          '$label-$index-${isHidden ? 'hidden' : cards[index].displayName}',
                        ),
                        card: cards[index],
                        showBack: isHidden,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
