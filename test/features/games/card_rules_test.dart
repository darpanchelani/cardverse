import 'package:cardverse/features/games/engine/card_rules.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const ace = PlayingCardModel(
    suit: 'hearts',
    rank: 'A',
    value: 14,
    displayName: 'A of Hearts',
    suitSymbol: '♥',
    colorType: CardColorType.red,
  );
  const king = PlayingCardModel(
    suit: 'spades',
    rank: 'K',
    value: 13,
    displayName: 'K of Spades',
    suitSymbol: '♠',
    colorType: CardColorType.black,
  );
  const otherAce = PlayingCardModel(
    suit: 'clubs',
    rank: 'A',
    value: 14,
    displayName: 'A of Clubs',
    suitSymbol: '♣',
    colorType: CardColorType.black,
  );

  test('higher player value wins', () {
    expect(CardRules.compareCards(ace, king), CardComparisonResult.playerWin);
  });

  test('higher computer value wins', () {
    expect(CardRules.compareCards(king, ace), CardComparisonResult.computerWin);
  });

  test('equal values draw regardless of suit', () {
    expect(CardRules.compareCards(ace, otherAce), CardComparisonResult.draw);
  });
}
