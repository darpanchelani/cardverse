import 'package:cardverse/app/theme.dart';
import 'package:cardverse/features/games/blackjack/blackjack_controller.dart';
import 'package:cardverse/features/games/blackjack/blackjack_screen.dart';
import 'package:cardverse/features/games/engine/deck_engine.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('starts a round, hides dealer card, and shows Hit and Stand', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final controller = BlackjackController(deckEngine: _ScreenDeckEngine());
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: BlackjackScreen(controller: controller),
      ),
    );

    expect(find.text('1000'), findsOneWidget);
    expect(find.text('Place your bet and start the round'), findsOneWidget);

    await tester.ensureVisible(find.text('Start Round'));
    await tester.tap(find.text('Start Round'));
    await tester.pumpAndSettle();

    expect(controller.state.playerHand, hasLength(2));
    expect(controller.state.dealerHand, hasLength(2));
    expect(controller.state.isDealerCardHidden, isTrue);
    expect(find.text('Hit'), findsOneWidget);
    expect(find.text('Stand'), findsOneWidget);
    expect(find.text('CV'), findsOneWidget);
  });
}

class _ScreenDeckEngine extends DeckEngine {
  @override
  List<PlayingCardModel> resetDeck() {
    return const [
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
      _eight,
      _nine,
      _seven,
      _eight,
      _ten,
    ];
  }
}

const _ten = PlayingCardModel(
  suit: 'hearts',
  rank: '10',
  value: 10,
  displayName: '10 of Hearts',
  suitSymbol: '♥',
  colorType: CardColorType.red,
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
  suit: 'hearts',
  rank: '5',
  value: 5,
  displayName: '5 of Hearts',
  suitSymbol: '♥',
  colorType: CardColorType.red,
);
const _four = PlayingCardModel(
  suit: 'diamonds',
  rank: '4',
  value: 4,
  displayName: '4 of Diamonds',
  suitSymbol: '♦',
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
  suit: 'spades',
  rank: '2',
  value: 2,
  displayName: '2 of Spades',
  suitSymbol: '♠',
  colorType: CardColorType.black,
);
