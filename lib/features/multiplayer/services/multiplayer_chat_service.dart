import 'package:cardverse/features/multiplayer/models/chat_message_model.dart';

abstract class MultiplayerChatService {
  bool get isConnected;

  Future<List<ChatMessageModel>?> loadHistory(String roomCode);
  Future<ChatMessageModel?> sendMessage(String roomCode, String message);
  void sendTypingStart(String roomCode);
  void sendTypingStop(String roomCode);

  void listenChatEvents({
    required void Function(ChatMessageModel message) onMessage,
    required void Function(List<ChatMessageModel> messages) onHistory,
    required void Function(String? username, bool isTyping) onTyping,
    required void Function(String message) onError,
  });

  void disposeListeners();
}
