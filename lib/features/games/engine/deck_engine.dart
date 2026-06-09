import 'dart:math';

import 'package:cardverse/features/games/models/playing_card_model.dart';

class DeckEngine {
  DeckEngine({Random? random}) : _random = random ?? Random();

  final Random _random;

  static const _suits = {
    'hearts': ('Hearts', '♥', CardColorType.red),
    'diamonds': ('Diamonds', '♦', CardColorType.red),
    'clubs': ('Clubs', '♣', CardColorType.black),
    'spades': ('Spades', '♠', CardColorType.black),
  };

  static const _ranks = {
    '2': 2,
    '3': 3,
    '4': 4,
    '5': 5,
    '6': 6,
    '7': 7,
    '8': 8,
    '9': 9,
    '10': 10,
    'J': 11,
    'Q': 12,
    'K': 13,
    'A': 14,
  };

  List<PlayingCardModel> createDeck() {
    return [
      for (final suit in _suits.entries)
        for (final rank in _ranks.entries)
          PlayingCardModel(
            suit: suit.key,
            rank: rank.key,
            value: rank.value,
            displayName: '${rank.key} of ${suit.value.$1}',
            suitSymbol: suit.value.$2,
            colorType: suit.value.$3,
          ),
    ];
  }

  List<PlayingCardModel> shuffleDeck(List<PlayingCardModel> deck) {
    final shuffledDeck = List<PlayingCardModel>.of(deck);
    shuffledDeck.shuffle(_random);
    return shuffledDeck;
  }

  PlayingCardModel? drawCard(List<PlayingCardModel> deck) {
    if (deck.isEmpty) return null;
    return deck.removeLast();
  }

  int remainingCards(List<PlayingCardModel> deck) => deck.length;

  List<PlayingCardModel> resetDeck() => shuffleDeck(createDeck());
}
