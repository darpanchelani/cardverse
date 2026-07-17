import 'package:card_game/card_game.dart' show SuitedCardBuilder;
import 'package:cardverse/app/app_services_scope.dart';
import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/games/adapters/card_game_adapter.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:flutter/material.dart';

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
    final renderedCard = card.cardGameCard;
    final accent = _frontAccent(theme);

    return Semantics(
      image: true,
      label: card.displayName,
      child: Container(
        decoration: BoxDecoration(
          color: accent,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.32),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(2),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: renderedCard == null
              ? _FallbackCardFront(card: card)
              : SuitedCardBuilder(card: renderedCard),
        ),
      ),
    );
  }
}

class _FallbackCardFront extends StatelessWidget {
  const _FallbackCardFront({required this.card});

  final PlayingCardModel card;

  @override
  Widget build(BuildContext context) {
    final color = card.colorType == CardColorType.red
        ? const Color(0xFFC7353B)
        : const Color(0xFF111A17);

    return ColoredBox(
      color: AppColors.white,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final rankSize = (constraints.maxWidth * 0.26)
              .clamp(14.0, 30.0)
              .toDouble();
          final suitSize = (constraints.maxWidth * 0.52)
              .clamp(28.0, 64.0)
              .toDouble();
          return Stack(
            children: [
              Positioned(
                left: 8,
                top: 7,
                child: Text(
                  '${card.rank}\n${card.suitSymbol}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontFamily: 'Arial',
                    fontSize: rankSize,
                    height: 0.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Center(
                child: Text(
                  card.suitSymbol,
                  style: TextStyle(
                    color: color,
                    fontFamily: 'Arial',
                    fontSize: suitSize,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.theme});

  final String theme;

  @override
  Widget build(BuildContext context) {
    final colors = _backColors(theme);
    final accent = _frontAccent(theme);

    return Semantics(
      image: true,
      label: 'Face-down playing card',
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(5),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accent, width: 1.5),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final cardWidth = constraints.maxWidth;
                final markSize = (cardWidth * 0.5).clamp(28.0, 64.0).toDouble();
                final monogramSize = (cardWidth * 0.18)
                    .clamp(11.0, 22.0)
                    .toDouble();
                return CustomPaint(
                  painter: _CardBackPatternPainter(
                    color: accent.withValues(alpha: 0.2),
                    spacing: (cardWidth * 0.12).clamp(7.0, 14.0).toDouble(),
                  ),
                  child: Center(
                    child: Container(
                      width: markSize,
                      height: markSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.first.withValues(alpha: 0.88),
                        border: Border.all(color: accent, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'CV',
                        style: TextStyle(
                          color: accent,
                          fontFamily: 'Arial',
                          fontSize: monogramSize,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CardBackPatternPainter extends CustomPainter {
  const _CardBackPatternPainter({required this.color, required this.spacing});

  final Color color;
  final double spacing;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    for (double x = -size.height; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + size.height, size.height),
        paint,
      );
      canvas.drawLine(
        Offset(x + size.height, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CardBackPatternPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.spacing != spacing;
}

Color _frontAccent(String theme) => switch (theme) {
  'royal_gold' => const Color(0xFFD8AA3E),
  'neon_night' => const Color(0xFF8D9BFF),
  'desert_thar' => const Color(0xFFD39B51),
  'minimal_dark' => const Color(0xFF858E89),
  _ => AppColors.gold,
};

List<Color> _backColors(String theme) => switch (theme) {
  'royal_gold' => const [Color(0xFF2F2410), Color(0xFF795515)],
  'neon_night' => const [Color(0xFF080A1A), Color(0xFF263698)],
  'desert_thar' => const [Color(0xFF56351D), Color(0xFF9A632C)],
  'minimal_dark' => const [Color(0xFF080909), Color(0xFF292E2C)],
  _ => const [AppColors.cardGreen, AppColors.inputGreen],
};
