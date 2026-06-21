class AppNotificationModel {
  const AppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.data,
    required this.isRead,
    required this.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) =>
      AppNotificationModel(
        id: (json['id'] ?? json['_id'] ?? '').toString(),
        type: json['type'] as String? ?? 'system',
        title: json['title'] as String? ?? 'CardVerse',
        message: json['message'] as String? ?? '',
        data: Map<String, dynamic>.from(json['data'] as Map? ?? const {}),
        isRead: json['isRead'] as bool? ?? false,
        createdAt:
            DateTime.tryParse(json['createdAt'] as String? ?? '') ??
            DateTime.now(),
      );

  final String id;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime createdAt;

  AppNotificationModel copyWith({bool? isRead}) => AppNotificationModel(
    id: id,
    type: type,
    title: title,
    message: message,
    data: data,
    isRead: isRead ?? this.isRead,
    createdAt: createdAt,
  );
}
