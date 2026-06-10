import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/games/high_card/widgets/playing_card_widget.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:cardverse/features/games/war/war_state.dart';
import 'package:cardverse/features/games/war/widgets/war_pile_widget.dart';
import 'package:flutter/material.dart';

class WarBattleAreaWidget extends StatelessWidget {
  const WarBattleAreaWidget({required this.state, super.key});

  final WarState state;

  @override
  Widget build(BuildContext context) {
    final hasWarCards =
        state.playerWarDownCards.isNotEmpty ||
        state.computerWarDownCards.isNotEmpty;
    final playerDisplayCard = state.playerWarCard ?? state.playerCard;
    final computerDisplayCard = state.computerWarCard ?? state.computerCard;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const RadialGradient(
          radius: 1.15,
          colors: [AppColors.tableGreen, AppColors.inputGreen],
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (hasWarCards) ...[const _WarBanner(), const SizedBox(height: 14)],
          LayoutBuilder(
            builder: (context, constraints) {
              final horizontal = constraints.maxWidth >= 300;
              final cardWidth =
                  (horizontal
                          ? ((constraints.maxWidth - 18) / 2).clamp(
                              105.0,
                              190.0,
                            )
                          : constraints.maxWidth.clamp(120.0, 180.0))
                      .toDouble();

              final playerSide = _BattleSide(
                width: cardWidth,
                label: 'You',
                card: playerDisplayCard,
                roundNumber: state.roundNumber,
                deckCount: state.playerDeck.length,
                downCount: state.playerWarDownCards.length,
                isWarReveal: state.playerWarCard != null,
              );
              final computerSide = _BattleSide(
                width: cardWidth,
                label: 'Computer',
                card: computerDisplayCard,
                roundNumber: state.roundNumber,
                deckCount: state.computerDeck.length,
                downCount: state.computerWarDownCards.length,
                isWarReveal: state.computerWarCard != null,
              );

              if (!horizontal) {
                return Column(
                  children: [
                    playerSide,
                    const SizedBox(height: 22),
                    computerSide,
                  ],
                );
              }
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [playerSide, const SizedBox(width: 18), computerSide],
              );
            },
          ),
          if (state.isRoundPlayed) ...[
            const SizedBox(height: 15),
            WarPileWidget(label: 'Battle pile', count: state.lastBattleSize),
          ],
        ],
      ),
    );
  }
}

class _BattleSide extends StatelessWidget {
  const _BattleSide({
    required this.width,
    required this.label,
    required this.card,
    required this.roundNumber,
    required this.deckCount,
    required this.downCount,
    required this.isWarReveal,
  });

  final double width;
  final String label;
  final PlayingCardModel? card;
  final int roundNumber;
  final int deckCount;
  final int downCount;
  final bool isWarReveal;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 260),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: ScaleTransition(scale: animation, child: child),
            ),
            child: PlayingCardWidget(
              key: ValueKey('$label-$roundNumber-${card?.displayName}'),
              label: label,
              card: card,
              showBack: card == null,
            ),
          ),
          const SizedBox(height: 10),
          WarPileWidget(label: 'Cards owned', count: deckCount),
          if (downCount > 0) ...[
            const SizedBox(height: 7),
            Text(
              '$downCount face-down${isWarReveal ? ' • final card shown' : ''}',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.gold,
                fontFamily: 'Arial',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _WarBanner extends StatefulWidget {
  const _WarBanner();

  @override
  State<_WarBanner> createState() => _WarBannerState();
}

class _WarBannerState extends State<_WarBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..repeat(reverse: true);
    _scale = Tween(
      begin: 0.94,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        decoration: BoxDecoration(
          color: const Color(0xFFFF8A48).withValues(alpha: 0.13),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: const Color(0xFFFF8A48)),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.local_fire_department_rounded, color: Color(0xFFFF8A48)),
            SizedBox(width: 7),
            Text(
              'WAR!',
              style: TextStyle(
                color: Color(0xFFFFB27E),
                fontFamily: 'Arial',
                fontWeight: FontWeight.w900,
                letterSpacing: 2.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
