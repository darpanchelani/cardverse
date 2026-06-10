import 'package:cardverse/core/network/socket_connection_state.dart';
import 'package:cardverse/core/network/socket_service.dart';
import 'package:flutter/foundation.dart';

class SocketConnectionController extends ChangeNotifier {
  SocketConnectionController({
    required SocketService socketService,
    required this.userId,
    required this.username,
    this.avatar = 'default',
    this.level = 1,
  }) : _socketService = socketService {
    _socketService.addListener(_syncState);
    _syncState();
  }

  final SocketService _socketService;
  final String userId;
  final String username;
  final String avatar;
  final int level;

  bool isConnected = false;
  bool isConnecting = false;
  String? socketId;
  String? errorMessage;
  SocketConnectionState state = SocketConnectionState.disconnected;

  Future<void> connect() async {
    try {
      await _socketService.connect(
        userId: userId,
        username: username,
        avatar: avatar,
        level: level,
      );
    } catch (_) {
      _syncState();
    }
  }

  void disconnect() => _socketService.disconnect();

  Future<void> reconnect() async {
    disconnect();
    await connect();
  }

  void _syncState() {
    state = _socketService.connectionState;
    isConnected =
        _socketService.isConnected && state == SocketConnectionState.connected;
    isConnecting =
        state == SocketConnectionState.connecting ||
        state == SocketConnectionState.reconnecting;
    socketId = _socketService.socketId;
    errorMessage = _socketService.errorMessage;
    notifyListeners();
  }

  @override
  void dispose() {
    _socketService.removeListener(_syncState);
    super.dispose();
  }
}
