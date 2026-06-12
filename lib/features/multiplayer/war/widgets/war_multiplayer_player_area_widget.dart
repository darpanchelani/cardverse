import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/games/high_card/widgets/playing_card_widget.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:cardverse/features/multiplayer/models/room_player_model.dart';
import 'package:flutter/material.dart';

class WarMultiplayerPlayerAreaWidget extends StatelessWidget {
  const WarMultiplayerPlayerAreaWidget({
    required this.player,
    required this.card,
    required this.score,
    required this.cardCount,
    required this.isCurrentUser,
    required this.isBattleWinner,
    super.key,
  });

  final RoomPlayerModel player;
  final PlayingCardModel? card;
  final int score;
  final int cardCount;
  final bool isCurrentUser;
  final bool isBattleWinner;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    duration: const Duration(milliseconds: 250),
    opacity: cardCount == 0 ? 0.55 : 1,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 280),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isBattleWinner
            ? AppColors.gold.withValues(alpha: 0.17)
            : AppColors.cardGreen,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isBattleWinner
              ? AppColors.paleGold
              : isCurrentUser
              ? AppColors.gold
              : AppColors.border,
          width: isBattleWinner ? 2 : 1,
        ),
        boxShadow: isBattleWinner
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
                  size: 17,
                ),
            ],
          ),
          Text(
            cardCount == 0 ? 'Eliminated' : '$score wins · $cardCount cards',
            style: TextStyle(
              color: cardCount == 0 ? AppColors.danger : AppColors.paleGold,
              fontFamily: 'Arial',
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 8),
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
                showBack: card == null && cardCount > 0,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            cardCount == 0
                ? 'Out of cards'
                : card?.displayName ?? 'Waiting for battle',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.mutedText,
              fontFamily: 'Arial',
              fontSize: 11,
            ),
          ),
        ],
      ),
    ),
  );
}
