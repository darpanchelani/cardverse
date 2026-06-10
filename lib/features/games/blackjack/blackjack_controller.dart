import 'dart:async';

import 'package:cardverse/features/games/blackjack/blackjack_rules.dart';
import 'package:cardverse/features/games/blackjack/blackjack_state.dart';
import 'package:cardverse/features/games/engine/deck_engine.dart';
import 'package:cardverse/features/games/models/playing_card_model.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:flutter/foundation.dart';

class BlackjackController extends ChangeNotifier {
  BlackjackController({
    DeckEngine? deckEngine,
    ProgressController? progressController,
  }) : _deckEngine = deckEngine ?? DeckEngine(),
       _progressController =
           progressController ?? ProgressController.maybeInstance {
    _state = _newGameState();
    unawaited(_restorePersistentChips());
  }

  static const betOptions = [10, 25, 50, 100, 250];

  final DeckEngine _deckEngine;
  final ProgressController? _progressController;
  late BlackjackState _state;
  bool _isActing = false;
  int _gameSession = 0;
  final Set<int> _recordedRounds = {};

  BlackjackState get state => _state;

  BlackjackState _newGameState() {
    return BlackjackState(
      deck: _deckEngine.resetDeck(),
      playerHand: const [],
      dealerHand: const [],
      playerScore: 0,
      dealerScore: 0,
      chips: 1000,
      currentBet: 50,
      roundNumber: 0,
      wins: 0,
      losses: 0,
      pushes: 0,
      resultMessage: 'Place your bet and start the round',
      isRoundStarted: false,
      isPlayerTurn: false,
      isDealerTurn: false,
      isRoundOver: false,
      isDealerCardHidden: true,
      isGameOver: false,
      roundResult: null,
    );
  }

  void startNewGame() {
    _gameSession++;
    _recordedRounds.clear();
    _state = _newGameState();
    unawaited(_progressController?.saveBlackjackChips(1000));
    notifyListeners();
  }

  void startRound() {
    if (_isActing || (_state.isRoundStarted && !_state.isRoundOver)) return;
    if (_state.chips <= 0) {
      _state = _state.copyWith(
        isGameOver: true,
        resultMessage: 'You are out of chips. Start a new game.',
      );
      notifyListeners();
      return;
    }

    _isActing = true;
    ensureDeckHasCards(notify: false);
    final deck = List<PlayingCardModel>.of(_state.deck);
    final playerHand = <PlayingCardModel>[];
    final dealerHand = <PlayingCardModel>[];
    final bet = _state.currentBet.clamp(1, _state.chips);

    // Alternate the deal so deterministic decks match a physical table.
    playerHand.add(_drawFrom(deck));
    dealerHand.add(_drawFrom(deck));
    playerHand.add(_drawFrom(deck));
    dealerHand.add(_drawFrom(deck));

    _state = _state.copyWith(
      deck: deck,
      playerHand: playerHand,
      dealerHand: dealerHand,
      playerScore: BlackjackRules.calculateHandValue(playerHand),
      dealerScore: BlackjackRules.calculateHandValue(dealerHand),
      currentBet: bet,
      roundNumber: _state.roundNumber + 1,
      resultMessage: 'Your turn: Hit or Stand.',
      isRoundStarted: true,
      isPlayerTurn: true,
      isDealerTurn: false,
      isRoundOver: false,
      isDealerCardHidden: true,
      isGameOver: false,
      clearRoundResult: true,
    );

    final playerBlackjack = BlackjackRules.isBlackjack(playerHand);
    final dealerBlackjack = BlackjackRules.isBlackjack(dealerHand);
    if (playerBlackjack || dealerBlackjack) {
      final result = playerBlackjack && dealerBlackjack
          ? BlackjackRoundResult.push
          : playerBlackjack
          ? BlackjackRoundResult.playerBlackjack
          : BlackjackRoundResult.dealerBlackjack;
      finishRound(result, notify: false);
    }

    _isActing = false;
    notifyListeners();
  }

  void hit() {
    if (_isActing ||
        !_state.isRoundStarted ||
        !_state.isPlayerTurn ||
        _state.isRoundOver) {
      return;
    }

    _isActing = true;
    if (_state.deck.isEmpty) ensureDeckHasCards(notify: false);
    final deck = List<PlayingCardModel>.of(_state.deck);
    final playerHand = List<PlayingCardModel>.of(_state.playerHand)
      ..add(_drawFrom(deck));
    final score = BlackjackRules.calculateHandValue(playerHand);
    _state = _state.copyWith(
      deck: deck,
      playerHand: playerHand,
      playerScore: score,
      resultMessage: score > 21
          ? 'You busted! Dealer wins.'
          : 'Choose Hit or Stand.',
    );

    if (BlackjackRules.isBust(playerHand)) {
      finishRound(BlackjackRoundResult.playerBust, notify: false);
    } else if (score == 21) {
      _standInternal();
    }

    _isActing = false;
    notifyListeners();
  }

  void stand() {
    if (_isActing ||
        !_state.isRoundStarted ||
        !_state.isPlayerTurn ||
        _state.isRoundOver) {
      return;
    }

    _isActing = true;
    _standInternal();
    _isActing = false;
    notifyListeners();
  }

  void _standInternal() {
    _state = _state.copyWith(
      isPlayerTurn: false,
      isDealerTurn: true,
      isDealerCardHidden: false,
      resultMessage: 'Dealer is playing...',
    );
    dealerPlay(notify: false);
  }

  void dealerPlay({bool notify = true}) {
    if (!_state.isRoundStarted || _state.isRoundOver) return;

    var deck = List<PlayingCardModel>.of(_state.deck);
    final dealerHand = List<PlayingCardModel>.of(_state.dealerHand);
    while (BlackjackRules.shouldDealerHit(dealerHand)) {
      if (deck.isEmpty) {
        deck = _deckEngine.resetDeck();
      }
      dealerHand.add(_drawFrom(deck));
    }

    _state = _state.copyWith(
      deck: deck,
      dealerHand: dealerHand,
      dealerScore: BlackjackRules.calculateHandValue(dealerHand),
      isDealerCardHidden: false,
    );
    finishRound(
      BlackjackRules.compareHands(_state.playerHand, dealerHand),
      notify: false,
    );
    if (notify) notifyListeners();
  }

  void finishRound(BlackjackRoundResult result, {bool notify = true}) {
    if (_state.isRoundOver) return;

    final isWin =
        result == BlackjackRoundResult.playerWin ||
        result == BlackjackRoundResult.dealerBust ||
        result == BlackjackRoundResult.playerBlackjack;
    final isLoss =
        result == BlackjackRoundResult.dealerWin ||
        result == BlackjackRoundResult.playerBust ||
        result == BlackjackRoundResult.dealerBlackjack;
    final isPush = result == BlackjackRoundResult.push;

    var chips = _state.chips;
    if (result == BlackjackRoundResult.playerBlackjack) {
      chips += _state.currentBet * 2;
    } else if (isWin) {
      chips += _state.currentBet;
    } else if (isLoss) {
      chips -= _state.currentBet;
    }
    chips = chips.clamp(0, 1 << 31);

    final gameOver = chips <= 0;
    _state = _state.copyWith(
      playerScore: BlackjackRules.calculateHandValue(_state.playerHand),
      dealerScore: BlackjackRules.calculateHandValue(_state.dealerHand),
      chips: chips,
      currentBet: chips > 0
          ? _state.currentBet.clamp(1, chips)
          : _state.currentBet,
      wins: _state.wins + (isWin ? 1 : 0),
      losses: _state.losses + (isLoss ? 1 : 0),
      pushes: _state.pushes + (isPush ? 1 : 0),
      resultMessage: gameOver
          ? 'You are out of chips. Start a new game.'
          : _messageFor(result),
      isPlayerTurn: false,
      isDealerTurn: false,
      isRoundOver: true,
      isDealerCardHidden: false,
      isGameOver: gameOver,
      roundResult: result,
    );
    unawaited(_progressController?.saveBlackjackChips(chips));
    _recordRound(result);
    if (notify) notifyListeners();
  }

  void placeBet(int amount) {
    if (!_state.canChangeBet || _state.isGameOver || _state.chips <= 0) return;
    final maximum = _state.chips;
    final minimum = maximum < 10 ? maximum : 10;
    _state = _state.copyWith(currentBet: amount.clamp(minimum, maximum));
    notifyListeners();
  }

  void increaseBet() {
    final currentIndex = betOptions.indexWhere(
      (amount) => amount > _state.currentBet,
    );
    placeBet(currentIndex == -1 ? _state.chips : betOptions[currentIndex]);
  }

  void decreaseBet() {
    final lowerOptions = betOptions
        .where((amount) => amount < _state.currentBet)
        .toList();
    placeBet(lowerOptions.isEmpty ? 10 : lowerOptions.last);
  }

  void resetStats() {
    _state = _state.copyWith(wins: 0, losses: 0, pushes: 0);
    notifyListeners();
  }

  void ensureDeckHasCards({int minimumCards = 15, bool notify = true}) {
    if (_state.deck.length >= minimumCards) return;
    _state = _state.copyWith(deck: _deckEngine.resetDeck());
    if (notify) notifyListeners();
  }

  PlayingCardModel? drawCard() {
    if (_state.deck.isEmpty) ensureDeckHasCards(notify: false);
    if (_state.deck.isEmpty) return null;
    final deck = List<PlayingCardModel>.of(_state.deck);
    final card = _drawFrom(deck);
    _state = _state.copyWith(deck: deck);
    notifyListeners();
    return card;
  }

  void updateScores() {
    _state = _state.copyWith(
      playerScore: BlackjackRules.calculateHandValue(_state.playerHand),
      dealerScore: BlackjackRules.calculateHandValue(_state.dealerHand),
    );
    notifyListeners();
  }

  PlayingCardModel _drawFrom(List<PlayingCardModel> deck) {
    final card = _deckEngine.drawCard(deck);
    if (card == null) {
      throw StateError('Cannot draw from an empty Blackjack deck.');
    }
    return card;
  }

  String _messageFor(BlackjackRoundResult result) {
    return switch (result) {
      BlackjackRoundResult.playerWin => 'You win this round!',
      BlackjackRoundResult.dealerWin => 'Dealer wins this round.',
      BlackjackRoundResult.push => 'Push! It’s a draw.',
      BlackjackRoundResult.playerBust => 'You busted! Dealer wins.',
      BlackjackRoundResult.dealerBust => 'Dealer busted! You win.',
      BlackjackRoundResult.playerBlackjack => 'Blackjack! You win.',
      BlackjackRoundResult.dealerBlackjack => 'Dealer has Blackjack.',
    };
  }

  Future<void> _restorePersistentChips() async {
    final progress = _progressController;
    if (progress == null || _state.isRoundStarted) return;
    final chips = await progress.getBlackjackChips();
    if (chips == null || chips < 0 || _state.isRoundStarted) return;
    _state = _state.copyWith(
      chips: chips,
      currentBet: chips > 0 ? _state.currentBet.clamp(1, chips) : 50,
      isGameOver: chips == 0,
      resultMessage: chips == 0
          ? 'You are out of chips. Start a new game.'
          : _state.resultMessage,
    );
    notifyListeners();
  }

  void _recordRound(BlackjackRoundResult result) {
    if (_recordedRounds.contains(_state.roundNumber)) return;
    _recordedRounds.add(_state.roundNumber);
    final progress = _progressController;
    if (progress == null) return;
    final resultName = switch (result) {
      BlackjackRoundResult.playerWin ||
      BlackjackRoundResult.dealerBust ||
      BlackjackRoundResult.playerBlackjack => 'win',
      BlackjackRoundResult.push => 'push',
      _ => 'loss',
    };
    unawaited(
      progress.recordGameResult(
        recordId:
            'blackjack_${identityHashCode(this)}_${_gameSession}_${_state.roundNumber}',
        gameType: 'blackjack',
        gameName: 'Blackjack',
        result: resultName,
        opponent: 'Dealer',
        playerScore: _state.playerScore,
        opponentScore: _state.dealerScore,
        extraData: {
          'betAmount': _state.currentBet,
          'finalChips': _state.chips,
          'roundResult': result.name,
          'playerHandValue': _state.playerScore,
          'dealerHandValue': _state.dealerScore,
        },
      ),
    );
  }
}
