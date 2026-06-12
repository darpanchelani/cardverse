import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/games/high_card/widgets/playing_card_widget.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:cardverse/features/multiplayer/models/room_player_model.dart';
import 'package:flutter/material.dart';

class HighCardMultiplayerPlayerCardWidget extends StatelessWidget {
  const HighCardMultiplayerPlayerCardWidget({
    required this.player,
    required this.card,
    required this.score,
    required this.isCurrentUser,
    required this.isRoundWinner,
    super.key,
  });

  final RoomPlayerModel player;
  final PlayingCardModel? card;
  final int score;
  final bool isCurrentUser;
  final bool isRoundWinner;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 280),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: isRoundWinner
          ? AppColors.gold.withValues(alpha: 0.17)
          : AppColors.cardGreen,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: isRoundWinner
            ? AppColors.paleGold
            : isCurrentUser
            ? AppColors.gold
            : AppColors.border,
        width: isRoundWinner ? 2 : 1,
      ),
      boxShadow: isRoundWinner
          ? [
              BoxShadow(
                color: AppColors.gold.withValues(alpha: 0.2),
                blurRadius: 20,
              ),
            ]
          : null,
    ),
    child: Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                isCurrentUser ? 'You' : player.username,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Arial',
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            if (player.isBot)
              const Icon(
                Icons.smart_toy_outlined,
                color: AppColors.gold,
                size: 18,
              ),
            const SizedBox(width: 5),
            Text(
              '$score',
              style: const TextStyle(
                color: AppColors.paleGold,
                fontFamily: 'Arial',
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => ScaleTransition(
              scale: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutBack,
              ),
              child: FadeTransition(opacity: animation, child: child),
            ),
            child: PlayingCardWidget(
              key: ValueKey(card?.displayName ?? '${player.id}_waiting'),
              card: card,
              showBack: card == null,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          card?.displayName ?? 'Waiting for draw',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: card == null ? AppColors.mutedText : AppColors.white,
            fontFamily: 'Arial',
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}
