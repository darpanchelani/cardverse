import 'package:cardverse/features/games/blackjack/blackjack_controller.dart';
import 'package:cardverse/features/games/blackjack/blackjack_rules.dart';
import 'package:cardverse/features/games/engine/deck_engine.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BlackjackController', () {
    test('starts with chips, default bet, empty hands, and fresh stats', () {
      final controller = BlackjackController();
      addTearDown(controller.dispose);

      expect(controller.state.chips, 1000);
      expect(controller.state.currentBet, 50);
      expect(controller.state.playerHand, isEmpty);
      expect(controller.state.dealerHand, isEmpty);
      expect(controller.state.roundNumber, 0);
      expect(
        controller.state.resultMessage,
        'Place your bet and start the round',
      );
    });

    test('changes bet before a round and locks it during play', () {
      final controller = BlackjackController(
        deckEngine: _FixedDeckEngine(_activeRoundDeck),
      );
      addTearDown(controller.dispose);

      controller
        ..placeBet(100)
        ..startRound()
        ..placeBet(250);

      expect(controller.state.currentBet, 100);
      expect(controller.state.isPlayerTurn, isTrue);
      expect(controller.state.playerHand, hasLength(2));
      expect(controller.state.dealerHand, hasLength(2));
      expect(controller.state.isDealerCardHidden, isTrue);
    });

    test('player Blackjack wins bonus chips immediately', () {
      final controller = BlackjackController(
        deckEngine: _FixedDeckEngine(_playerBlackjackDeck),
      );
      addTearDown(controller.dispose);

      controller.startRound();

      expect(
        controller.state.roundResult,
        BlackjackRoundResult.playerBlackjack,
      );
      expect(controller.state.chips, 1100);
      expect(controller.state.wins, 1);
      expect(controller.state.isRoundOver, isTrue);
      expect(controller.state.isDealerCardHidden, isFalse);
    });

    test('both natural Blackjacks create a push', () {
      final controller = BlackjackController(
        deckEngine: _FixedDeckEngine(_doubleBlackjackDeck),
      );
      addTearDown(controller.dispose);

      controller.startRound();

      expect(controller.state.roundResult, BlackjackRoundResult.push);
      expect(controller.state.chips, 1000);
      expect(controller.state.pushes, 1);
    });

    test('hit adds a card and player bust deducts the bet', () {
      final controller = BlackjackController(
        deckEngine: _FixedDeckEngine(_playerBustDeck),
      );
      addTearDown(controller.dispose);

      controller
        ..startRound()
        ..hit();

      expect(controller.state.playerHand, hasLength(3));
      expect(controller.state.playerScore, 25);
      expect(controller.state.roundResult, BlackjackRoundResult.playerBust);
      expect(controller.state.chips, 950);
      expect(controller.state.losses, 1);
      expect(controller.state.isDealerCardHidden, isFalse);
    });

    test('stand makes dealer hit until 17 and awards dealer bust win', () {
      final controller = BlackjackController(
        deckEngine: _FixedDeckEngine(_dealerBustDeck),
      );
      addTearDown(controller.dispose);

      controller
        ..startRound()
        ..stand();

      expect(controller.state.dealerHand, hasLength(3));
      expect(controller.state.dealerScore, 25);
      expect(controller.state.roundResult, BlackjackRoundResult.dealerBust);
      expect(controller.state.chips, 1050);
      expect(controller.state.wins, 1);
      expect(controller.state.isDealerTurn, isFalse);
    });

    test('equal final scores push and leave chips unchanged', () {
      final controller = BlackjackController(
        deckEngine: _FixedDeckEngine(_pushDeck),
      );
      addTearDown(controller.dispose);

      controller
        ..startRound()
        ..stand();

      expect(controller.state.playerScore, 18);
      expect(controller.state.dealerScore, 18);
      expect(controller.state.roundResult, BlackjackRoundResult.push);
      expect(controller.state.chips, 1000);
      expect(controller.state.pushes, 1);
    });

    test('next round clears hands and increments the round number', () {
      final controller = BlackjackController(
        deckEngine: _FixedDeckEngine(_multiRoundDeck),
      );
      addTearDown(controller.dispose);

      controller
        ..startRound()
        ..stand()
        ..startRound();

      expect(controller.state.roundNumber, 2);
      expect(controller.state.playerHand, hasLength(2));
      expect(controller.state.dealerHand, hasLength(2));
      expect(controller.state.isRoundOver, isFalse);
    });

    test('new game resets chips, stats, hands, bet, and rounds', () {
      final controller = BlackjackController(
        deckEngine: _FixedDeckEngine(_playerBustDeck),
      );
      addTearDown(controller.dispose);

      controller
        ..startRound()
        ..hit()
        ..startNewGame();

      expect(controller.state.chips, 1000);
      expect(controller.state.currentBet, 50);
      expect(controller.state.wins, 0);
      expect(controller.state.losses, 0);
      expect(controller.state.pushes, 0);
      expect(controller.state.roundNumber, 0);
      expect(controller.state.playerHand, isEmpty);
      expect(controller.state.dealerHand, isEmpty);
    });

    test('losing the final chips marks the game over', () {
      final controller = BlackjackController(
        deckEngine: _FixedDeckEngine(_playerBustDeck),
      );
      addTearDown(controller.dispose);

      controller
        ..placeBet(1000)
        ..startRound()
        ..hit();

      expect(controller.state.chips, 0);
      expect(controller.state.isGameOver, isTrue);
      expect(
        controller.state.resultMessage,
        'You are out of chips. Start a new game.',
      );
    });
  });
}

class _FixedDeckEngine extends DeckEngine {
  _FixedDeckEngine(this.cards);

  final List<PlayingCardModel> cards;

  @override
  List<PlayingCardModel> resetDeck() => List.of(cards);
}

// Cards are drawn from the end. Deal order is player, dealer, player, dealer.
const _activeRoundDeck = [..._filler, _seven, _nine, _eight, _ten];
const _playerBlackjackDeck = [..._filler, _nine, _king, _eight, _ace];
const _doubleBlackjackDeck = [..._filler, _queen, _king, _aceSpades, _ace];
const _playerBustDeck = [..._filler, _five, _seven, _king, _nine, _ten];
const _dealerBustDeck = [..._filler, _nine, _six, _seven, _ten, _tenClubs];
const _pushDeck = [..._filler, _eight, _eightSpades, _ten, _tenClubs];
const _multiRoundDeck = [
  ..._filler,
  _nine,
  _eight,
  _seven,
  _ten,
  _six,
  _nine,
  _eightSpades,
  _tenClubs,
];

const _filler = [
  _two,
  _three,
  _four,
  _five,
  _six,
  _seven,
  _eight,
  _nine,
  _ten,
  _two,
  _three,
  _four,
  _five,
  _six,
  _seven,
];

const _ace = PlayingCardModel(
  suit: 'hearts',
  rank: 'A',
  value: 14,
  displayName: 'A of Hearts',
  suitSymbol: '♥',
  colorType: CardColorType.red,
);
const _aceSpades = PlayingCardModel(
  suit: 'spades',
  rank: 'A',
  value: 14,
  displayName: 'A of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
const _king = PlayingCardModel(
  suit: 'spades',
  rank: 'K',
  value: 13,
  displayName: 'K of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
const _queen = PlayingCardModel(
  suit: 'diamonds',
  rank: 'Q',
  value: 12,
  displayName: 'Q of Diamonds',
  suitSymbol: '♦',
  colorType: CardColorType.red,
);
const _ten = PlayingCardModel(
  suit: 'hearts',
  rank: '10',
  value: 10,
  displayName: '10 of Hearts',
  suitSymbol: '♥',
  colorType: CardColorType.red,
);
const _tenClubs = PlayingCardModel(
  suit: 'clubs',
  rank: '10',
  value: 10,
  displayName: '10 of Clubs',
  suitSymbol: '♣',
  colorType: CardColorType.black,
);
const _nine = PlayingCardModel(
  suit: 'diamonds',
  rank: '9',
  value: 9,
  displayName: '9 of Diamonds',
  suitSymbol: '♦',
  colorType: CardColorType.red,
);
const _eight = PlayingCardModel(
  suit: 'clubs',
  rank: '8',
  value: 8,
  displayName: '8 of Clubs',
  suitSymbol: '♣',
  colorType: CardColorType.black,
);
const _eightSpades = PlayingCardModel(
  suit: 'spades',
  rank: '8',
  value: 8,
  displayName: '8 of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
const _seven = PlayingCardModel(
  suit: 'hearts',
  rank: '7',
  value: 7,
  displayName: '7 of Hearts',
  suitSymbol: '♥',
  colorType: CardColorType.red,
);
const _six = PlayingCardModel(
  suit: 'clubs',
  rank: '6',
  value: 6,
  displayName: '6 of Clubs',
  suitSymbol: '♣',
  colorType: CardColorType.black,
);
const _five = PlayingCardModel(
  suit: 'spades',
  rank: '5',
  value: 5,
  displayName: '5 of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
const _four = PlayingCardModel(
  suit: 'hearts',
  rank: '4',
  value: 4,
  displayName: '4 of Hearts',
  suitSymbol: '♥',
  colorType: CardColorType.red,
);
const _three = PlayingCardModel(
  suit: 'clubs',
  rank: '3',
  value: 3,
  displayName: '3 of Clubs',
  suitSymbol: '♣',
  colorType: CardColorType.black,
);
const _two = PlayingCardModel(
  suit: 'diamonds',
  rank: '2',
  value: 2,
  displayName: '2 of Diamonds',
  suitSymbol: '♦',
  colorType: CardColorType.red,
);
