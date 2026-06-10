import 'package:cardverse/core/network/socket_service.dart';
import 'package:cardverse/features/multiplayer/models/chat_message_model.dart';
import 'package:cardverse/features/multiplayer/services/multiplayer_chat_service.dart';

class SocketChatService implements MultiplayerChatService {
  SocketChatService(this._socket);

  final SocketService _socket;

  @override
  bool get isConnected => _socket.isConnected;

  @override
  Future<List<ChatMessageModel>?> loadHistory(String roomCode) async {
    // The server sends chat:history automatically after room:create/room:join.
    return null;
  }

  @override
  Future<ChatMessageModel?> sendMessage(String roomCode, String message) async {
    await _socket.request(SocketEvents.chatSend, {
      'roomCode': roomCode,
      'message': message,
    });
    return null;
  }

  @override
  void sendTypingStart(String roomCode) {
    _socket.emit(SocketEvents.typingStart, {'roomCode': roomCode});
  }

  @override
  void sendTypingStop(String roomCode) {
    _socket.emit(SocketEvents.typingStop, {'roomCode': roomCode});
  }

  @override
  void listenChatEvents({
    required void Function(ChatMessageModel message) onMessage,
    required void Function(List<ChatMessageModel> messages) onHistory,
    required void Function(String? username, bool isTyping) onTyping,
    required void Function(String message) onError,
  }) {
    disposeListeners();
    _socket.on(SocketEvents.chatMessage, (data) {
      onMessage(ChatMessageModel.fromJson(_map(data)));
    });
    _socket.on(SocketEvents.chatHistory, (data) {
      if (data is! List) return;
      onHistory(
        data.map((item) => ChatMessageModel.fromJson(_map(item))).toList(),
      );
    });
    _socket.on(SocketEvents.typingUpdate, (data) {
      final value = _map(data);
      onTyping(
        value['username'] as String?,
        value['isTyping'] as bool? ?? false,
      );
    });
    _socket.on(SocketEvents.errorMessage, (data) {
      onError(_map(data)['message'] as String? ?? 'Chat request failed.');
    });
  }

  @override
  void disposeListeners() {
    _socket.off(SocketEvents.chatMessage);
    _socket.off(SocketEvents.chatHistory);
    _socket.off(SocketEvents.typingUpdate);
    _socket.off(SocketEvents.errorMessage);
  }

  Map<String, dynamic> _map(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return {};
  }
}
