import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:cardverse/features/games/war/war_rules.dart';
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

  test('compares card values and identifies war', () {
    expect(WarRules.compareCards(ace, king), WarRoundResult.playerWin);
    expect(WarRules.compareCards(king, ace), WarRoundResult.computerWin);
    expect(WarRules.compareCards(ace, otherAce), WarRoundResult.war);
  });

  test('requires four cards to continue war', () {
    expect(WarRules.canContinueWar([ace, king, ace]), isFalse);
    expect(WarRules.canContinueWar([ace, king, ace, king]), isTrue);
  });

  test('drawWarCards burns three cards and reveals one', () {
    final deck = <PlayingCardModel>[ace, king, otherAce, king];
    final draw = WarRules.drawWarCards(deck);

    expect(draw.downCards, hasLength(3));
    expect(draw.faceUpCard, ace);
    expect(deck, isEmpty);
  });
}
