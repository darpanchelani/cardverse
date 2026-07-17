import 'package:card_game/card_game.dart';
import 'package:cardverse/features/games/adapters/card_game_adapter.dart';
import 'package:cardverse/features/games/engine/deck_engine.dart';
import 'package:cardverse/features/games/high_card/widgets/playing_card_widget.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CardGameAdapter', () {
    test('converts every card in the CardVerse deck', () {
      final deck = DeckEngine().createDeck();

      expect(deck, hasLength(52));
      expect(deck.map((card) => card.cardGameCard), everyElement(isNotNull));
    });

    test('maps a face card to the illustrated deck model', () {
      const card = PlayingCardModel(
        suit: 'hearts',
        rank: 'K',
        value: 13,
        displayName: 'King of Hearts',
        suitSymbol: '♥',
        colorType: CardColorType.red,
      );

      final renderedCard = card.cardGameCard;

      expect(renderedCard?.suit, CardSuit.hearts);
      expect(renderedCard?.value, isA<KingSuitedCardValue>());
    });

    test('returns null for malformed card data', () {
      const card = PlayingCardModel(
        suit: 'stars',
        rank: '1',
        value: 1,
        displayName: 'Unknown card',
        suitSymbol: '★',
        colorType: CardColorType.black,
      );

      expect(card.cardGameCard, isNull);
    });

    testWidgets('uses the SVG renderer for a face card', (tester) async {
      const card = PlayingCardModel(
        suit: 'hearts',
        rank: 'K',
        value: 13,
        displayName: 'King of Hearts',
        suitSymbol: '♥',
        colorType: CardColorType.red,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Center(
            child: SizedBox(width: 120, child: PlayingCardWidget(card: card)),
          ),
        ),
      );

      expect(find.byType(SuitedCardBuilder), findsOneWidget);
    });
  });
}
