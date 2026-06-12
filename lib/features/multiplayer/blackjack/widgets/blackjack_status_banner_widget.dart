import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BlackjackStatusBannerWidget extends StatelessWidget {
  const BlackjackStatusBannerWidget({
    required this.roomCode,
    required this.currentRound,
    required this.maxRounds,
    required this.status,
    super.key,
  });

  final String roomCode;
  final int currentRound;
  final int? maxRounds;
  final String status;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.cardGreen,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: AppColors.gold),
    ),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Room',
                style: TextStyle(
                  color: AppColors.mutedText,
                  fontFamily: 'Arial',
                  fontSize: 12,
                ),
              ),
              Text(
                roomCode,
                style: const TextStyle(
                  color: AppColors.paleGold,
                  fontFamily: 'Arial',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 3,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              maxRounds == null
                  ? 'Round $currentRound'
                  : 'Round $currentRound / $maxRounds',
              style: const TextStyle(
                fontFamily: 'Arial',
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              _label(status),
              style: const TextStyle(
                color: AppColors.gold,
                fontFamily: 'Arial',
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    ),
  );

  String _label(String value) => switch (value) {
    'dealer_turn' => 'Dealer Turn',
    'round_over' => 'Round Over',
    'match_over' => 'Match Over',
    'betting' => 'Betting',
    _ => 'Playing',
  };
}
