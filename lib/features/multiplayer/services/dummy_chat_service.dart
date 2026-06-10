import 'package:cardverse/features/multiplayer/models/chat_message_model.dart';

class DummyChatService {
  // TODO: Replace with SocketChatService in Phase 7.
  final Map<String, List<ChatMessageModel>> _messages = {};

  Future<List<ChatMessageModel>> getRoomMessages(String roomCode) async =>
      List.of(_messages[roomCode] ?? const []);

  Future<ChatMessageModel> sendMessage({
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
}
