class InviteModel {
  const InviteModel({
    required this.id,
    required this.roomCode,
    required this.fromUserId,
    required this.fromUsername,
    required this.toUserId,
    required this.toUsername,
    required this.gameName,
    required this.status,
    required this.createdAt,
  });

  factory InviteModel.fromJson(Map<String, dynamic> json) => InviteModel(
    id: json['id'] as String? ?? '',
    roomCode: json['roomCode'] as String? ?? '',
    fromUserId: json['fromUserId'] as String? ?? '',
    fromUsername: json['fromUsername'] as String? ?? '',
    toUserId: json['toUserId'] as String? ?? '',
    toUsername: json['toUsername'] as String? ?? '',
    gameName: json['gameName'] as String? ?? 'Card Game',
    status: json['status'] as String? ?? 'pending',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
  );

  final String id;
  final String roomCode;
  final String fromUserId;
  final String fromUsername;
  final String toUserId;
  final String toUsername;
  final String gameName;
  final String status;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
    'id': id,
    'roomCode': roomCode,
    'fromUserId': fromUserId,
    'fromUsername': fromUsername,
    'toUserId': toUserId,
    'toUsername': toUsername,
    'gameName': gameName,
    'status': status,
    'createdAt': createdAt.toIso8601String(),
  };

  InviteModel copyWith({
    String? id,
    String? roomCode,
    String? fromUserId,
    String? fromUsername,
    String? toUserId,
    String? toUsername,
    String? gameName,
    String? status,
    DateTime? createdAt,
  }) => InviteModel(
    id: id ?? this.id,
    roomCode: roomCode ?? this.roomCode,
    fromUserId: fromUserId ?? this.fromUserId,
    fromUsername: fromUsername ?? this.fromUsername,
    toUserId: toUserId ?? this.toUserId,
    toUsername: toUsername ?? this.toUsername,
    gameName: gameName ?? this.gameName,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
}
