import 'package:cardverse/features/games/models/playing_card_model.dart';

enum BlackjackRoundResult {
  playerWin,
  dealerWin,
  push,
  playerBust,
  dealerBust,
  playerBlackjack,
  dealerBlackjack,
}

abstract final class BlackjackRules {
  static int getBlackjackCardValue(PlayingCardModel card) {
    return switch (card.rank) {
      'A' => 11,
      'K' || 'Q' || 'J' => 10,
      _ => int.tryParse(card.rank) ?? card.value.clamp(2, 10),
    };
  }

  static int calculateHandValue(List<PlayingCardModel> hand) {
    var total = 0;
    var aces = 0;

    for (final card in hand) {
      total += getBlackjackCardValue(card);
      if (card.rank == 'A') aces++;
    }

    while (total > 21 && aces > 0) {
      total -= 10;
      aces--;
    }
    return total;
  }

  static bool isBust(List<PlayingCardModel> hand) {
    return calculateHandValue(hand) > 21;
  }

  static bool isBlackjack(List<PlayingCardModel> hand) {
    return hand.length == 2 && calculateHandValue(hand) == 21;
  }

  static bool shouldDealerHit(List<PlayingCardModel> dealerHand) {
    return calculateHandValue(dealerHand) < 17;
  }

  static BlackjackRoundResult compareHands(
    List<PlayingCardModel> playerHand,
    List<PlayingCardModel> dealerHand,
  ) {
    final playerBlackjack = isBlackjack(playerHand);
    final dealerBlackjack = isBlackjack(dealerHand);
    if (playerBlackjack && dealerBlackjack) {
      return BlackjackRoundResult.push;
    }
    if (playerBlackjack) {
      return BlackjackRoundResult.playerBlackjack;
    }
    if (dealerBlackjack) {
      return BlackjackRoundResult.dealerBlackjack;
    }
    if (isBust(playerHand)) {
      return BlackjackRoundResult.playerBust;
    }
    if (isBust(dealerHand)) {
      return BlackjackRoundResult.dealerBust;
    }

    final playerValue = calculateHandValue(playerHand);
    final dealerValue = calculateHandValue(dealerHand);
    if (playerValue > dealerValue) {
      return BlackjackRoundResult.playerWin;
    }
    if (dealerValue > playerValue) {
      return BlackjackRoundResult.dealerWin;
    }
    return BlackjackRoundResult.push;
  }
}
