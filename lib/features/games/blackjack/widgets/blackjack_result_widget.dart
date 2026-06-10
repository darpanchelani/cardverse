import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/games/blackjack/blackjack_rules.dart';
import 'package:flutter/material.dart';

class BlackjackResultWidget extends StatelessWidget {
  const BlackjackResultWidget({
    required this.message,
    required this.result,
    super.key,
  });

  final String message;
  final BlackjackRoundResult? result;

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

  _BlackjackVisual get _visual {
    return switch (result) {
      BlackjackRoundResult.playerWin || BlackjackRoundResult.dealerBust =>
        const _BlackjackVisual(Icons.emoji_events_rounded, AppColors.gold),
      BlackjackRoundResult.playerBlackjack => const _BlackjackVisual(
        Icons.auto_awesome_rounded,
        AppColors.gold,
      ),
      BlackjackRoundResult.dealerWin || BlackjackRoundResult.dealerBlackjack =>
        const _BlackjackVisual(Icons.close_rounded, AppColors.danger),
      BlackjackRoundResult.playerBust => const _BlackjackVisual(
        Icons.warning_amber_rounded,
        AppColors.danger,
      ),
      BlackjackRoundResult.push => const _BlackjackVisual(
        Icons.sync_rounded,
        AppColors.paleGold,
      ),
      null => const _BlackjackVisual(
        Icons.touch_app_rounded,
        AppColors.mutedText,
      ),
    };
  }
}

class _BlackjackVisual {
  const _BlackjackVisual(this.icon, this.color);

  final IconData icon;
  final Color color;
}
