import 'package:cardverse/features/games/engine/card_rules.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';

class HighCardState {
  const HighCardState({
    required this.deck,
    required this.playerCard,
    required this.computerCard,
    required this.playerScore,
    required this.computerScore,
    required this.drawScore,
    required this.roundNumber,
    required this.remainingCards,
    required this.resultMessage,
    required this.isRoundPlayed,
    required this.isGameOver,
    required this.lastResult,
  });

  final List<PlayingCardModel> deck;
  final PlayingCardModel? playerCard;
  final PlayingCardModel? computerCard;
  final int playerScore;
  final int computerScore;
  final int drawScore;
  final int roundNumber;
  final int remainingCards;
  final String resultMessage;
  final bool isRoundPlayed;
  final bool isGameOver;
  final CardComparisonResult? lastResult;

  HighCardState copyWith({
    List<PlayingCardModel>? deck,
    PlayingCardModel? playerCard,
    PlayingCardModel? computerCard,
    int? playerScore,
    int? computerScore,
    int? drawScore,
    int? roundNumber,
    int? remainingCards,
    String? resultMessage,
    bool? isRoundPlayed,
    bool? isGameOver,
    CardComparisonResult? lastResult,
    bool clearCards = false,
    bool clearResult = false,
  }) {
    return HighCardState(
      deck: deck ?? this.deck,
      playerCard: clearCards ? null : playerCard ?? this.playerCard,
      computerCard: clearCards ? null : computerCard ?? this.computerCard,
      playerScore: playerScore ?? this.playerScore,
      computerScore: computerScore ?? this.computerScore,
      drawScore: drawScore ?? this.drawScore,
      roundNumber: roundNumber ?? this.roundNumber,
      remainingCards: remainingCards ?? this.remainingCards,
      resultMessage: resultMessage ?? this.resultMessage,
      isRoundPlayed: isRoundPlayed ?? this.isRoundPlayed,
      isGameOver: isGameOver ?? this.isGameOver,
      lastResult: clearResult ? null : lastResult ?? this.lastResult,
    );
  }
}
