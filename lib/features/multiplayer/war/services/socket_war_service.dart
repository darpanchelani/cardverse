import 'package:cardverse/core/network/socket_service.dart';
import 'package:cardverse/features/multiplayer/war/models/war_battle_result_model.dart';
import 'package:cardverse/features/multiplayer/war/models/war_game_state_model.dart';

class SocketWarService {
  SocketWarService(this._socket);

  final SocketService _socket;

  bool get isConnected => _socket.isConnected;

  Future<WarGameStateModel> initGame(String roomCode) =>
      _request(SocketEvents.warInit, roomCode);

  Future<WarGameStateModel> playBattle(String roomCode) =>
      _request(SocketEvents.warBattle, roomCode);

  Future<WarGameStateModel> nextBattle(String roomCode) =>
      _request(SocketEvents.warNextBattle, roomCode);

  Future<WarGameStateModel> requestRematch(String roomCode) =>
      _request(SocketEvents.warRematchRequest, roomCode);

  Future<WarGameStateModel> acceptRematch(String roomCode) =>
      _request(SocketEvents.warRematchAccept, roomCode);

  Future<void> leaveGame(String roomCode) async {
    if (!isConnected) return;
    await _socket.request(SocketEvents.warLeaveGame, {'roomCode': roomCode});
  }

  void listenWarEvents({
    required void Function(WarGameStateModel state) onState,
    required void Function(WarBattleResultModel result) onBattleResult,
    required void Function(Map<String, dynamic> data) onWarStarted,
    required void Function(WarGameStateModel state) onMatchOver,
    required void Function(String message) onError,
    required void Function(String username, List<String> requests)
    onRematchRequested,
    required void Function(WarGameStateModel state) onRematchStarted,
  }) {
    disposeListeners();
    _socket.on(SocketEvents.warState, (data) {
      onState(WarGameStateModel.fromJson(_map(data)));
    });
    _socket.on(SocketEvents.warBattleResult, (data) {
      onBattleResult(WarBattleResultModel.fromJson(_map(data)));
    });
    _socket.on(SocketEvents.warStarted, (data) => onWarStarted(_map(data)));
    _socket.on(SocketEvents.warMatchOver, (data) {
      onMatchOver(WarGameStateModel.fromJson(_map(data)));
    });
    _socket.on(SocketEvents.warError, (data) {
      onError(_map(data)['message'] as String? ?? 'War request failed.');
    });
    _socket.on(SocketEvents.warRematchRequested, (data) {
      final value = _map(data);
      onRematchRequested(
        value['username'] as String? ?? 'A player',
        (value['rematchRequests'] as List<dynamic>? ?? const [])
            .map((item) => item.toString())
            .toList(),
      );
    });
    _socket.on(SocketEvents.warRematchStarted, (data) {
      onRematchStarted(WarGameStateModel.fromJson(_map(data)));
    });
  }

  void disposeListeners() {
    for (final event in [
      SocketEvents.warState,
      SocketEvents.warBattleResult,
      SocketEvents.warStarted,
      SocketEvents.warMatchOver,
      SocketEvents.warError,
      SocketEvents.warRematchRequested,
      SocketEvents.warRematchStarted,
    ]) {
      _socket.off(event);
    }
  }

  Future<WarGameStateModel> _request(String event, String roomCode) async {
    final response = await _socket.request(event, {'roomCode': roomCode});
    return WarGameStateModel.fromJson(
      Map<String, dynamic>.from(response['game'] as Map),
    );
  }

  Map<String, dynamic> _map(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
