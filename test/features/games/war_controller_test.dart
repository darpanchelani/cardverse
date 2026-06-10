import 'package:cardverse/features/games/engine/deck_engine.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:cardverse/features/games/war/war_controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WarController', () {
    test('starts a standard game with 26 cards each', () {
      final controller = WarController();
      addTearDown(controller.dispose);

      expect(controller.state.playerDeck, hasLength(26));
      expect(controller.state.computerDeck, hasLength(26));
      expect(controller.state.roundNumber, 0);
      expect(controller.state.resultMessage, 'Tap Battle to start');
      expect(controller.state.isGameOver, isFalse);
    });

    test('higher card captures both cards at the deck bottom', () {
      final controller = WarController(
        deckEngine: _FixedDeckEngine(_normalBattleDeck),
      );
      addTearDown(controller.dispose);

      controller.playRound();

      expect(controller.state.playerCard?.rank, 'A');
      expect(controller.state.computerCard?.rank, '2');
      expect(controller.state.playerDeck, hasLength(5));
      expect(controller.state.computerDeck, hasLength(3));
      expect(controller.state.playerRoundsWon, 1);
      expect(controller.state.computerRoundsWon, 0);
      expect(controller.state.roundNumber, 1);
      expect(controller.state.lastBattleSize, 2);
      expect(controller.state.resultMessage, 'You win this battle!');
    });

    test('equal cards trigger war and award the complete battle pile', () {
      final controller = WarController(
        deckEngine: _FixedDeckEngine(_singleWarDeck),
      );
      addTearDown(controller.dispose);

      controller.playRound();

      expect(controller.state.warCount, 1);
      expect(controller.state.playerWarDownCards, hasLength(3));
      expect(controller.state.computerWarDownCards, hasLength(3));
      expect(controller.state.playerWarCard?.rank, 'A');
      expect(controller.state.computerWarCard?.rank, '2');
      expect(controller.state.lastBattleSize, 10);
      expect(controller.state.playerDeck, hasLength(10));
      expect(controller.state.computerDeck, isEmpty);
      expect(controller.state.playerRoundsWon, 1);
      expect(controller.state.isGameOver, isTrue);
      expect(controller.state.winner, 'Player');
      expect(controller.state.resultMessage, 'You win the war!');
    });

    test('continues war when face-up war cards tie again', () {
      final controller = WarController(
        deckEngine: _FixedDeckEngine(_recursiveWarDeck),
      );
      addTearDown(controller.dispose);

      controller.playRound();

      expect(controller.state.warCount, 2);
      expect(controller.state.playerWarDownCards, hasLength(6));
      expect(controller.state.computerWarDownCards, hasLength(6));
      expect(controller.state.playerWarCard?.rank, 'K');
      expect(controller.state.computerWarCard?.rank, '3');
      expect(controller.state.lastBattleSize, 18);
      expect(controller.state.playerDeck, hasLength(18));
      expect(controller.state.winner, 'Player');
    });

    test('ends in a draw when neither side can continue war', () {
      final controller = WarController(
        deckEngine: _FixedDeckEngine(_insufficientWarDeck),
      );
      addTearDown(controller.dispose);

      controller.playRound();

      expect(controller.state.warCount, 1);
      expect(controller.state.isGameOver, isTrue);
      expect(controller.state.winner, 'Draw');
      expect(controller.state.resultMessage, 'The war ends in a draw!');
    });

    test('new game clears battle state and restores the split', () {
      final controller = WarController(
        deckEngine: _FixedDeckEngine(_normalBattleDeck),
      );
      addTearDown(controller.dispose);

      controller
        ..playRound()
        ..startNewGame();

      expect(controller.state.playerDeck, hasLength(4));
      expect(controller.state.computerDeck, hasLength(4));
      expect(controller.state.playerCard, isNull);
      expect(controller.state.computerCard, isNull);
      expect(controller.state.roundNumber, 0);
      expect(controller.state.playerRoundsWon, 0);
      expect(controller.state.warCount, 0);
      expect(controller.state.isGameOver, isFalse);
    });
  });
}

class _FixedDeckEngine extends DeckEngine {
  _FixedDeckEngine(this.cards);

  final List<PlayingCardModel> cards;

  @override
  List<PlayingCardModel> resetDeck() => List.of(cards);

  @override
  List<PlayingCardModel> shuffleDeck(List<PlayingCardModel> deck) {
    return List.of(deck);
  }
}

const _normalBattleDeck = [
  _threeClubs,
  _fourClubs,
  _fiveClubs,
  _aceHearts,
  _sixSpades,
  _sevenSpades,
  _eightSpades,
  _twoSpades,
];

const _singleWarDeck = [
  _aceHearts,
  _threeClubs,
  _fourClubs,
  _fiveClubs,
  _eightHearts,
  _twoSpades,
  _sixSpades,
  _sevenSpades,
  _nineSpades,
  _eightSpades,
];

const _recursiveWarDeck = [
  _kingHearts,
  _threeClubs,
  _fourClubs,
  _fiveClubs,
  _queenHearts,
  _sixClubs,
  _sevenClubs,
  _nineClubs,
  _eightHearts,
  _threeSpades,
  _tenSpades,
  _jackSpades,
  _sixHearts,
  _queenSpades,
  _fourSpades,
  _fiveSpades,
  _sevenSpades,
  _eightSpades,
];

const _insufficientWarDeck = [
  _threeClubs,
  _fourClubs,
  _eightHearts,
  _fiveSpades,
  _sixSpades,
  _eightSpades,
];

const _aceHearts = PlayingCardModel(
  suit: 'hearts',
  rank: 'A',
  value: 14,
  displayName: 'A of Hearts',
  suitSymbol: '♥',
  colorType: CardColorType.red,
);
const _kingHearts = PlayingCardModel(
  suit: 'hearts',
  rank: 'K',
  value: 13,
  displayName: 'K of Hearts',
  suitSymbol: '♥',
  colorType: CardColorType.red,
);
const _queenHearts = PlayingCardModel(
  suit: 'hearts',
  rank: 'Q',
  value: 12,
  displayName: 'Q of Hearts',
  suitSymbol: '♥',
  colorType: CardColorType.red,
);
const _eightHearts = PlayingCardModel(
  suit: 'hearts',
  rank: '8',
  value: 8,
  displayName: '8 of Hearts',
  suitSymbol: '♥',
  colorType: CardColorType.red,
);
const _sixHearts = PlayingCardModel(
  suit: 'hearts',
  rank: '6',
  value: 6,
  displayName: '6 of Hearts',
  suitSymbol: '♥',
  colorType: CardColorType.red,
);
const _threeClubs = PlayingCardModel(
  suit: 'clubs',
  rank: '3',
  value: 3,
  displayName: '3 of Clubs',
  suitSymbol: '♣',
  colorType: CardColorType.black,
);
const _fourClubs = PlayingCardModel(
  suit: 'clubs',
  rank: '4',
  value: 4,
  displayName: '4 of Clubs',
  suitSymbol: '♣',
  colorType: CardColorType.black,
);
const _fiveClubs = PlayingCardModel(
  suit: 'clubs',
  rank: '5',
  value: 5,
  displayName: '5 of Clubs',
  suitSymbol: '♣',
  colorType: CardColorType.black,
);
const _sixClubs = PlayingCardModel(
  suit: 'clubs',
  rank: '6',
  value: 6,
  displayName: '6 of Clubs',
  suitSymbol: '♣',
  colorType: CardColorType.black,
);
const _sevenClubs = PlayingCardModel(
  suit: 'clubs',
  rank: '7',
  value: 7,
  displayName: '7 of Clubs',
  suitSymbol: '♣',
  colorType: CardColorType.black,
);
const _nineClubs = PlayingCardModel(
  suit: 'clubs',
  rank: '9',
  value: 9,
  displayName: '9 of Clubs',
  suitSymbol: '♣',
  colorType: CardColorType.black,
);
const _twoSpades = PlayingCardModel(
  suit: 'spades',
  rank: '2',
  value: 2,
  displayName: '2 of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
const _threeSpades = PlayingCardModel(
  suit: 'spades',
  rank: '3',
  value: 3,
  displayName: '3 of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
const _fourSpades = PlayingCardModel(
  suit: 'spades',
  rank: '4',
  value: 4,
  displayName: '4 of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
const _fiveSpades = PlayingCardModel(
  suit: 'spades',
  rank: '5',
  value: 5,
  displayName: '5 of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
const _sixSpades = PlayingCardModel(
  suit: 'spades',
  rank: '6',
  value: 6,
  displayName: '6 of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
const _sevenSpades = PlayingCardModel(
  suit: 'spades',
  rank: '7',
  value: 7,
  displayName: '7 of Spades',
  suitSymbol: '♠',
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
const _nineSpades = PlayingCardModel(
  suit: 'spades',
  rank: '9',
  value: 9,
  displayName: '9 of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
const _tenSpades = PlayingCardModel(
  suit: 'spades',
  rank: '10',
  value: 10,
  displayName: '10 of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
const _jackSpades = PlayingCardModel(
  suit: 'spades',
  rank: 'J',
  value: 11,
  displayName: 'J of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
const _queenSpades = PlayingCardModel(
  suit: 'spades',
  rank: 'Q',
  value: 12,
  displayName: 'Q of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
