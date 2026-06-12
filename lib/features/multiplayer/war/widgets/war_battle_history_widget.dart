import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/war/models/war_battle_result_model.dart';
import 'package:flutter/material.dart';

class WarBattleHistoryWidget extends StatelessWidget {
  const WarBattleHistoryWidget({required this.battles, super.key});

  final List<WarBattleResultModel> battles;

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
    title: Text('Battle History (${battles.length})'),
    children: battles.reversed.map((battle) {
      final cards = battle.cards.values
          .map((card) => '${card.rank}${card.suitSymbol}')
          .join('  ');
      return ListTile(
        contentPadding: EdgeInsets.zero,
        dense: true,
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: battle.warCards.isNotEmpty
              ? AppColors.danger.withValues(alpha: 0.25)
              : AppColors.inputGreen,
          child: Text('${battle.battleNumber}'),
        ),
        title: Text(battle.message),
        subtitle: Text(
          '$cards · ${battle.pileCount} cards',
          style: const TextStyle(
            color: AppColors.mutedText,
            fontFamily: 'Arial',
          ),
        ),
      );
    }).toList(),
  );
}
