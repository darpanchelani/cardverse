import 'package:cardverse/core/network/socket_service.dart';
import 'package:cardverse/features/multiplayer/high_card/models/high_card_game_state_model.dart';
import 'package:cardverse/features/multiplayer/high_card/models/high_card_round_result_model.dart';

class SocketHighCardService {
  SocketHighCardService(this._socket);

  final SocketService _socket;

  bool get isConnected => _socket.isConnected;

  Future<HighCardGameStateModel> initGame(String roomCode) =>
      _request(SocketEvents.highCardInit, roomCode);

  Future<HighCardGameStateModel> drawCards(String roomCode) =>
      _request(SocketEvents.highCardDraw, roomCode);

  Future<HighCardGameStateModel> nextRound(String roomCode) =>
      _request(SocketEvents.highCardNextRound, roomCode);

  Future<HighCardGameStateModel> requestRematch(String roomCode) =>
      _request(SocketEvents.highCardRematchRequest, roomCode);

  Future<HighCardGameStateModel> acceptRematch(String roomCode) =>
      _request(SocketEvents.highCardRematchAccept, roomCode);

  Future<void> leaveGame(String roomCode) async {
    if (!isConnected) return;
    await _socket.request(SocketEvents.highCardLeaveGame, {
      'roomCode': roomCode,
    });
  }

  void listenHighCardEvents({
    required void Function(HighCardGameStateModel state) onState,
    required void Function(HighCardRoundResultModel result) onRoundResult,
    required void Function(HighCardGameStateModel state) onMatchOver,
    required void Function(String message) onError,
    required void Function(String username, List<String> requests)
    onRematchRequested,
    required void Function(HighCardGameStateModel state) onRematchStarted,
  }) {
    disposeListeners();
    _socket.on(SocketEvents.highCardState, (data) {
      onState(HighCardGameStateModel.fromJson(_map(data)));
    });
    _socket.on(SocketEvents.highCardRoundResult, (data) {
      onRoundResult(HighCardRoundResultModel.fromJson(_map(data)));
    });
    _socket.on(SocketEvents.highCardMatchOver, (data) {
      onMatchOver(HighCardGameStateModel.fromJson(_map(data)));
    });
    _socket.on(SocketEvents.highCardError, (data) {
      onError(_map(data)['message'] as String? ?? 'High Card request failed.');
    });
    _socket.on(SocketEvents.highCardRematchRequested, (data) {
      final value = _map(data);
      onRematchRequested(
        value['username'] as String? ?? 'A player',
        (value['rematchRequests'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .toList(),
      );
    });
    _socket.on(SocketEvents.highCardRematchStarted, (data) {
      onRematchStarted(HighCardGameStateModel.fromJson(_map(data)));
    });
  }

  void disposeListeners() {
    _socket.off(SocketEvents.highCardState);
    _socket.off(SocketEvents.highCardRoundResult);
    _socket.off(SocketEvents.highCardMatchOver);
    _socket.off(SocketEvents.highCardError);
    _socket.off(SocketEvents.highCardRematchRequested);
    _socket.off(SocketEvents.highCardRematchStarted);
  }

  Future<HighCardGameStateModel> _request(String event, String roomCode) async {
    final response = await _socket.request(event, {'roomCode': roomCode});
    return HighCardGameStateModel.fromJson(
      Map<String, dynamic>.from(response['game'] as Map),
    );
  }

  Map<String, dynamic> _map(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
