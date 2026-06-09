import 'dart:math';

import 'package:cardverse/features/games/engine/deck_engine.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DeckEngine', () {
    final engine = DeckEngine(random: Random(7));

    test('creates a standard 52-card deck', () {
      final deck = engine.createDeck();
      final uniqueCards = deck
          .map((card) => '${card.rank}-${card.suit}')
          .toSet();

      expect(deck, hasLength(52));
      expect(uniqueCards, hasLength(52));
      expect(deck.where((card) => card.suit == 'hearts'), hasLength(13));
      expect(deck.where((card) => card.suit == 'diamonds'), hasLength(13));
      expect(deck.where((card) => card.suit == 'clubs'), hasLength(13));
      expect(deck.where((card) => card.suit == 'spades'), hasLength(13));
    });

    test('assigns correct ace values, symbols, and colors', () {
      final deck = engine.createDeck();
      final aceOfHearts = deck.singleWhere(
        (card) => card.rank == 'A' && card.suit == 'hearts',
      );
      final aceOfSpades = deck.singleWhere(
        (card) => card.rank == 'A' && card.suit == 'spades',
      );

      expect(aceOfHearts.value, 14);
      expect(aceOfHearts.displayName, 'A of Hearts');
      expect(aceOfHearts.suitSymbol, '♥');
      expect(aceOfHearts.colorType, CardColorType.red);
      expect(aceOfSpades.suitSymbol, '♠');
      expect(aceOfSpades.colorType, CardColorType.black);
    });

    test('draw removes one card and updates remaining count', () {
      final deck = engine.createDeck();
      final card = engine.drawCard(deck);

      expect(card, isNotNull);
      expect(engine.remainingCards(deck), 51);
    });

    test('draw returns null for an empty deck', () {
      expect(engine.drawCard([]), isNull);
    });
  });
}
