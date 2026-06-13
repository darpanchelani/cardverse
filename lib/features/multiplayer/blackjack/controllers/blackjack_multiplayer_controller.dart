import 'dart:async';

import 'package:cardverse/features/multiplayer/blackjack/models/blackjack_game_state_model.dart';
import 'package:cardverse/features/multiplayer/blackjack/models/blackjack_round_result_model.dart';
import 'package:cardverse/features/multiplayer/blackjack/services/socket_blackjack_service.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:cardverse/features/history/services/match_history_api_service.dart';
import 'package:flutter/foundation.dart';

class BlackjackMultiplayerController extends ChangeNotifier {
  BlackjackMultiplayerController({
    required SocketBlackjackService service,
    required this.currentUserId,
    this.progressController,
    this.cloudMatchService,
  }) : _service = service {
    _service.listenBlackjackEvents(
      onState: handleGameState,
      onRoundStarted: handleRoundStarted,
      onPlayerAction: handlePlayerAction,
      onDealerTurn: handleDealerTurn,
      onRoundResult: handleRoundResult,
      onMatchOver: handleMatchOver,
      onError: _handleError,
      onRematchRequested: _handleRematchRequested,
      onRematchStarted: _handleRematchStarted,
    );
  }

  final SocketBlackjackService _service;
  final ProgressController? progressController;
  final MatchHistoryApiService? cloudMatchService;
  String currentUserId;
  final Set<String> _recordedMatches = {};
  String? _roomCode;

  BlackjackGameStateModel? gameState;
  BlackjackRoundResultModel? latestRoundResult;
  bool isLoading = false;
  bool isPlacingBet = false;
  bool isStartingRound = false;
  bool isActing = false;
  bool isAdvancing = false;
  bool isRequestingRematch = false;
  String? errorMessage;
  String? actionNotice;
  String? rematchNotice;

  bool get isConnected => _service.isConnected;
  bool get isRoundOver => gameState?.status == 'round_over';
  bool get isMatchOver => gameState?.status == 'match_over';
  bool get hasRequestedRematch =>
      gameState?.rematchRequests.contains(currentUserId) ?? false;
  bool get canAct =>
      gameState?.status == 'playing' &&
      gameState?.playerStatuses[currentUserId] == 'playing';

  void updateIdentity(String userId) {
    currentUserId = userId;
    clear();
  }

  Future<bool> connectAndLoadGame(String roomCode) async {
    if (!isConnected) {
      errorMessage = 'Disconnected from server. Trying to reconnect...';
      notifyListeners();
      return false;
    }
    _roomCode = roomCode;
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      handleGameState(await _service.initGame(roomCode));
      return true;
    } catch (error) {
      _handleError(_message(error));
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> placeBet(int amount) async {
    final roomCode = _roomCode;
    if (roomCode == null ||
        !isConnected ||
        gameState?.status != 'betting' ||
        isPlacingBet) {
      return false;
    }
    isPlacingBet = true;
    errorMessage = null;
    notifyListeners();
    try {
      handleGameState(await _service.placeBet(roomCode, amount));
      return true;
    } catch (error) {
      _handleError(_message(error));
      return false;
    } finally {
      isPlacingBet = false;
      notifyListeners();
    }
  }

  Future<bool> startRound() => _runStateAction(
    allowed: gameState?.status == 'betting',
    busy: isStartingRound,
    setBusy: (value) => isStartingRound = value,
    action: _service.startRound,
  );

  Future<bool> hit() => _runStateAction(
    allowed: canAct,
    busy: isActing,
    setBusy: (value) => isActing = value,
    action: _service.hit,
  );

  Future<bool> stand() => _runStateAction(
    allowed: canAct,
    busy: isActing,
    setBusy: (value) => isActing = value,
    action: _service.stand,
  );

  Future<bool> nextRound() => _runStateAction(
    allowed: isRoundOver,
    busy: isAdvancing,
    setBusy: (value) => isAdvancing = value,
    action: _service.nextRound,
  );

  Future<bool> requestRematch() => _rematch(_service.requestRematch);

  Future<bool> acceptRematch() => _rematch(_service.acceptRematch);

  Future<bool> _runStateAction({
    required bool allowed,
    required bool busy,
    required ValueChanged<bool> setBusy,
    required Future<BlackjackGameStateModel> Function(String) action,
  }) async {
    final roomCode = _roomCode;
    if (roomCode == null || !isConnected || !allowed || busy) return false;
    setBusy(true);
    errorMessage = null;
    notifyListeners();
    try {
      handleGameState(await action(roomCode));
      return true;
    } catch (error) {
      _handleError(_message(error));
      return false;
    } finally {
      setBusy(false);
      notifyListeners();
    }
  }

  Future<bool> _rematch(
    Future<BlackjackGameStateModel> Function(String) action,
  ) async {
    final roomCode = _roomCode;
    if (roomCode == null ||
        !isConnected ||
        !isMatchOver ||
        isRequestingRematch) {
      return false;
    }
    isRequestingRematch = true;
    notifyListeners();
    try {
      handleGameState(await action(roomCode));
      return true;
    } catch (error) {
      _handleError(_message(error));
      return false;
    } finally {
      isRequestingRematch = false;
      notifyListeners();
    }
  }

  Future<void> leaveGame() async {
    final roomCode = _roomCode;
    if (roomCode != null) {
      try {
        await _service.leaveGame(roomCode);
      } catch (_) {
        // Room leave remains the fallback if the game request cannot be sent.
      }
    }
    clear();
  }

  void handleGameState(BlackjackGameStateModel state) {
    if (_roomCode != null && state.roomCode != _roomCode) return;
    _roomCode = state.roomCode;
    gameState = state;
    errorMessage = null;
    if (state.status == 'match_over') unawaited(_recordMatch(state));
    notifyListeners();
  }

  void handleRoundStarted(BlackjackGameStateModel state) {
    actionNotice = 'Cards dealt. Hit or stand.';
    handleGameState(state);
  }

  void handlePlayerAction(Map<String, dynamic> action) {
    final username = action['username'] as String? ?? 'Player';
    actionNotice = '$username chose ${action['action'] ?? 'an action'}.';
    notifyListeners();
  }

  void handleDealerTurn(Map<String, dynamic> _) {
    actionNotice = 'Dealer is playing...';
    notifyListeners();
  }

  void handleRoundResult(BlackjackRoundResultModel result) {
    latestRoundResult = result;
    actionNotice = null;
    notifyListeners();
  }

  void handleMatchOver(BlackjackGameStateModel state) => handleGameState(state);

  void clear() {
    _roomCode = null;
    gameState = null;
    latestRoundResult = null;
    isLoading = false;
    isPlacingBet = false;
    isStartingRound = false;
    isActing = false;
    isAdvancing = false;
    isRequestingRematch = false;
    errorMessage = null;
    actionNotice = null;
    rematchNotice = null;
    notifyListeners();
  }

  void _handleError(String message) {
    errorMessage = message;
    notifyListeners();
  }

  void _handleRematchRequested(String username, List<String> requests) {
    rematchNotice = '$username requested a rematch.';
    final state = gameState;
    if (state != null) {
      gameState = state.copyWith(rematchRequests: requests);
    }
    notifyListeners();
  }

  void _handleRematchStarted(BlackjackGameStateModel state) {
    rematchNotice = 'New Blackjack table started.';
    handleGameState(state);
  }

  Future<void> _recordMatch(BlackjackGameStateModel state) async {
    final progress = progressController;
    if (progress == null ||
        !state.players.any((player) => player.id == currentUserId)) {
      return;
    }
    final recordId =
        'blackjack_online_${state.roomCode}_${state.createdAt.microsecondsSinceEpoch}';
    if (!_recordedMatches.add(recordId)) return;
    final chips = state.playerChips[currentUserId] ?? 0;
    final opponentChips = state.playerChips.entries
        .where((entry) => entry.key != currentUserId)
        .map((entry) => entry.value);
    final opponentScore = opponentChips.isEmpty
        ? state.roundHistory.isEmpty
              ? 0
              : state.roundHistory.last.dealerScore
        : opponentChips.reduce((a, b) => a > b ? a : b);
    final winnerId = state.matchResults?.winnerId;
    final result = winnerId == null
        ? 'draw'
        : winnerId == currentUserId
        ? 'win'
        : 'loss';
    final reward = switch (result) {
      'win' => (200, 100),
      'loss' => (50, 35),
      _ => (80, 50),
    };
    try {
      await cloudMatchService?.saveOnlineMatch({
        'matchKey': recordId,
        'gameType': 'blackjack_online',
        'gameName': 'Online Blackjack',
        'mode': 'online',
        'roomCode': state.roomCode,
        'winnerId': state.matchResults?.winnerId,
        'players': state.players
            .map(
              (player) => {
                if (!player.isBot) 'userId': player.id,
                'username': player.username,
                'score': state.playerChips[player.id] ?? 0,
                'result': state.matchResults?.winnerId == null
                    ? 'draw'
                    : state.matchResults?.winnerId == player.id
                    ? 'win'
                    : 'loss',
              },
            )
            .toList(),
        'roundHistory': state.roundHistory
            .map((round) => round.toJson())
            .toList(),
      });
    } catch (_) {
      // Local progress remains the offline fallback when cloud sync fails.
    }
    await progress.recordGameResult(
      recordId: recordId,
      gameType: 'blackjack_online',
      gameName: 'Online Blackjack',
      result: result,
      opponent: 'Multiplayer Dealer',
      playerScore: chips,
      opponentScore: opponentScore,
      rewardCoins: reward.$1,
      rewardXp: reward.$2,
      extraData: {
        'roomCode': state.roomCode,
        'maxRounds': state.maxRounds,
        'totalPlayers': state.players.length,
        'winnerName': state.matchResults?.winnerName,
        'finalChips': chips,
        'roundsPlayed': state.roundHistory.length,
        'roundHistory': state.roundHistory
            .map((round) => round.toJson())
            .toList(),
      },
    );
  }

  String _message(Object error) {
    if (error is StateError) return error.message;
    return error.toString().replaceFirst('Exception: ', '');
  }

  @override
  void dispose() {
    _service.disposeListeners();
    super.dispose();
  }
}
