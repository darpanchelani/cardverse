import 'package:cardverse/features/multiplayer/models/friend_model.dart';

class FriendRequestModel {
  const FriendRequestModel({
    required this.id,
    required this.fromUser,
    required this.toUser,
    required this.status,
    required this.createdAt,
  });

  factory FriendRequestModel.fromJson(Map<String, dynamic> json) =>
      FriendRequestModel(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        fromUser: FriendModel.fromJson(
          Map<String, dynamic>.from(json['fromUser'] as Map? ?? const {}),
        ),
        toUser: FriendModel.fromJson(
          Map<String, dynamic>.from(json['toUser'] as Map? ?? const {}),
        ),
        status: json['status'] as String? ?? 'pending',
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  final String id;
  final FriendModel fromUser;
  final FriendModel toUser;
  final String status;
  final DateTime createdAt;
}
