import 'package:cardverse/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class BlackjackMultiplayerBetWidget extends StatelessWidget {
  const BlackjackMultiplayerBetWidget({
    required this.chips,
    required this.currentBet,
    required this.minimumBet,
    required this.enabled,
    required this.isLoading,
    required this.onBet,
    super.key,
  });

  final int chips;
  final int currentBet;
  final int minimumBet;
  final bool enabled;
  final bool isLoading;
  final ValueChanged<int> onBet;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: AppColors.cardGreen,
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Bet: $currentBet · Available: $chips chips',
          style: const TextStyle(
            fontFamily: 'Arial',
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 11),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [10, 25, 50, 100, 250]
              .where((amount) => amount >= minimumBet)
              .map(
                (amount) => ChoiceChip(
                  label: Text('$amount'),
                  selected: currentBet == amount,
                  onSelected: enabled && !isLoading && amount <= chips
                      ? (_) => onBet(amount)
                      : null,
                  selectedColor: AppColors.gold,
                  backgroundColor: AppColors.inputGreen,
                  labelStyle: TextStyle(
                    color: currentBet == amount
                        ? AppColors.ink
                        : AppColors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
              .toList(),
        ),
      ],
    ),
  );
}
