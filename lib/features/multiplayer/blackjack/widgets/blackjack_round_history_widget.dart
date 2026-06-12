import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/blackjack/models/blackjack_round_result_model.dart';
import 'package:flutter/material.dart';

class BlackjackRoundHistoryWidget extends StatelessWidget {
  const BlackjackRoundHistoryWidget({required this.rounds, super.key});

  final List<BlackjackRoundResultModel> rounds;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: const EdgeInsets.symmetric(horizontal: 4),
    title: const Text('Round History'),
    leading: const Icon(Icons.history_rounded, color: AppColors.gold),
    children: rounds.reversed
        .map(
          (round) => ListTile(
            title: Text('Round ${round.roundNumber}'),
            subtitle: Text(
              round.playerResults.values
                  .map((result) => result.message)
                  .join(' · '),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Text(
              'Dealer ${round.dealerScore}',
              style: const TextStyle(color: AppColors.paleGold),
            ),
          ),
        )
        .toList(),
  );
}
