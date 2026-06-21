import 'package:cardverse/core/constants/app_colors.dart';
import 'package:cardverse/features/notifications/models/app_notification_model.dart';
import 'package:flutter/material.dart';

class NotificationTileWidget extends StatelessWidget {
  const NotificationTileWidget({
    required this.notification,
    required this.onTap,
    required this.onDelete,
    super.key,
  });

  final AppNotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Card(
    color: notification.isRead
        ? AppColors.cardGreen
        : AppColors.gold.withValues(alpha: 0.12),
    child: ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: AppColors.inputGreen,
        child: Icon(_icon(notification.type), color: AppColors.gold),
      ),
      title: Text(notification.title),
      subtitle: Text(
        '${notification.message}\n${_time(notification.createdAt)}',
      ),
      isThreeLine: true,
      trailing: IconButton(
        tooltip: 'Delete',
        onPressed: onDelete,
        icon: const Icon(Icons.close_rounded),
      ),
    ),
  );

  static IconData _icon(String type) => switch (type) {
    'room_invite' => Icons.mail_outline_rounded,
    'friend_request' => Icons.person_add_alt_1_rounded,
    'friend_accept' => Icons.people_rounded,
    'achievement_unlocked' => Icons.emoji_events_rounded,
    'match_result' => Icons.style_rounded,
    _ => Icons.notifications_none_rounded,
  };

  static String _time(DateTime date) {
    final difference = DateTime.now().difference(date);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    return '${difference.inDays}d ago';
  }
}
