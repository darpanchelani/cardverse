import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/games/blackjack/blackjack_controller.dart';
import 'package:flutter/material.dart';

class BlackjackBetWidget extends StatelessWidget {
  const BlackjackBetWidget({
    required this.currentBet,
    required this.chips,
    required this.enabled,
    required this.onBetSelected,
    required this.onDecrease,
    required this.onIncrease,
    super.key,
  });

  final int currentBet;
  final int chips;
  final bool enabled;
  final ValueChanged<int> onBetSelected;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Place your bet',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      enabled
                          ? '$chips chips available'
                          : 'Bet locked during the round',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.mutedText,
                        fontFamily: 'Arial',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton.outlined(
                tooltip: 'Decrease bet',
                onPressed: enabled ? onDecrease : null,
                icon: const Icon(Icons.remove_rounded),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: SizedBox(
                  key: ValueKey(currentBet),
                  width: 66,
                  child: Text(
                    '$currentBet',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.paleGold,
                    ),
                  ),
                ),
              ),
              IconButton.filled(
                tooltip: 'Increase bet',
                onPressed: enabled ? onIncrease : null,
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: AppColors.ink,
                ),
                icon: const Icon(Icons.add_rounded),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final amount in BlackjackController.betOptions)
                ChoiceChip(
                  label: Text('$amount'),
                  selected: currentBet == amount,
                  onSelected: enabled && amount <= chips
                      ? (_) => onBetSelected(amount)
                      : null,
                  selectedColor: AppColors.gold,
                  backgroundColor: AppColors.inputGreen,
                  disabledColor: AppColors.inputGreen.withValues(alpha: 0.45),
                  labelStyle: TextStyle(
                    color: currentBet == amount
                        ? AppColors.ink
                        : AppColors.white,
                    fontFamily: 'Arial',
                    fontWeight: FontWeight.w700,
                  ),
                  side: BorderSide(
                    color: currentBet == amount
                        ? AppColors.paleGold
                        : AppColors.border,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
