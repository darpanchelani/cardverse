import 'package:cardverse/core/network/socket_service.dart';
import 'package:cardverse/features/multiplayer/blackjack/models/blackjack_game_state_model.dart';
import 'package:cardverse/features/multiplayer/blackjack/models/blackjack_round_result_model.dart';

class SocketBlackjackService {
  SocketBlackjackService(this._socket);

  final SocketService _socket;

  bool get isConnected => _socket.isConnected;

  Future<BlackjackGameStateModel> initGame(String roomCode) =>
      _request(SocketEvents.blackjackInit, roomCode);

  Future<BlackjackGameStateModel> placeBet(String roomCode, int amount) =>
      _request(SocketEvents.blackjackPlaceBet, roomCode, {'amount': amount});

  Future<BlackjackGameStateModel> startRound(String roomCode) =>
      _request(SocketEvents.blackjackStartRound, roomCode);

  Future<BlackjackGameStateModel> hit(String roomCode) =>
      _request(SocketEvents.blackjackHit, roomCode);

  Future<BlackjackGameStateModel> stand(String roomCode) =>
      _request(SocketEvents.blackjackStand, roomCode);

  Future<BlackjackGameStateModel> nextRound(String roomCode) =>
      _request(SocketEvents.blackjackNextRound, roomCode);

  Future<BlackjackGameStateModel> requestRematch(String roomCode) =>
      _request(SocketEvents.blackjackRematchRequest, roomCode);

  Future<BlackjackGameStateModel> acceptRematch(String roomCode) =>
      _request(SocketEvents.blackjackRematchAccept, roomCode);

  Future<void> leaveGame(String roomCode) async {
    if (!isConnected) return;
    await _socket.request(SocketEvents.blackjackLeaveGame, {
      'roomCode': roomCode,
    });
  }

  void listenBlackjackEvents({
    required void Function(BlackjackGameStateModel state) onState,
    required void Function(BlackjackGameStateModel state) onRoundStarted,
    required void Function(Map<String, dynamic> action) onPlayerAction,
    required void Function(Map<String, dynamic> data) onDealerTurn,
    required void Function(BlackjackRoundResultModel result) onRoundResult,
    required void Function(BlackjackGameStateModel state) onMatchOver,
    required void Function(String message) onError,
    required void Function(String username, List<String> requests)
    onRematchRequested,
    required void Function(BlackjackGameStateModel state) onRematchStarted,
  }) {
    disposeListeners();
    _socket.on(SocketEvents.blackjackState, (data) {
      onState(BlackjackGameStateModel.fromJson(_map(data)));
    });
    _socket.on(SocketEvents.blackjackRoundStarted, (data) {
      onRoundStarted(BlackjackGameStateModel.fromJson(_map(data)));
    });
    _socket.on(
      SocketEvents.blackjackPlayerAction,
      (data) => onPlayerAction(_map(data)),
    );
    _socket.on(
      SocketEvents.blackjackDealerTurn,
      (data) => onDealerTurn(_map(data)),
    );
    _socket.on(SocketEvents.blackjackRoundResult, (data) {
      onRoundResult(BlackjackRoundResultModel.fromJson(_map(data)));
    });
    _socket.on(SocketEvents.blackjackMatchOver, (data) {
      onMatchOver(BlackjackGameStateModel.fromJson(_map(data)));
    });
    _socket.on(SocketEvents.blackjackError, (data) {
      onError(_map(data)['message'] as String? ?? 'Blackjack request failed.');
    });
    _socket.on(SocketEvents.blackjackRematchRequested, (data) {
      final value = _map(data);
      onRematchRequested(
        value['username'] as String? ?? 'A player',
        (value['rematchRequests'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .toList(),
      );
    });
    _socket.on(SocketEvents.blackjackRematchStarted, (data) {
      onRematchStarted(BlackjackGameStateModel.fromJson(_map(data)));
    });
  }

  void disposeListeners() {
    for (final event in [
      SocketEvents.blackjackState,
      SocketEvents.blackjackRoundStarted,
      SocketEvents.blackjackPlayerAction,
      SocketEvents.blackjackDealerTurn,
      SocketEvents.blackjackRoundResult,
      SocketEvents.blackjackMatchOver,
      SocketEvents.blackjackError,
      SocketEvents.blackjackRematchRequested,
      SocketEvents.blackjackRematchStarted,
    ]) {
      _socket.off(event);
    }
  }

  Future<BlackjackGameStateModel> _request(
    String event,
    String roomCode, [
    Map<String, dynamic> extra = const {},
  ]) async {
    final response = await _socket.request(event, {
      'roomCode': roomCode,
      ...extra,
    });
    return BlackjackGameStateModel.fromJson(
      Map<String, dynamic>.from(response['game'] as Map),
    );
  }

  Map<String, dynamic> _map(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
