import 'package:cardverse/features/games/models/playing_card_model.dart';

enum CardComparisonResult { playerWin, computerWin, draw }

abstract final class CardRules {
  static CardComparisonResult compareCards(
    PlayingCardModel playerCard,
    PlayingCardModel computerCard,
  ) {
    if (playerCard.value > computerCard.value) {
      return CardComparisonResult.playerWin;
    }
    if (playerCard.value < computerCard.value) {
      return CardComparisonResult.computerWin;
    }
    return CardComparisonResult.draw;
  }
}
