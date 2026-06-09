import 'package:cardverse/features/games/engine/deck_engine.dart';
import 'package:cardverse/features/games/high_card/high_card_controller.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HighCardController', () {
    late HighCardController controller;

    setUp(() {
      controller = HighCardController(deckEngine: _FixedDeckEngine());
    });

    tearDown(() {
      controller.dispose();
    });

    test('starts with a fresh shuffled deck state', () {
      expect(controller.state.playerCard, isNull);
      expect(controller.state.computerCard, isNull);
      expect(controller.state.playerScore, 0);
      expect(controller.state.roundNumber, 0);
      expect(controller.state.remainingCards, 4);
      expect(controller.state.resultMessage, 'Tap Draw Cards to start');
      expect(controller.state.isGameOver, isFalse);
    });

    test('draws two cards and awards the correct score', () {
      controller.drawCards();

      expect(controller.state.playerCard?.rank, 'A');
      expect(controller.state.computerCard?.rank, '2');
      expect(controller.state.playerScore, 1);
      expect(controller.state.computerScore, 0);
      expect(controller.state.drawScore, 0);
      expect(controller.state.roundNumber, 1);
      expect(controller.state.remainingCards, 2);
      expect(controller.state.resultMessage, 'You win this round!');
    });

    test('resetScores keeps the current deck and round', () {
      controller.drawCards();
      controller.resetScores();

      expect(controller.state.playerScore, 0);
      expect(controller.state.computerScore, 0);
      expect(controller.state.drawScore, 0);
      expect(controller.state.roundNumber, 1);
      expect(controller.state.remainingCards, 2);
      expect(controller.state.playerCard?.rank, 'A');
    });

    test('marks game over after the final playable round', () {
      controller.drawCards();
      controller.drawCards();

      expect(controller.state.roundNumber, 2);
      expect(controller.state.remainingCards, 0);
      expect(controller.state.isGameOver, isTrue);
      expect(
        controller.state.resultMessage,
        'Deck finished! Start a new game.',
      );
    });

    test('new game resets deck, cards, rounds, and scores', () {
      controller
        ..drawCards()
        ..startNewGame();

      expect(controller.state.playerCard, isNull);
      expect(controller.state.computerCard, isNull);
      expect(controller.state.playerScore, 0);
      expect(controller.state.computerScore, 0);
      expect(controller.state.drawScore, 0);
      expect(controller.state.roundNumber, 0);
      expect(controller.state.remainingCards, 4);
      expect(controller.state.isGameOver, isFalse);
    });
  });
}

class _FixedDeckEngine extends DeckEngine {
  @override
  List<PlayingCardModel> resetDeck() {
    return const [
      PlayingCardModel(
        suit: 'clubs',
        rank: 'K',
        value: 13,
        displayName: 'K of Clubs',
        suitSymbol: '♣',
        colorType: CardColorType.black,
      ),
      PlayingCardModel(
        suit: 'diamonds',
        rank: 'Q',
        value: 12,
        displayName: 'Q of Diamonds',
        suitSymbol: '♦',
        colorType: CardColorType.red,
      ),
      PlayingCardModel(
        suit: 'spades',
        rank: '2',
        value: 2,
        displayName: '2 of Spades',
        suitSymbol: '♠',
        colorType: CardColorType.black,
      ),
      PlayingCardModel(
        suit: 'hearts',
        rank: 'A',
        value: 14,
        displayName: 'A of Hearts',
        suitSymbol: '♥',
        colorType: CardColorType.red,
      ),
    ];
  }
}
