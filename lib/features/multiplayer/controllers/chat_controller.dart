import 'package:cardverse/features/multiplayer/models/chat_message_model.dart';
import 'package:cardverse/features/multiplayer/services/dummy_chat_service.dart';
import 'package:flutter/foundation.dart';

class ChatController extends ChangeNotifier {
  ChatController(this._service);

  final DummyChatService _service;
  bool _isSending = false;
  String? _roomCode;

  List<ChatMessageModel> messages = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadMessages(String roomCode) async {
    _roomCode = roomCode;
    isLoading = true;
    notifyListeners();
    try {
      messages = await _service.getRoomMessages(roomCode);
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
    if (roomCode == null || message.trim().isEmpty || _isSending) return false;
    _isSending = true;
    try {
      final sent = await _service.sendMessage(
        roomCode: roomCode,
        senderId: 'current_user',
        senderName: 'Guest Player',
        message: message,
      );
      messages = [...messages, sent];
      notifyListeners();
      return true;
    } finally {
      _isSending = false;
    }
  }

  Future<void> addSystemMessage(String message) async {
    final roomCode = _roomCode;
    if (roomCode == null) return;
    final sent = await _service.addSystemMessage(
      roomCode: roomCode,
      message: message,
    );
    messages = [...messages, sent];
    notifyListeners();
  }

  void clearMessages() {
    _roomCode = null;
    messages = [];
    errorMessage = null;
    notifyListeners();
  }
}
