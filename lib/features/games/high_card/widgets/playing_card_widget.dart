import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:flutter/material.dart';
import 'package:cardverse/app/app_services_scope.dart';

class PlayingCardWidget extends StatelessWidget {
  const PlayingCardWidget({
    super.key,
    this.card,
    this.label,
    this.showBack = false,
    this.cardTheme,
  });

  final PlayingCardModel? card;
  final String? label;
  final bool showBack;
  final String? cardTheme;

  @override
  Widget build(BuildContext context) {
    final selectedTheme =
        cardTheme ??
        AppServicesScope.maybeOf(context)?.customization.cardTheme ??
        'classic';
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(color: AppColors.paleGold),
          ),
          const SizedBox(height: 12),
        ],
        AspectRatio(
          aspectRatio: 0.68,
          child: showBack || card == null
              ? _CardBack(theme: selectedTheme)
              : _CardFront(card: card!, theme: selectedTheme),
        ),
      ],
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({required this.card, required this.theme});

  final PlayingCardModel card;
  final String theme;

  @override
  Widget build(BuildContext context) {
    final cardColor = card.colorType == CardColorType.red
        ? (theme == 'minimal_dark'
              ? const Color(0xFFFF7C82)
              : const Color(0xFFC7353B))
        : (theme == 'minimal_dark' ? AppColors.white : const Color(0xFF111A17));

    return Container(
      decoration: BoxDecoration(
        color: theme == 'minimal_dark'
            ? const Color(0xFF171A19)
            : theme == 'desert_thar'
            ? const Color(0xFFFFE8BE)
            : AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme == 'neon_night'
              ? const Color(0xFF7184FF)
              : AppColors.gold,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.28),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 13,
            top: 11,
            child: _CardCorner(card: card, color: cardColor),
          ),
          Center(
            child: Text(
              card.suitSymbol,
              style: TextStyle(
                color: cardColor,
                fontFamily: 'Arial',
                fontSize: 58,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Positioned(
            right: 13,
            bottom: 11,
            child: RotatedBox(
              quarterTurns: 2,
              child: _CardCorner(card: card, color: cardColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardCorner extends StatelessWidget {
  const _CardCorner({required this.card, required this.color});

  final PlayingCardModel card;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          card.rank,
          style: TextStyle(
            color: color,
            fontFamily: 'Arial',
            fontSize: 23,
            height: 0.95,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          card.suitSymbol,
          style: TextStyle(
            color: color,
            fontFamily: 'Arial',
            fontSize: 20,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.theme});

  final String theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: switch (theme) {
            'royal_gold' => const [Color(0xFF2F2410), Color(0xFF9A711F)],
            'neon_night' => const [Color(0xFF080A1A), Color(0xFF3448C5)],
            'desert_thar' => const [Color(0xFF56351D), Color(0xFFB7803C)],
            'minimal_dark' => const [Color(0xFF080909), Color(0xFF303533)],
            _ => const [AppColors.cardGreen, AppColors.inputGreen],
          },
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(
                left: 10,
                top: 8,
                child: Text(
                  '♠',
                  style: TextStyle(color: AppColors.gold, fontSize: 18),
                ),
              ),
              const Positioned(
                right: 10,
                bottom: 8,
                child: Text(
                  '♦',
                  style: TextStyle(color: AppColors.gold, fontSize: 18),
                ),
              ),
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.gold.withValues(alpha: 0.12),
                  border: Border.all(color: AppColors.gold),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'CV',
                  style: TextStyle(
                    color: AppColors.paleGold,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
