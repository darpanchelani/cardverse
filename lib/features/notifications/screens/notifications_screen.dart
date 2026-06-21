import 'package:cardverse/app/app_services_scope.dart';
import 'package:cardverse/app/routes.dart';
import 'package:cardverse/core/widgets/app_empty_state.dart';
import 'package:cardverse/core/widgets/app_error_view.dart';
import 'package:cardverse/core/widgets/app_loading_indicator.dart';
import 'package:cardverse/features/notifications/widgets/notification_tile_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = AppServicesScope.of(context).notifications;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: controller.unreadCount == 0
                ? null
                : controller.markAllAsRead,
            child: const Text('Read all'),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          if (controller.isLoading) return const AppLoadingIndicator();
          if (controller.errorMessage != null) {
            return AppErrorView(
              message: controller.errorMessage!,
              onRetry: controller.loadNotifications,
            );
          }
          if (controller.notifications.isEmpty) {
            return const AppEmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No notifications yet',
              message:
                  'Friend requests, invites, and match updates appear here.',
            );
          }
          return RefreshIndicator(
            onRefresh: controller.loadNotifications,
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              itemCount: controller.notifications.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final notification = controller.notifications[index];
                return NotificationTileWidget(
                  notification: notification,
                  onTap: () async {
                    if (!notification.isRead) {
                      await controller.markAsRead(notification.id);
                    }
                    if (!context.mounted) return;
                    switch (notification.type) {
                      case 'friend_request':
                        context.push(AppRoutes.friendRequests);
                      case 'room_invite':
                        context.push(AppRoutes.invites);
                      case 'achievement_unlocked':
                        context.push(AppRoutes.achievements);
                      case 'match_result':
                        context.push(AppRoutes.matchHistory);
                    }
                  },
                  onDelete: () =>
                      controller.deleteNotification(notification.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
