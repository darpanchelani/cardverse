import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/games/high_card/widgets/playing_card_widget.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:cardverse/features/multiplayer/models/room_player_model.dart';
import 'package:flutter/material.dart';

class BlackjackMultiplayerPlayerHandWidget extends StatelessWidget {
  const BlackjackMultiplayerPlayerHandWidget({
    required this.player,
    required this.hand,
    required this.score,
    required this.chips,
    required this.bet,
    required this.status,
    required this.isCurrentUser,
    super.key,
  });

  final RoomPlayerModel player;
  final List<PlayingCardModel> hand;
  final int score;
  final int chips;
  final int bet;
  final String status;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: AppColors.cardGreen,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: isCurrentUser ? AppColors.gold : AppColors.border,
        width: isCurrentUser ? 2 : 1,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
          'Score $score · $chips chips · Bet $bet · ${_statusLabel(status)}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: status == 'bust' || status == 'eliminated'
                ? AppColors.danger
                : AppColors.paleGold,
            fontFamily: 'Arial',
            fontSize: 11,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: hand.isEmpty
              ? const Center(
                  child: Text(
                    'Waiting for cards',
                    style: TextStyle(
                      color: AppColors.mutedText,
                      fontFamily: 'Arial',
                    ),
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: hand.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 7),
                  itemBuilder: (context, index) => SizedBox(
                    width: 80,
                    child: PlayingCardWidget(card: hand[index]),
                  ),
                ),
        ),
      ],
    ),
  );

  String _statusLabel(String value) => value
      .split('_')
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
