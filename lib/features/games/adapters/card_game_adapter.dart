import 'package:card_game/card_game.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';

extension CardGameAdapter on PlayingCardModel {
  /// Converts CardVerse's API-friendly card model into the renderer's card.
  ///
  /// Malformed or unsupported card data returns `null` so the UI can retain a
  /// readable fallback instead of failing an entire game table.
  SuitedCard? get cardGameCard {
    final cardSuit = switch (suit.trim().toLowerCase()) {
      'hearts' => CardSuit.hearts,
      'diamonds' => CardSuit.diamonds,
      'clubs' => CardSuit.clubs,
      'spades' => CardSuit.spades,
      _ => null,
    };
    if (cardSuit == null) return null;

    final normalizedRank = rank.trim().toUpperCase();
    final SuitedCardValue? cardValue = switch (normalizedRank) {
      'J' => JackSuitedCardValue(),
      'Q' => QueenSuitedCardValue(),
      'K' => KingSuitedCardValue(),
      'A' => AceSuitedCardValue(),
      _ => _numberValue(normalizedRank),
    };
    if (cardValue == null) return null;

    return SuitedCard(suit: cardSuit, value: cardValue);
  }
}

SuitedCardValue? _numberValue(String rank) {
  final value = int.tryParse(rank);
  if (value == null || value < 2 || value > 10) return null;
  return NumberSuitedCardValue(value: value);
}
