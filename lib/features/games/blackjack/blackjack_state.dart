import 'package:cardverse/features/games/blackjack/blackjack_rules.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';

class BlackjackState {
  const BlackjackState({
    required this.deck,
    required this.playerHand,
    required this.dealerHand,
    required this.playerScore,
    required this.dealerScore,
    required this.chips,
    required this.currentBet,
    required this.roundNumber,
    required this.wins,
    required this.losses,
    required this.pushes,
    required this.resultMessage,
    required this.isRoundStarted,
    required this.isPlayerTurn,
    required this.isDealerTurn,
    required this.isRoundOver,
    required this.isDealerCardHidden,
    required this.isGameOver,
    required this.roundResult,
  });

  final List<PlayingCardModel> deck;
  final List<PlayingCardModel> playerHand;
  final List<PlayingCardModel> dealerHand;
  final int playerScore;
  final int dealerScore;
  final int chips;
  final int currentBet;
  final int roundNumber;
  final int wins;
  final int losses;
  final int pushes;
  final String resultMessage;
  final bool isRoundStarted;
  final bool isPlayerTurn;
  final bool isDealerTurn;
  final bool isRoundOver;
  final bool isDealerCardHidden;
  final bool isGameOver;
  final BlackjackRoundResult? roundResult;

  bool get canChangeBet => !isRoundStarted || isRoundOver;

  BlackjackState copyWith({
    List<PlayingCardModel>? deck,
    List<PlayingCardModel>? playerHand,
    List<PlayingCardModel>? dealerHand,
    int? playerScore,
    int? dealerScore,
    int? chips,
    int? currentBet,
    int? roundNumber,
    int? wins,
    int? losses,
    int? pushes,
    String? resultMessage,
    bool? isRoundStarted,
    bool? isPlayerTurn,
    bool? isDealerTurn,
    bool? isRoundOver,
    bool? isDealerCardHidden,
    bool? isGameOver,
    BlackjackRoundResult? roundResult,
    bool clearRoundResult = false,
  }) {
    return BlackjackState(
      deck: deck ?? this.deck,
      playerHand: playerHand ?? this.playerHand,
      dealerHand: dealerHand ?? this.dealerHand,
      playerScore: playerScore ?? this.playerScore,
      dealerScore: dealerScore ?? this.dealerScore,
      chips: chips ?? this.chips,
      currentBet: currentBet ?? this.currentBet,
      roundNumber: roundNumber ?? this.roundNumber,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      pushes: pushes ?? this.pushes,
      resultMessage: resultMessage ?? this.resultMessage,
      isRoundStarted: isRoundStarted ?? this.isRoundStarted,
      isPlayerTurn: isPlayerTurn ?? this.isPlayerTurn,
      isDealerTurn: isDealerTurn ?? this.isDealerTurn,
      isRoundOver: isRoundOver ?? this.isRoundOver,
      isDealerCardHidden: isDealerCardHidden ?? this.isDealerCardHidden,
      isGameOver: isGameOver ?? this.isGameOver,
      roundResult: clearRoundResult ? null : roundResult ?? this.roundResult,
    );
  }
}
