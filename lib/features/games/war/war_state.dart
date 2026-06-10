import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:cardverse/features/games/war/war_rules.dart';

class WarState {
  const WarState({
    required this.playerDeck,
    required this.computerDeck,
    required this.battlePile,
    required this.playerCard,
    required this.computerCard,
    required this.playerWarDownCards,
    required this.computerWarDownCards,
    required this.playerWarCard,
    required this.computerWarCard,
    required this.roundNumber,
    required this.playerRoundsWon,
    required this.computerRoundsWon,
    required this.warCount,
    required this.resultMessage,
    required this.isRoundPlayed,
    required this.isWarActive,
    required this.isGameOver,
    required this.winner,
    required this.lastResult,
    required this.lastBattleSize,
  });

  final List<PlayingCardModel> playerDeck;
  final List<PlayingCardModel> computerDeck;
  final List<PlayingCardModel> battlePile;
  final PlayingCardModel? playerCard;
  final PlayingCardModel? computerCard;
  final List<PlayingCardModel> playerWarDownCards;
  final List<PlayingCardModel> computerWarDownCards;
  final PlayingCardModel? playerWarCard;
  final PlayingCardModel? computerWarCard;
  final int roundNumber;
  final int playerRoundsWon;
  final int computerRoundsWon;
  final int warCount;
  final String resultMessage;
  final bool isRoundPlayed;
  final bool isWarActive;
  final bool isGameOver;
  final String? winner;
  final WarRoundResult? lastResult;

  // Retains the captured pile size after ownership has been resolved.
  final int lastBattleSize;

  WarState copyWith({
    List<PlayingCardModel>? playerDeck,
    List<PlayingCardModel>? computerDeck,
    List<PlayingCardModel>? battlePile,
    PlayingCardModel? playerCard,
    PlayingCardModel? computerCard,
    List<PlayingCardModel>? playerWarDownCards,
    List<PlayingCardModel>? computerWarDownCards,
    PlayingCardModel? playerWarCard,
    PlayingCardModel? computerWarCard,
    int? roundNumber,
    int? playerRoundsWon,
    int? computerRoundsWon,
    int? warCount,
    String? resultMessage,
    bool? isRoundPlayed,
    bool? isWarActive,
    bool? isGameOver,
    String? winner,
    WarRoundResult? lastResult,
    int? lastBattleSize,
    bool clearRoundCards = false,
    bool clearWinner = false,
    bool clearResult = false,
  }) {
    return WarState(
      playerDeck: playerDeck ?? this.playerDeck,
      computerDeck: computerDeck ?? this.computerDeck,
      battlePile: battlePile ?? this.battlePile,
      playerCard: clearRoundCards ? null : playerCard ?? this.playerCard,
      computerCard: clearRoundCards ? null : computerCard ?? this.computerCard,
      playerWarDownCards: clearRoundCards
          ? const []
          : playerWarDownCards ?? this.playerWarDownCards,
      computerWarDownCards: clearRoundCards
          ? const []
          : computerWarDownCards ?? this.computerWarDownCards,
      playerWarCard: clearRoundCards
          ? null
          : playerWarCard ?? this.playerWarCard,
      computerWarCard: clearRoundCards
          ? null
          : computerWarCard ?? this.computerWarCard,
      roundNumber: roundNumber ?? this.roundNumber,
      playerRoundsWon: playerRoundsWon ?? this.playerRoundsWon,
      computerRoundsWon: computerRoundsWon ?? this.computerRoundsWon,
      warCount: warCount ?? this.warCount,
      resultMessage: resultMessage ?? this.resultMessage,
      isRoundPlayed: isRoundPlayed ?? this.isRoundPlayed,
      isWarActive: isWarActive ?? this.isWarActive,
      isGameOver: isGameOver ?? this.isGameOver,
      winner: clearWinner ? null : winner ?? this.winner,
      lastResult: clearResult ? null : lastResult ?? this.lastResult,
      lastBattleSize: lastBattleSize ?? this.lastBattleSize,
    );
  }
}
