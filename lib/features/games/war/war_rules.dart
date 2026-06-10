import 'package:cardverse/features/games/models/playing_card_model.dart';

enum WarRoundResult { playerWin, computerWin, war, draw }

class WarDraw {
  const WarDraw({required this.downCards, required this.faceUpCard});

  final List<PlayingCardModel> downCards;
  final PlayingCardModel? faceUpCard;
}

abstract final class WarRules {
  static const cardsRequiredForWar = 4;

  static WarRoundResult compareCards(
    PlayingCardModel playerCard,
    PlayingCardModel computerCard,
  ) {
    if (playerCard.value > computerCard.value) {
      return WarRoundResult.playerWin;
    }
    if (playerCard.value < computerCard.value) {
      return WarRoundResult.computerWin;
    }
    return WarRoundResult.war;
  }

  static bool canContinueWar(List<PlayingCardModel> deck) {
    return deck.length >= cardsRequiredForWar;
  }

  static WarDraw drawWarCards(List<PlayingCardModel> deck) {
    if (!canContinueWar(deck)) {
      return const WarDraw(downCards: [], faceUpCard: null);
    }

    final downCards = <PlayingCardModel>[
      deck.removeLast(),
      deck.removeLast(),
      deck.removeLast(),
    ];
    return WarDraw(downCards: downCards, faceUpCard: deck.removeLast());
  }

  static WarRoundResult determineWarWinner(
    PlayingCardModel playerWarCard,
    PlayingCardModel computerWarCard,
  ) {
    return compareCards(playerWarCard, computerWarCard);
  }
}
