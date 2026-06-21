import 'dart:async';

import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/notifications/models/app_notification_model.dart';
import 'package:cardverse/features/notifications/services/notifications_api_service.dart';
import 'package:cardverse/features/notifications/services/socket_notifications_service.dart';
import 'package:flutter/foundation.dart';

class NotificationsController extends ChangeNotifier {
  NotificationsController({
    required NotificationsApiService api,
    required SocketNotificationsService socket,
    required AuthController auth,
  }) : _api = api,
       _socket = socket,
       _auth = auth {
    _socket.listen(
      onNotification: handleSocketNotification,
      onUnreadCount: (count) {
        unreadCount = count;
        notifyListeners();
      },
      onStatsUpdated: () => unawaited(_auth.loadMe()),
    );
  }

  final NotificationsApiService _api;
  final SocketNotificationsService _socket;
  final AuthController _auth;

  List<AppNotificationModel> notifications = [];
  int unreadCount = 0;
  bool isLoading = false;
  String? errorMessage;
  AppNotificationModel? latestNotification;

  Future<void> loadNotifications() async {
    if (!_auth.isAuthenticated) {
      notifications = [];
      unreadCount = 0;
      notifyListeners();
      return;
    }
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final result = await _api.load();
      notifications = result.items;
      unreadCount = result.unreadCount;
    } catch (error) {
      errorMessage = error.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String id) async {
    await _api.markRead(id);
    notifications = notifications
        .map((item) => item.id == id ? item.copyWith(isRead: true) : item)
        .toList();
    unreadCount = notifications.where((item) => !item.isRead).length;
    notifyListeners();
  }

  Future<void> markAllAsRead() async {
    await _api.markAllRead();
    notifications = notifications
        .map((item) => item.copyWith(isRead: true))
        .toList();
    unreadCount = 0;
    notifyListeners();
  }

  Future<void> deleteNotification(String id) async {
    await _api.delete(id);
    notifications = notifications.where((item) => item.id != id).toList();
    unreadCount = notifications.where((item) => !item.isRead).length;
    notifyListeners();
  }

  void handleSocketNotification(Map<String, dynamic> json) {
    final notification = AppNotificationModel.fromJson(json);
    if (notifications.any((item) => item.id == notification.id)) return;
    notifications = [notification, ...notifications];
    unreadCount += notification.isRead ? 0 : 1;
    latestNotification = notification;
    notifyListeners();
  }

  void consumeLatest() {
    latestNotification = null;
  }

  void clear() {
    notifications = [];
    unreadCount = 0;
    latestNotification = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _socket.disposeListeners();
    super.dispose();
  }
}
