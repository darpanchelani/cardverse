import 'dart:async';

import 'package:cardverse/features/games/engine/deck_engine.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:cardverse/features/games/war/war_rules.dart';
import 'package:cardverse/features/games/war/war_state.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:flutter/foundation.dart';

class WarController extends ChangeNotifier {
  WarController({
    DeckEngine? deckEngine,
    ProgressController? progressController,
  }) : _deckEngine = deckEngine ?? DeckEngine(),
       _progressController =
           progressController ?? ProgressController.maybeInstance {
    _state = _newGameState();
  }

  final DeckEngine _deckEngine;
  final ProgressController? _progressController;
  late WarState _state;
  bool _isPlaying = false;
  bool _resultRecorded = false;
  int _gameSession = 0;

  WarState get state => _state;

  WarState _newGameState() {
    final deck = _deckEngine.resetDeck();
    final splitIndex = deck.length ~/ 2;
    return WarState(
      playerDeck: List.of(deck.sublist(0, splitIndex)),
      computerDeck: List.of(deck.sublist(splitIndex)),
      battlePile: const [],
      playerCard: null,
      computerCard: null,
      playerWarDownCards: const [],
      computerWarDownCards: const [],
      playerWarCard: null,
      computerWarCard: null,
      roundNumber: 0,
      playerRoundsWon: 0,
      computerRoundsWon: 0,
      warCount: 0,
      resultMessage: 'Tap Battle to start',
      isRoundPlayed: false,
      isWarActive: false,
      isGameOver: false,
      winner: null,
      lastResult: null,
      lastBattleSize: 0,
    );
  }

  void startNewGame() {
    _gameSession++;
    _resultRecorded = false;
    _state = _newGameState();
    notifyListeners();
  }

  void playRound() {
    if (_isPlaying || _state.isGameOver) return;
    _isPlaying = true;

    resetRoundCards(notify: false);
    final playerDeck = List<PlayingCardModel>.of(_state.playerDeck);
    final computerDeck = List<PlayingCardModel>.of(_state.computerDeck);
    final battlePile = <PlayingCardModel>[];

    if (playerDeck.isEmpty || computerDeck.isEmpty) {
      _isPlaying = false;
      checkGameOver();
      return;
    }

    final playerCard = playerDeck.removeLast();
    final computerCard = computerDeck.removeLast();
    battlePile.addAll([playerCard, computerCard]);
    final result = WarRules.compareCards(playerCard, computerCard);

    _state = _state.copyWith(
      playerDeck: playerDeck,
      computerDeck: computerDeck,
      battlePile: battlePile,
      playerCard: playerCard,
      computerCard: computerCard,
      roundNumber: _state.roundNumber + 1,
      isRoundPlayed: true,
      lastResult: result,
      lastBattleSize: battlePile.length,
    );

    if (result == WarRoundResult.war) {
      handleWar();
    } else {
      resolveBattle(result);
    }

    checkGameOver(notify: false);
    _recordGameIfFinished();
    _isPlaying = false;
    notifyListeners();
  }

  void handleWar() {
    var playerDeck = List<PlayingCardModel>.of(_state.playerDeck);
    var computerDeck = List<PlayingCardModel>.of(_state.computerDeck);
    final battlePile = List<PlayingCardModel>.of(_state.battlePile);
    final allPlayerDownCards = <PlayingCardModel>[];
    final allComputerDownCards = <PlayingCardModel>[];
    PlayingCardModel? playerWarCard;
    PlayingCardModel? computerWarCard;
    var warCount = _state.warCount;

    while (true) {
      warCount++;
      _state = _state.copyWith(
        playerDeck: playerDeck,
        computerDeck: computerDeck,
        battlePile: battlePile,
        playerWarDownCards: allPlayerDownCards,
        computerWarDownCards: allComputerDownCards,
        playerWarCard: playerWarCard,
        computerWarCard: computerWarCard,
        warCount: warCount,
        resultMessage: 'War! Both cards are equal.',
        isWarActive: true,
        lastResult: WarRoundResult.war,
        lastBattleSize: battlePile.length,
      );

      final playerCanContinue = WarRules.canContinueWar(playerDeck);
      final computerCanContinue = WarRules.canContinueWar(computerDeck);
      if (!playerCanContinue || !computerCanContinue) {
        _resolveInsufficientWarCards(
          playerCanContinue: playerCanContinue,
          computerCanContinue: computerCanContinue,
          playerDeck: playerDeck,
          computerDeck: computerDeck,
          battlePile: battlePile,
          playerDownCards: allPlayerDownCards,
          computerDownCards: allComputerDownCards,
          playerWarCard: playerWarCard,
          computerWarCard: computerWarCard,
          warCount: warCount,
        );
        return;
      }

      final playerDraw = WarRules.drawWarCards(playerDeck);
      final computerDraw = WarRules.drawWarCards(computerDeck);
      allPlayerDownCards.addAll(playerDraw.downCards);
      allComputerDownCards.addAll(computerDraw.downCards);
      playerWarCard = playerDraw.faceUpCard;
      computerWarCard = computerDraw.faceUpCard;
      battlePile.addAll(playerDraw.downCards);
      battlePile.addAll(computerDraw.downCards);
      battlePile.addAll([playerWarCard!, computerWarCard!]);

      final warResult = WarRules.determineWarWinner(
        playerWarCard,
        computerWarCard,
      );
      _state = _state.copyWith(
        playerDeck: playerDeck,
        computerDeck: computerDeck,
        battlePile: battlePile,
        playerWarDownCards: List.of(allPlayerDownCards),
        computerWarDownCards: List.of(allComputerDownCards),
        playerWarCard: playerWarCard,
        computerWarCard: computerWarCard,
        warCount: warCount,
        lastResult: warResult,
        lastBattleSize: battlePile.length,
      );

      if (warResult != WarRoundResult.war) {
        resolveBattle(warResult);
        return;
      }
    }
  }

  void resolveBattle(WarRoundResult result) {
    if (result != WarRoundResult.playerWin &&
        result != WarRoundResult.computerWin) {
      return;
    }

    addCardsToWinner(result);
    _state = _state.copyWith(
      playerRoundsWon:
          _state.playerRoundsWon + (result == WarRoundResult.playerWin ? 1 : 0),
      computerRoundsWon:
          _state.computerRoundsWon +
          (result == WarRoundResult.computerWin ? 1 : 0),
      resultMessage: result == WarRoundResult.playerWin
          ? (_state.warCount > 0 && _state.playerWarDownCards.isNotEmpty
                ? 'You win the war!'
                : 'You win this battle!')
          : (_state.warCount > 0 && _state.computerWarDownCards.isNotEmpty
                ? 'Computer wins the war!'
                : 'Computer wins this battle!'),
      isWarActive: false,
      lastResult: result,
    );
  }

  void addCardsToWinner(WarRoundResult winner) {
    final capturedCards = _deckEngine.shuffleDeck(_state.battlePile);
    final playerDeck = List<PlayingCardModel>.of(_state.playerDeck);
    final computerDeck = List<PlayingCardModel>.of(_state.computerDeck);

    if (winner == WarRoundResult.playerWin) {
      playerDeck.insertAll(0, capturedCards);
    } else if (winner == WarRoundResult.computerWin) {
      computerDeck.insertAll(0, capturedCards);
    }

    _state = _state.copyWith(
      playerDeck: playerDeck,
      computerDeck: computerDeck,
      battlePile: const [],
      lastBattleSize: capturedCards.length,
    );
  }

  void checkGameOver({bool notify = true}) {
    if (_state.isGameOver) return;

    final playerEmpty = _state.playerDeck.isEmpty;
    final computerEmpty = _state.computerDeck.isEmpty;
    if (!playerEmpty && !computerEmpty) return;

    if (playerEmpty && computerEmpty) {
      _state = _state.copyWith(
        isGameOver: true,
        winner: 'Draw',
        resultMessage: 'The war ends in a draw!',
        lastResult: WarRoundResult.draw,
      );
    } else if (playerEmpty) {
      _state = _state.copyWith(
        isGameOver: true,
        winner: 'Computer',
        resultMessage: 'Computer wins the war!',
        lastResult: WarRoundResult.computerWin,
      );
    } else {
      _state = _state.copyWith(
        isGameOver: true,
        winner: 'Player',
        resultMessage: 'You win the war!',
        lastResult: WarRoundResult.playerWin,
      );
    }

    if (notify) notifyListeners();
  }

  void _recordGameIfFinished() {
    if (!_state.isGameOver || _resultRecorded) return;
    _resultRecorded = true;
    final progress = _progressController;
    if (progress == null) return;
    final result = switch (_state.winner) {
      'Player' => 'win',
      'Computer' => 'loss',
      _ => 'draw',
    };
    unawaited(
      progress.recordGameResult(
        recordId: 'war_${identityHashCode(this)}_$_gameSession',
        gameType: 'war',
        gameName: 'War',
        result: result,
        opponent: 'Computer',
        playerScore: _state.playerRoundsWon,
        opponentScore: _state.computerRoundsWon,
        extraData: {
          'roundsPlayed': _state.roundNumber,
          'warsTriggered': _state.warCount,
          'playerFinalCards': _state.playerDeck.length,
          'computerFinalCards': _state.computerDeck.length,
        },
      ),
    );
  }

  void resetRoundCards({bool notify = true}) {
    _state = _state.copyWith(
      battlePile: const [],
      isWarActive: false,
      lastBattleSize: 0,
      clearRoundCards: true,
      clearResult: true,
    );
    if (notify) notifyListeners();
  }

  void _resolveInsufficientWarCards({
    required bool playerCanContinue,
    required bool computerCanContinue,
    required List<PlayingCardModel> playerDeck,
    required List<PlayingCardModel> computerDeck,
    required List<PlayingCardModel> battlePile,
    required List<PlayingCardModel> playerDownCards,
    required List<PlayingCardModel> computerDownCards,
    required PlayingCardModel? playerWarCard,
    required PlayingCardModel? computerWarCard,
    required int warCount,
  }) {
    String winner;
    WarRoundResult result;
    String message;

    if (playerCanContinue && !computerCanContinue) {
      winner = 'Player';
      result = WarRoundResult.playerWin;
      message = 'Computer cannot continue. You win the war!';
    } else if (!playerCanContinue && computerCanContinue) {
      winner = 'Computer';
      result = WarRoundResult.computerWin;
      message = 'You cannot continue. Computer wins the war!';
    } else if (playerDeck.length > computerDeck.length) {
      winner = 'Player';
      result = WarRoundResult.playerWin;
      message = 'You have more cards and win the war!';
    } else if (computerDeck.length > playerDeck.length) {
      winner = 'Computer';
      result = WarRoundResult.computerWin;
      message = 'Computer has more cards and wins the war!';
    } else {
      winner = 'Draw';
      result = WarRoundResult.draw;
      message = 'The war ends in a draw!';
    }

    final remainingCards = <PlayingCardModel>[
      ...playerDeck,
      ...computerDeck,
      ...battlePile,
    ];
    final finalPlayerDeck = winner == 'Player'
        ? _deckEngine.shuffleDeck(remainingCards)
        : <PlayingCardModel>[];
    final finalComputerDeck = winner == 'Computer'
        ? _deckEngine.shuffleDeck(remainingCards)
        : <PlayingCardModel>[];

    _state = _state.copyWith(
      playerDeck: finalPlayerDeck,
      computerDeck: finalComputerDeck,
      battlePile: const [],
      playerWarDownCards: List.of(playerDownCards),
      computerWarDownCards: List.of(computerDownCards),
      playerWarCard: playerWarCard,
      computerWarCard: computerWarCard,
      warCount: warCount,
      resultMessage: message,
      isWarActive: false,
      isGameOver: true,
      winner: winner,
      lastResult: result,
      lastBattleSize: remainingCards.length,
    );
  }
}
