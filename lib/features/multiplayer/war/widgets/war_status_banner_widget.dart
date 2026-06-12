import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/multiplayer/war/models/war_game_state_model.dart';
import 'package:flutter/material.dart';

class WarStatusBannerWidget extends StatelessWidget {
  const WarStatusBannerWidget({required this.state, super.key});

  final WarGameStateModel state;

  @override
  Widget build(BuildContext context) {
    if (state.warCards.isEmpty || state.battleResult == null) {
      return const SizedBox.shrink();
    }
    final tiedNames = state.players
        .where((player) => state.warCards.containsKey(player.id))
        .map((player) => player.username)
        .join(' vs ');
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.94, end: 1),
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutBack,
      builder: (context, value, child) =>
          Transform.scale(scale: value, child: child),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.danger.withValues(alpha: 0.28),
              AppColors.gold.withValues(alpha: 0.16),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold),
        ),
        child: Column(
          children: [
            const Text(
              'WAR!',
              style: TextStyle(
                color: AppColors.paleGold,
                fontFamily: 'Arial',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              '$tiedNames · ${state.battleResult!.pileCount} cards contested',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.white,
                fontFamily: 'Arial',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
