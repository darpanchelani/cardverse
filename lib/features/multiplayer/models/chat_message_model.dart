class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.roomCode,
    required this.senderId,
    required this.senderName,
    required this.message,
    required this.sentAt,
    required this.isSystemMessage,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) =>
      ChatMessageModel(
        id: json['id'] as String? ?? '',
        roomCode: json['roomCode'] as String? ?? '',
        senderId: json['senderId'] as String? ?? '',
        senderName: json['senderName'] as String? ?? '',
        message: json['message'] as String? ?? '',
        sentAt:
            DateTime.tryParse(json['sentAt'] as String? ?? '') ??
            DateTime.now(),
        isSystemMessage: json['isSystemMessage'] as bool? ?? false,
      );

  final String id;
  final String roomCode;
  final String senderId;
  final String senderName;
  final String message;
  final DateTime sentAt;
  final bool isSystemMessage;

  Map<String, dynamic> toJson() => {
    'id': id,
    'roomCode': roomCode,
    'senderId': senderId,
    'senderName': senderName,
    'message': message,
    'sentAt': sentAt.toIso8601String(),
    'isSystemMessage': isSystemMessage,
  };

  ChatMessageModel copyWith({
    String? id,
    String? roomCode,
    String? senderId,
    String? senderName,
    String? message,
    DateTime? sentAt,
    bool? isSystemMessage,
  }) => ChatMessageModel(
    id: id ?? this.id,
    roomCode: roomCode ?? this.roomCode,
    senderId: senderId ?? this.senderId,
    senderName: senderName ?? this.senderName,
    message: message ?? this.message,
    sentAt: sentAt ?? this.sentAt,
    isSystemMessage: isSystemMessage ?? this.isSystemMessage,
  );
}
