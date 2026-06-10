import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/games/war/war_rules.dart';
import 'package:flutter/material.dart';

class WarResultWidget extends StatelessWidget {
  const WarResultWidget({
    required this.message,
    required this.result,
    required this.isGameOver,
    super.key,
  });

  final String message;
  final WarRoundResult? result;
  final bool isGameOver;

  @override
  Widget build(BuildContext context) {
    final visual = _visual;
    return Container(
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
    );
  }

  _WarVisual get _visual {
    if (isGameOver) {
      return const _WarVisual(Icons.emoji_events_rounded, AppColors.gold);
    }
    return switch (result) {
      WarRoundResult.playerWin => const _WarVisual(
        Icons.emoji_events_rounded,
        AppColors.gold,
      ),
      WarRoundResult.computerWin => const _WarVisual(
        Icons.shield_rounded,
        AppColors.danger,
      ),
      WarRoundResult.war => const _WarVisual(
        Icons.local_fire_department_rounded,
        Color(0xFFFF8A48),
      ),
      WarRoundResult.draw => const _WarVisual(
        Icons.balance_rounded,
        AppColors.paleGold,
      ),
      null => const _WarVisual(Icons.touch_app_rounded, AppColors.mutedText),
    };
  }
}

class _WarVisual {
  const _WarVisual(this.icon, this.color);

  final IconData icon;
  final Color color;
}
