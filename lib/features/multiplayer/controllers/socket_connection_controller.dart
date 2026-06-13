import 'package:cardverse/core/network/socket_connection_state.dart';
import 'package:cardverse/core/network/socket_service.dart';
import 'package:flutter/foundation.dart';

class SocketConnectionController extends ChangeNotifier {
  SocketConnectionController({
    required SocketService socketService,
    required String userId,
    required String username,
    String avatar = 'default',
    int level = 1,
    String? token,
  }) : _socketService = socketService,
       _userId = userId,
       _username = username,
       _avatar = avatar,
       _token = token,
       _level = level {
    _socketService.addListener(_syncState);
    _syncState();
  }

  final SocketService _socketService;
  String _userId;
  String _avatar;
  String? _token;
  String _username;
  int _level;

  String get userId => _userId;
  String get avatar => _avatar;
  String? get token => _token;
  String get username => _username;
  int get level => _level;

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
        token: token,
      );
    } catch (_) {
      _syncState();
    }
  }

  void disconnect() => _socketService.disconnect();

  void updateIdentity({
    required String userId,
    required String username,
    required int level,
    String avatar = 'default',
    String? token,
  }) {
    final changed =
        _userId != userId ||
        _username != username ||
        _level != level ||
        _avatar != avatar ||
        _token != token;
    _userId = userId;
    _username = username;
    _level = level;
    _avatar = avatar;
    _token = token;
    if (changed) _socketService.resetConnection();
    notifyListeners();
  }

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
