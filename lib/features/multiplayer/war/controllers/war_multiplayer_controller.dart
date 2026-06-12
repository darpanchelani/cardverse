import 'dart:async';

import 'package:cardverse/features/multiplayer/war/models/war_battle_result_model.dart';
import 'package:cardverse/features/multiplayer/war/models/war_game_state_model.dart';
import 'package:cardverse/features/multiplayer/war/services/socket_war_service.dart';
import 'package:cardverse/features/progress/controllers/progress_controller.dart';
import 'package:flutter/foundation.dart';

class WarMultiplayerController extends ChangeNotifier {
  WarMultiplayerController({
    required SocketWarService service,
    required this.currentUserId,
    this.progressController,
  }) : _service = service {
    _service.listenWarEvents(
      onState: handleGameState,
      onBattleResult: handleBattleResult,
      onWarStarted: handleWarStarted,
      onMatchOver: handleMatchOver,
      onError: _handleError,
      onRematchRequested: _handleRematchRequested,
      onRematchStarted: _handleRematchStarted,
    );
  }

  final SocketWarService _service;
  final ProgressController? progressController;
  final String currentUserId;
  final Set<String> _recordedMatches = {};
  String? _roomCode;

  WarGameStateModel? gameState;
  WarBattleResultModel? latestBattleResult;
  bool isLoading = false;
  bool isBattling = false;
  bool isAdvancing = false;
  bool isRequestingRematch = false;
  bool warEventActive = false;
  String? errorMessage;
  String? rematchNotice;

  bool get isConnected => _service.isConnected;
  bool get isBattleOver => gameState?.status == 'battle_over';
  bool get isWarActive => gameState?.status == 'war_active' || warEventActive;
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

  Future<bool> playBattle() async {
    final roomCode = _roomCode;
    if (roomCode == null ||
        !isConnected ||
        gameState?.status != 'playing' ||
        isBattling) {
      return false;
    }
    isBattling = true;
    warEventActive = false;
    errorMessage = null;
    notifyListeners();
    try {
      handleGameState(await _service.playBattle(roomCode));
      return true;
    } catch (error) {
      _handleError(_message(error));
      return false;
    } finally {
      isBattling = false;
      notifyListeners();
    }
  }

  Future<bool> nextBattle() async {
    final roomCode = _roomCode;
    if (roomCode == null ||
        !isConnected ||
        gameState?.status != 'battle_over' ||
        isAdvancing) {
      return false;
    }
    isAdvancing = true;
    errorMessage = null;
    notifyListeners();
    try {
      handleGameState(await _service.nextBattle(roomCode));
      return true;
    } catch (error) {
      _handleError(_message(error));
      return false;
    } finally {
      isAdvancing = false;
      notifyListeners();
    }
  }

  Future<bool> requestRematch() => _rematch(_service.requestRematch);

  Future<bool> acceptRematch() => _rematch(_service.acceptRematch);

  Future<bool> _rematch(
    Future<WarGameStateModel> Function(String roomCode) action,
  ) async {
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
        // The room leave request still runs if the game event cannot be sent.
      }
    }
    clear();
  }

  void handleGameState(WarGameStateModel state) {
    if (_roomCode != null && state.roomCode != _roomCode) return;
    _roomCode = state.roomCode;
    gameState = state;
    latestBattleResult = state.battleResult;
    warEventActive = state.warCards.isNotEmpty && state.battleResult != null;
    errorMessage = null;
    if (state.status == 'match_over') unawaited(_recordMatch(state));
    notifyListeners();
  }

  void handleBattleResult(WarBattleResultModel result) {
    latestBattleResult = result;
    warEventActive = result.warCards.isNotEmpty;
    notifyListeners();
  }

  void handleWarStarted(Map<String, dynamic> _) {
    warEventActive = true;
    notifyListeners();
  }

  void handleMatchOver(WarGameStateModel state) => handleGameState(state);

  void clear() {
    _roomCode = null;
    gameState = null;
    latestBattleResult = null;
    errorMessage = null;
    rematchNotice = null;
    isLoading = false;
    isBattling = false;
    isAdvancing = false;
    isRequestingRematch = false;
    warEventActive = false;
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

  void _handleRematchStarted(WarGameStateModel state) {
    rematchNotice = 'Rematch started.';
    warEventActive = false;
    handleGameState(state);
  }

  Future<void> _recordMatch(WarGameStateModel state) async {
    final progress = progressController;
    if (progress == null ||
        !state.players.any((player) => player.id == currentUserId)) {
      return;
    }
    final recordId =
        'war_online_${state.roomCode}_${state.createdAt.microsecondsSinceEpoch}';
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
      'win' => (150, 75),
      'loss' => (35, 25),
      _ => (60, 40),
    };
    await progress.recordGameResult(
      recordId: recordId,
      gameType: 'war_online',
      gameName: 'Online War',
      result: result,
      opponent: 'Multiplayer',
      playerScore: playerScore,
      opponentScore: opponentScore,
      rewardCoins: reward.$1,
      rewardXp: reward.$2,
      extraData: {
        'roomCode': state.roomCode,
        'maxBattles': state.maxBattles,
        'totalPlayers': state.players.length,
        'winnerName': state.matchWinnerName,
        'warCount': state.warCount,
        'finalCardCounts': state.cardCounts,
        'battleHistory': state.battleHistory
            .map((battle) => battle.toJson())
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
