import 'package:cardverse/features/multiplayer/models/chat_message_model.dart';
import 'package:cardverse/features/multiplayer/services/multiplayer_chat_service.dart';
import 'package:flutter/foundation.dart';

class ChatController extends ChangeNotifier {
  ChatController(this._service) {
    _service.listenChatEvents(
      onMessage: _onMessage,
      onHistory: _onHistory,
      onTyping: _onTyping,
      onError: _onError,
    );
  }

  final MultiplayerChatService _service;
  bool _isSending = false;
  String? _roomCode;

  List<ChatMessageModel> messages = [];
  bool isLoading = false;
  bool isTyping = false;
  String? typingUsername;
  String? errorMessage;

  bool get isConnected => _service.isConnected;

  Future<void> loadMessages(String roomCode) async {
    _roomCode = roomCode;
    isLoading = true;
    notifyListeners();
    try {
      final history = await _service.loadHistory(roomCode);
      if (history != null) messages = history;
      errorMessage = null;
    } catch (_) {
      errorMessage = 'Could not load room chat.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage(String message) async {
    final roomCode = _roomCode;
    if (roomCode == null ||
        message.trim().isEmpty ||
        _isSending ||
        !isConnected) {
      return false;
    }
    _isSending = true;
    try {
      final sent = await _service.sendMessage(roomCode, message.trim());
      if (sent != null) _onMessage(sent);
      return true;
    } catch (error) {
      errorMessage = error is StateError
          ? error.message
          : 'Could not send this message.';
      notifyListeners();
      return false;
    } finally {
      _isSending = false;
    }
  }

  void sendTypingStart() {
    final roomCode = _roomCode;
    if (roomCode != null && isConnected) {
      _service.sendTypingStart(roomCode);
    }
  }

  void sendTypingStop() {
    final roomCode = _roomCode;
    if (roomCode != null && isConnected) {
      _service.sendTypingStop(roomCode);
    }
  }

  void clearMessages() {
    _roomCode = null;
    messages = [];
    isTyping = false;
    typingUsername = null;
    errorMessage = null;
    notifyListeners();
  }

  void _onMessage(ChatMessageModel message) {
    if (_roomCode != null && message.roomCode != _roomCode) return;
    if (messages.any((item) => item.id == message.id)) return;
    messages = [...messages, message];
    notifyListeners();
  }

  void _onHistory(List<ChatMessageModel> history) {
    messages = history;
    notifyListeners();
  }

  void _onTyping(String? username, bool typing) {
    isTyping = typing;
    typingUsername = typing ? username : null;
    notifyListeners();
  }

  void _onError(String message) {
    errorMessage = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _service.disposeListeners();
    super.dispose();
  }
}
