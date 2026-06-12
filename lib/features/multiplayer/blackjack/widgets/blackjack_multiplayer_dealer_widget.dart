import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/games/high_card/widgets/playing_card_widget.dart';
import 'package:cardverse/features/multiplayer/blackjack/models/blackjack_game_state_model.dart';
import 'package:flutter/material.dart';

class BlackjackMultiplayerDealerWidget extends StatelessWidget {
  const BlackjackMultiplayerDealerWidget({required this.dealer, super.key});

  final BlackjackDealerModel dealer;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppColors.cardGreen,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.account_balance_rounded, color: AppColors.gold),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Dealer',
                style: TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w800,
                  fontSize: 17,
                ),
              ),
            ),
            Text(
              dealer.isHidden ? 'Score ?' : 'Score ${dealer.score}',
              style: const TextStyle(
                color: AppColors.paleGold,
                fontFamily: 'Arial',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: dealer.hand.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) => SizedBox(
              width: 86,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                child: PlayingCardWidget(
                  key: ValueKey(dealer.hand[index]?.displayName ?? 'hidden'),
                  card: dealer.hand[index],
                  showBack: dealer.hand[index] == null,
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
