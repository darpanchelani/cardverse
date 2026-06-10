import 'package:cardverse/features/games/blackjack/blackjack_rules.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BlackjackRules', () {
    test('scores number, face, and Ace cards independently of model value', () {
      expect(BlackjackRules.getBlackjackCardValue(_king), 10);
      expect(BlackjackRules.getBlackjackCardValue(_ace), 11);
      expect(BlackjackRules.getBlackjackCardValue(_nine), 9);
    });

    test('adjusts one or more Aces from 11 to 1', () {
      expect(BlackjackRules.calculateHandValue([_ace, _king]), 21);
      expect(BlackjackRules.calculateHandValue([_ace, _nine]), 20);
      expect(BlackjackRules.calculateHandValue([_ace, _nine, _five]), 15);
      expect(BlackjackRules.calculateHandValue([_ace, _ace, _nine]), 21);
      expect(BlackjackRules.calculateHandValue([_ace, _ace, _nine, _five]), 16);
    });

    test('detects natural Blackjack only with two cards', () {
      expect(BlackjackRules.isBlackjack([_ace, _king]), isTrue);
      expect(BlackjackRules.isBlackjack([_ace, _five, _five]), isFalse);
    });

    test('dealer hits below 17 and stands on 17', () {
      expect(BlackjackRules.shouldDealerHit([_ten, _six]), isTrue);
      expect(BlackjackRules.shouldDealerHit([_ten, _seven]), isFalse);
    });

    test('compares busts, Blackjacks, scores, and pushes', () {
      expect(
        BlackjackRules.compareHands([_king, _queen, _five], [_ten, _seven]),
        BlackjackRoundResult.playerBust,
      );
      expect(
        BlackjackRules.compareHands([_ten, _seven], [_king, _queen, _five]),
        BlackjackRoundResult.dealerBust,
      );
      expect(
        BlackjackRules.compareHands([_ace, _king], [_ten, _nine]),
        BlackjackRoundResult.playerBlackjack,
      );
      expect(
        BlackjackRules.compareHands([_ten, _eight], [_king, _eight]),
        BlackjackRoundResult.push,
      );
    });
  });
}

const _ace = PlayingCardModel(
  suit: 'hearts',
  rank: 'A',
  value: 14,
  displayName: 'A of Hearts',
  suitSymbol: '♥',
  colorType: CardColorType.red,
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
  suit: 'clubs',
  rank: 'Q',
  value: 12,
  displayName: 'Q of Clubs',
  suitSymbol: '♣',
  colorType: CardColorType.black,
);
const _ten = PlayingCardModel(
  suit: 'diamonds',
  rank: '10',
  value: 10,
  displayName: '10 of Diamonds',
  suitSymbol: '♦',
  colorType: CardColorType.red,
);
const _nine = PlayingCardModel(
  suit: 'clubs',
  rank: '9',
  value: 9,
  displayName: '9 of Clubs',
  suitSymbol: '♣',
  colorType: CardColorType.black,
);
const _eight = PlayingCardModel(
  suit: 'hearts',
  rank: '8',
  value: 8,
  displayName: '8 of Hearts',
  suitSymbol: '♥',
  colorType: CardColorType.red,
);
const _seven = PlayingCardModel(
  suit: 'spades',
  rank: '7',
  value: 7,
  displayName: '7 of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
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
  suit: 'diamonds',
  rank: '5',
  value: 5,
  displayName: '5 of Diamonds',
  suitSymbol: '♦',
  colorType: CardColorType.red,
);
