import 'package:cardverse/features/multiplayer/models/chat_message_model.dart';
import 'package:cardverse/features/multiplayer/services/multiplayer_chat_service.dart';

class DummyChatService implements MultiplayerChatService {
  // TODO: Replace with SocketChatService in Phase 7.
  final Map<String, List<ChatMessageModel>> _messages = {};

  @override
  bool get isConnected => true;

  Future<List<ChatMessageModel>> getRoomMessages(String roomCode) async =>
      List.of(_messages[roomCode] ?? const []);

  @override
  Future<List<ChatMessageModel>?> loadHistory(String roomCode) =>
      getRoomMessages(roomCode);

  @override
  Future<ChatMessageModel?> sendMessage(String roomCode, String message) {
    return sendLocalMessage(
      roomCode: roomCode,
      senderId: 'current_user',
      senderName: 'Guest Player',
      message: message,
    );
  }

  Future<ChatMessageModel> sendLocalMessage({
    required String roomCode,
    required String senderId,
    required String senderName,
    required String message,
  }) async {
    final chatMessage = ChatMessageModel(
      id: 'message_${DateTime.now().microsecondsSinceEpoch}',
      roomCode: roomCode,
      senderId: senderId,
      senderName: senderName,
      message: message.trim(),
      sentAt: DateTime.now(),
      isSystemMessage: false,
    );
    _messages.putIfAbsent(roomCode, () => []).add(chatMessage);
    return chatMessage;
  }

  Future<ChatMessageModel> addSystemMessage({
    required String roomCode,
    required String message,
  }) async {
    final chatMessage = ChatMessageModel(
      id: 'system_${DateTime.now().microsecondsSinceEpoch}',
      roomCode: roomCode,
      senderId: 'system',
      senderName: 'CardVerse',
      message: message,
      sentAt: DateTime.now(),
      isSystemMessage: true,
    );
    _messages.putIfAbsent(roomCode, () => []).add(chatMessage);
    return chatMessage;
  }

  @override
  void sendTypingStart(String roomCode) {}

  @override
  void sendTypingStop(String roomCode) {}

  @override
  void listenChatEvents({
    required void Function(ChatMessageModel message) onMessage,
    required void Function(List<ChatMessageModel> messages) onHistory,
    required void Function(String? username, bool isTyping) onTyping,
    required void Function(String message) onError,
  }) {}

  @override
  void disposeListeners() {}
}
