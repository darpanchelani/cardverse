import 'dart:async';

import 'package:cardverse/core/config/app_config.dart';
import 'package:cardverse/core/network/socket_connection_state.dart';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

abstract final class SocketEvents {
  static const userConnect = 'user:connect';
  static const roomCreate = 'room:create';
  static const roomJoin = 'room:join';
  static const roomLeave = 'room:leave';
  static const roomGetPublic = 'room:get_public';
  static const roomToggleReady = 'room:toggle_ready';
  static const roomAddBot = 'room:add_bot';
  static const roomRemoveBot = 'room:remove_bot';
  static const roomStartGame = 'room:start_game';
  static const chatSend = 'chat:send';
  static const typingStart = 'typing:start';
  static const typingStop = 'typing:stop';
  static const highCardInit = 'high_card:init';
  static const highCardDraw = 'high_card:draw';
  static const highCardNextRound = 'high_card:next_round';
  static const highCardRematchRequest = 'high_card:rematch_request';
  static const highCardRematchAccept = 'high_card:rematch_accept';
  static const highCardLeaveGame = 'high_card:leave_game';
  static const warInit = 'war:init';
  static const warBattle = 'war:battle';
  static const warNextBattle = 'war:next_battle';
  static const warRematchRequest = 'war:rematch_request';
  static const warRematchAccept = 'war:rematch_accept';
  static const warLeaveGame = 'war:leave_game';
  static const blackjackInit = 'blackjack:init';
  static const blackjackPlaceBet = 'blackjack:place_bet';
  static const blackjackStartRound = 'blackjack:start_round';
  static const blackjackHit = 'blackjack:hit';
  static const blackjackStand = 'blackjack:stand';
  static const blackjackNextRound = 'blackjack:next_round';
  static const blackjackRematchRequest = 'blackjack:rematch_request';
  static const blackjackRematchAccept = 'blackjack:rematch_accept';
  static const blackjackLeaveGame = 'blackjack:leave_game';
  static const inviteSend = 'invite:send';
  static const inviteAccept = 'invite:accept';
  static const inviteDecline = 'invite:decline';
  static const inviteCancel = 'invite:cancel';

  static const connectionSuccess = 'connection:success';
  static const roomCreated = 'room:created';
  static const roomJoined = 'room:joined';
  static const roomLeft = 'room:left';
  static const roomUpdated = 'room:updated';
  static const roomPublicList = 'room:public_list';
  static const roomError = 'room:error';
  static const roomGameStarting = 'room:game_starting';
  static const chatMessage = 'chat:message';
  static const chatHistory = 'chat:history';
  static const typingUpdate = 'typing:update';
  static const errorMessage = 'error:message';
  static const highCardState = 'high_card:state';
  static const highCardRoundResult = 'high_card:round_result';
  static const highCardMatchOver = 'high_card:match_over';
  static const highCardError = 'high_card:error';
  static const highCardRematchRequested = 'high_card:rematch_requested';
  static const highCardRematchStarted = 'high_card:rematch_started';
  static const warState = 'war:state';
  static const warBattleResult = 'war:battle_result';
  static const warStarted = 'war:war_started';
  static const warMatchOver = 'war:match_over';
  static const warError = 'war:error';
  static const warRematchRequested = 'war:rematch_requested';
  static const warRematchStarted = 'war:rematch_started';
  static const blackjackState = 'blackjack:state';
  static const blackjackRoundStarted = 'blackjack:round_started';
  static const blackjackPlayerAction = 'blackjack:player_action';
  static const blackjackDealerTurn = 'blackjack:dealer_turn';
  static const blackjackRoundResult = 'blackjack:round_result';
  static const blackjackMatchOver = 'blackjack:match_over';
  static const blackjackError = 'blackjack:error';
  static const blackjackRematchRequested = 'blackjack:rematch_requested';
  static const blackjackRematchStarted = 'blackjack:rematch_started';
  static const inviteReceived = 'invite:received';
  static const inviteAccepted = 'invite:accepted';
  static const inviteDeclined = 'invite:declined';
  static const inviteCancelled = 'invite:cancelled';
  static const inviteError = 'invite:error';
  static const notificationNew = 'notification:new';
  static const notificationUnreadCount = 'notification:unread_count';
  static const userStatsUpdated = 'user:stats_updated';
}

class SocketService extends ChangeNotifier {
  SocketService({this.baseUrl = AppConfig.socketBaseUrl});

  final String baseUrl;
  io.Socket? _socket;
  Map<String, dynamic>? _userPayload;
  Completer<void>? _connectionCompleter;

  SocketConnectionState connectionState = SocketConnectionState.disconnected;
  String? socketId;
  String? errorMessage;

  bool get isConnected => _socket?.connected == true;

  Future<void> connect({
    required String userId,
    required String username,
    String avatar = 'default',
    int level = 1,
    String? token,
  }) async {
    _userPayload = {
      'userId': userId,
      'username': username,
      'avatar': avatar,
      'level': level,
      'isGuest': token == null,
      'token': ?token,
    };
    if (isConnected && connectionState == SocketConnectionState.connected) {
      return;
    }
    if (_connectionCompleter != null && !_connectionCompleter!.isCompleted) {
      return _connectionCompleter!.future;
    }

    _connectionCompleter = Completer<void>();
    _setState(SocketConnectionState.connecting);
    _socket ??= _createSocket();
    _socket!.connect();
    return _connectionCompleter!.future.timeout(
      const Duration(seconds: 8),
      onTimeout: () {
        _setState(
          SocketConnectionState.failed,
          'Could not connect to the CardVerse server at $baseUrl.',
        );
        throw TimeoutException('Socket connection timed out');
      },
    );
  }

  io.Socket _createSocket() {
    var options = io.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .enableReconnection()
        .setReconnectionAttempts(5)
        .setReconnectionDelay(1000)
        .setTimeout(5000);
    final token = _userPayload?['token'] as String?;
    if (token != null) options = options.setAuth({'token': token});
    final socket = io.io(baseUrl, options.build());
    socket.on('connect', (_) {
      socketId = socket.id;
      final payload = _userPayload;
      if (payload != null) socket.emit(SocketEvents.userConnect, payload);
    });
    socket.on(SocketEvents.connectionSuccess, (data) {
      final map = _map(data);
      socketId = map['socketId'] as String? ?? socket.id;
      _setState(SocketConnectionState.connected);
      if (_connectionCompleter?.isCompleted == false) {
        _connectionCompleter!.complete();
      }
    });
    socket.on('reconnect_attempt', (_) {
      _setState(SocketConnectionState.reconnecting);
    });
    socket.on('reconnect', (_) {
      _setState(SocketConnectionState.connecting);
    });
    socket.on('connect_error', (error) {
      _setState(
        SocketConnectionState.failed,
        'Could not connect to the CardVerse server at $baseUrl.',
      );
      if (_connectionCompleter?.isCompleted == false) {
        _connectionCompleter!.completeError(error);
      }
    });
    socket.on('disconnect', (_) {
      _setState(SocketConnectionState.disconnected);
    });
    return socket;
  }

  void disconnect() {
    _socket?.disconnect();
    _setState(SocketConnectionState.disconnected);
  }

  void resetConnection() {
    _socket?.dispose();
    _socket = null;
    _connectionCompleter = null;
    socketId = null;
    _setState(SocketConnectionState.disconnected);
  }

  void emit(String event, dynamic data) => _socket?.emit(event, data);

  Future<Map<String, dynamic>> request(
    String event,
    Map<String, dynamic> data,
  ) async {
    if (!isConnected) throw StateError('Backend is not connected.');
    final response = await _socket!
        .emitWithAckAsync(event, data)
        .timeout(const Duration(seconds: 6));
    final map = _map(response);
    if (map['success'] != true) {
      throw StateError(map['message'] as String? ?? 'Socket request failed.');
    }
    return map;
  }

  void on(String event, Function(dynamic) callback) {
    (_socket ??= _createSocket()).on(event, callback);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void _setState(SocketConnectionState state, [String? error]) {
    connectionState = state;
    errorMessage = error;
    notifyListeners();
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return {};
  }

  @override
  void dispose() {
    _socket?.dispose();
    super.dispose();
  }
}
