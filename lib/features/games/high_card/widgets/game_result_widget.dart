import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/games/engine/card_rules.dart';
import 'package:flutter/material.dart';

class GameResultWidget extends StatelessWidget {
  const GameResultWidget({
    required this.message,
    required this.result,
    required this.isGameOver,
    super.key,
  });

  final String message;
  final CardComparisonResult? result;
  final bool isGameOver;

  @override
  Widget build(BuildContext context) {
    final visual = _visualForResult();

    return AnimatedScale(
      scale: 1,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutBack,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: visual.color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: visual.color.withValues(alpha: 0.75)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(visual.icon, color: visual.color),
            const SizedBox(width: 11),
            Flexible(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: visual.color),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _ResultVisual _visualForResult() {
    if (isGameOver) {
      return const _ResultVisual(Icons.layers_clear_rounded, AppColors.gold);
    }
    return switch (result) {
      CardComparisonResult.playerWin => const _ResultVisual(
        Icons.emoji_events_rounded,
        AppColors.gold,
      ),
      CardComparisonResult.computerWin => const _ResultVisual(
        Icons.smart_toy_rounded,
        AppColors.danger,
      ),
      CardComparisonResult.draw => const _ResultVisual(
        Icons.balance_rounded,
        AppColors.paleGold,
      ),
      null => const _ResultVisual(Icons.touch_app_rounded, AppColors.mutedText),
    };
  }
}

class _ResultVisual {
  const _ResultVisual(this.icon, this.color);

  final IconData icon;
  final Color color;
}
