import 'dart:async';

import 'package:cardverse/features/games/engine/card_rules.dart';
import 'package:cardverse/features/games/engine/deck_engine.dart';
import 'package:cardverse/features/games/high_card/high_card_state.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:flutter/foundation.dart';

class HighCardController extends ChangeNotifier {
  HighCardController({
    DeckEngine? deckEngine,
    ProgressController? progressController,
  }) : _deckEngine = deckEngine ?? DeckEngine(),
       _progressController =
           progressController ?? ProgressController.maybeInstance {
    _state = _newGameState();
  }

  final DeckEngine _deckEngine;
  final ProgressController? _progressController;
  late HighCardState _state;
  bool _isDrawing = false;
  int _gameSession = 0;

  HighCardState get state => _state;

  HighCardState _newGameState() {
    final deck = _deckEngine.resetDeck();
    return HighCardState(
      deck: deck,
      playerCard: null,
      computerCard: null,
      playerScore: 0,
      computerScore: 0,
      drawScore: 0,
      roundNumber: 0,
      remainingCards: _deckEngine.remainingCards(deck),
      resultMessage: 'Tap Draw Cards to start',
      isRoundPlayed: false,
      isGameOver: false,
      lastResult: null,
    );
  }

  void startNewGame() {
    _gameSession++;
    _state = _newGameState();
    notifyListeners();
  }

  void drawCards() {
    if (_isDrawing || _state.isGameOver) return;
    if (_state.remainingCards < 2) {
      _setGameOver();
      return;
    }

    _isDrawing = true;
    final deck = List.of(_state.deck);
    final playerCard = _deckEngine.drawCard(deck);
    final computerCard = _deckEngine.drawCard(deck);

    if (playerCard == null || computerCard == null) {
      _isDrawing = false;
      _setGameOver();
      return;
    }

    final result = CardRules.compareCards(playerCard, computerCard);
    final cardsLeft = _deckEngine.remainingCards(deck);
    _state = _state.copyWith(
      deck: deck,
      playerCard: playerCard,
      computerCard: computerCard,
      playerScore:
          _state.playerScore +
          (result == CardComparisonResult.playerWin ? 1 : 0),
      computerScore:
          _state.computerScore +
          (result == CardComparisonResult.computerWin ? 1 : 0),
      drawScore:
          _state.drawScore + (result == CardComparisonResult.draw ? 1 : 0),
      roundNumber: _state.roundNumber + 1,
      remainingCards: cardsLeft,
      resultMessage: _messageFor(result),
      isRoundPlayed: true,
      isGameOver: cardsLeft < 2,
      lastResult: result,
    );

    if (_state.isGameOver) {
      _state = _state.copyWith(
        resultMessage: 'Deck finished! Start a new game.',
      );
    }
    final resultName = switch (result) {
      CardComparisonResult.playerWin => 'win',
      CardComparisonResult.computerWin => 'loss',
      CardComparisonResult.draw => 'draw',
    };
    final progress = _progressController;
    if (progress != null) {
      unawaited(
        progress.recordGameResult(
          recordId:
              'high_card_${identityHashCode(this)}_'
              '${_gameSession}_${_state.roundNumber}',
          gameType: 'high_card',
          gameName: 'High Card',
          result: resultName,
          opponent: 'Computer',
          playerScore: playerCard.value,
          opponentScore: computerCard.value,
          extraData: {
            'playerCard': playerCard.displayName,
            'computerCard': computerCard.displayName,
            'roundNumber': _state.roundNumber,
          },
        ),
      );
    }
    _isDrawing = false;
    notifyListeners();
  }

  void resetScores() {
    _state = _state.copyWith(playerScore: 0, computerScore: 0, drawScore: 0);
    notifyListeners();
  }

  void updateResult(CardComparisonResult result) {
    _state = _state.copyWith(
      resultMessage: _messageFor(result),
      lastResult: result,
    );
    notifyListeners();
  }

  void checkGameOver() {
    if (_state.remainingCards < 2 && !_state.isGameOver) {
      _setGameOver();
    }
  }

  void _setGameOver() {
    _state = _state.copyWith(
      resultMessage: 'Deck finished! Start a new game.',
      isGameOver: true,
    );
    notifyListeners();
  }

  String _messageFor(CardComparisonResult result) {
    return switch (result) {
      CardComparisonResult.playerWin => 'You win this round!',
      CardComparisonResult.computerWin => 'Computer wins this round!',
      CardComparisonResult.draw => 'It’s a draw!',
    };
  }
}
