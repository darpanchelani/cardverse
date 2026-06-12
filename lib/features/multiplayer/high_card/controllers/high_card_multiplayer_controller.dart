import 'dart:async';

import 'package:cardverse/features/multiplayer/high_card/models/high_card_game_state_model.dart';
import 'package:cardverse/features/multiplayer/high_card/models/high_card_round_result_model.dart';
import 'package:cardverse/features/multiplayer/high_card/services/socket_high_card_service.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:flutter/foundation.dart';

class HighCardMultiplayerController extends ChangeNotifier {
  HighCardMultiplayerController({
    required SocketHighCardService service,
    required this.currentUserId,
    this.progressController,
  }) : _service = service {
    _service.listenHighCardEvents(
      onState: handleGameState,
      onRoundResult: handleRoundResult,
      onMatchOver: handleMatchOver,
      onError: _handleError,
      onRematchRequested: _handleRematchRequested,
      onRematchStarted: _handleRematchStarted,
    );
  }

  final SocketHighCardService _service;
  final ProgressController? progressController;
  final String currentUserId;
  final Set<String> _recordedMatches = {};
  String? _roomCode;

  HighCardGameStateModel? gameState;
  HighCardRoundResultModel? latestRoundResult;
  bool isLoading = false;
  bool isDrawing = false;
  bool isAdvancing = false;
  bool isRequestingRematch = false;
  String? errorMessage;
  String? rematchNotice;

  bool get isConnected => _service.isConnected;
  bool get isRoundOver => gameState?.status == 'round_over';
  bool get isMatchOver => gameState?.status == 'match_over';
  bool get hasRequestedRematch =>
      gameState?.rematchRequests.contains(currentUserId) ?? false;

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

  Future<bool> drawCards() async {
    final roomCode = _roomCode;
    if (roomCode == null ||
        !isConnected ||
        gameState?.status != 'playing' ||
        isDrawing) {
      return false;
    }
    isDrawing = true;
    errorMessage = null;
    notifyListeners();
    try {
      handleGameState(await _service.drawCards(roomCode));
      return true;
    } catch (error) {
      _handleError(_message(error));
      return false;
    } finally {
      isDrawing = false;
      notifyListeners();
    }
  }

  Future<bool> nextRound() async {
    final roomCode = _roomCode;
    if (roomCode == null ||
        !isConnected ||
        gameState?.status != 'round_over' ||
        isAdvancing) {
      return false;
    }
    isAdvancing = true;
    errorMessage = null;
    notifyListeners();
    try {
      handleGameState(await _service.nextRound(roomCode));
      return true;
    } catch (error) {
      _handleError(_message(error));
      return false;
    } finally {
      isAdvancing = false;
      notifyListeners();
    }
  }

  Future<bool> requestRematch() async {
    final roomCode = _roomCode;
    if (roomCode == null ||
        !isConnected ||
        !isMatchOver ||
        isRequestingRematch) {
      return false;
    }
    isRequestingRematch = true;
    errorMessage = null;
    notifyListeners();
    try {
      handleGameState(await _service.requestRematch(roomCode));
      return true;
    } catch (error) {
      _handleError(_message(error));
      return false;
    } finally {
      isRequestingRematch = false;
      notifyListeners();
    }
  }

  Future<bool> acceptRematch() async {
    final roomCode = _roomCode;
    if (roomCode == null || !isConnected || !isMatchOver) return false;
    isRequestingRematch = true;
    notifyListeners();
    try {
      handleGameState(await _service.acceptRematch(roomCode));
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
        // Room leave still runs when the game-specific request cannot be sent.
      }
    }
    clear();
  }

  void handleGameState(HighCardGameStateModel state) {
    if (_roomCode != null && state.roomCode != _roomCode) return;
    _roomCode = state.roomCode;
    gameState = state;
    latestRoundResult = state.roundResult;
    errorMessage = null;
    if (state.status == 'match_over') unawaited(_recordMatch(state));
    notifyListeners();
  }

  void handleRoundResult(HighCardRoundResultModel result) {
    latestRoundResult = result;
    notifyListeners();
  }

  void handleMatchOver(HighCardGameStateModel state) {
    handleGameState(state);
  }

  void clear() {
    _roomCode = null;
    gameState = null;
    latestRoundResult = null;
    errorMessage = null;
    rematchNotice = null;
    isLoading = false;
    isDrawing = false;
    isAdvancing = false;
    isRequestingRematch = false;
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

  void _handleRematchStarted(HighCardGameStateModel state) {
    rematchNotice = 'Rematch started.';
    handleGameState(state);
  }

  Future<void> _recordMatch(HighCardGameStateModel state) async {
    final progress = progressController;
    if (progress == null ||
        !state.players.any((player) => player.id == currentUserId)) {
      return;
    }
    final recordId =
        'high_card_online_${state.roomCode}_${state.createdAt.microsecondsSinceEpoch}';
    if (!_recordedMatches.add(recordId)) return;

    final playerScore = state.scores[currentUserId] ?? 0;
    final opponentScores = state.scores.entries
        .where((entry) => entry.key != currentUserId)
        .map((entry) => entry.value);
    final opponentScore = opponentScores.isEmpty
        ? 0
        : opponentScores.reduce((a, b) => a > b ? a : b);
    final result = state.matchWinnerId == null
        ? 'draw'
        : state.matchWinnerId == currentUserId
        ? 'win'
        : 'loss';
    final reward = switch (result) {
      'win' => (100, 50),
      'loss' => (25, 20),
      _ => (40, 30),
    };
    await progress.recordGameResult(
      recordId: recordId,
      gameType: 'high_card_online',
      gameName: 'Online High Card',
      result: result,
      opponent: 'Multiplayer',
      playerScore: playerScore,
      opponentScore: opponentScore,
      rewardCoins: reward.$1,
      rewardXp: reward.$2,
      extraData: {
        'roomCode': state.roomCode,
        'maxRounds': state.maxRounds,
        'totalPlayers': state.players.length,
        'winnerName': state.matchWinnerName,
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
