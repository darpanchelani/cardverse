import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/high_card/models/high_card_round_result_model.dart';
import 'package:flutter/material.dart';

class HighCardRoundHistoryWidget extends StatelessWidget {
  const HighCardRoundHistoryWidget({required this.rounds, super.key});

  final List<HighCardRoundResultModel> rounds;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: const EdgeInsets.symmetric(horizontal: 16),
    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
    collapsedBackgroundColor: AppColors.cardGreen,
    backgroundColor: AppColors.cardGreen,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    collapsedShape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(18),
    ),
    title: Text('Round History (${rounds.length})'),
    children: rounds.reversed.map((round) {
      final cards = round.cards.values
          .map((card) => '${card.rank}${card.suitSymbol}')
          .join('  ');
      return ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.inputGreen,
          child: Text('${round.roundNumber}'),
        ),
        title: Text(round.message),
        subtitle: Text(
          cards,
          style: const TextStyle(
            color: AppColors.mutedText,
            fontFamily: 'Arial',
          ),
        ),
      );
    }).toList(),
  );
}
