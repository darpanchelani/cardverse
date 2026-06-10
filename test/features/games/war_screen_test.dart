import 'package:cardverse/app/theme.dart';
import 'package:cardverse/features/games/engine/deck_engine.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:cardverse/features/games/war/war_controller.dart';
import 'package:cardverse/features/games/war/war_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('battle reveals cards and updates ownership counts', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = WarController(deckEngine: _ScreenDeckEngine());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: WarScreen(controller: controller),
      ),
    );

    expect(find.text('Tap Battle to start'), findsOneWidget);
    expect(find.text('CV'), findsNWidgets(2));

    await tester.ensureVisible(find.text('Battle'));
    await tester.tap(find.text('Battle'));
    await tester.pumpAndSettle();

    expect(find.text('You win this battle!'), findsOneWidget);
    expect(find.text('Tap Battle to start'), findsNothing);
    expect(controller.state.playerDeck, hasLength(5));
    expect(controller.state.computerDeck, hasLength(3));
    expect(find.text('CV'), findsNothing);
  });
}

class _ScreenDeckEngine extends DeckEngine {
  @override
  List<PlayingCardModel> resetDeck() {
    return const [_card3, _card4, _card5, _ace, _card6, _card7, _card8, _card2];
  }

  @override
  List<PlayingCardModel> shuffleDeck(List<PlayingCardModel> deck) {
    return List.of(deck);
  }
}

const _ace = PlayingCardModel(
  suit: 'hearts',
  rank: 'A',
  value: 14,
  displayName: 'A of Hearts',
  suitSymbol: '♥',
  colorType: CardColorType.red,
);
const _card2 = PlayingCardModel(
  suit: 'spades',
  rank: '2',
  value: 2,
  displayName: '2 of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
const _card3 = PlayingCardModel(
  suit: 'clubs',
  rank: '3',
  value: 3,
  displayName: '3 of Clubs',
  suitSymbol: '♣',
  colorType: CardColorType.black,
);
const _card4 = PlayingCardModel(
  suit: 'clubs',
  rank: '4',
  value: 4,
  displayName: '4 of Clubs',
  suitSymbol: '♣',
  colorType: CardColorType.black,
);
const _card5 = PlayingCardModel(
  suit: 'clubs',
  rank: '5',
  value: 5,
  displayName: '5 of Clubs',
  suitSymbol: '♣',
  colorType: CardColorType.black,
);
const _card6 = PlayingCardModel(
  suit: 'spades',
  rank: '6',
  value: 6,
  displayName: '6 of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
const _card7 = PlayingCardModel(
  suit: 'spades',
  rank: '7',
  value: 7,
  displayName: '7 of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
const _card8 = PlayingCardModel(
  suit: 'spades',
  rank: '8',
  value: 8,
  displayName: '8 of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
