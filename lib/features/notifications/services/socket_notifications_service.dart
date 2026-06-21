import 'package:cardverse/core/network/socket_service.dart';

class SocketNotificationsService {
  SocketNotificationsService(this._socket);

  final SocketService _socket;

  void listen({
    required void Function(Map<String, dynamic>) onNotification,
    required void Function(int) onUnreadCount,
    required VoidCallback onStatsUpdated,
  }) {
    disposeListeners();
    _socket.on(SocketEvents.notificationNew, (data) {
      onNotification(_map(data));
    });
    _socket.on(SocketEvents.notificationUnreadCount, (data) {
      onUnreadCount((_map(data)['unreadCount'] as num?)?.toInt() ?? 0);
    });
    _socket.on(SocketEvents.userStatsUpdated, (_) => onStatsUpdated());
  }

  void disposeListeners() {
    _socket.off(SocketEvents.notificationNew);
    _socket.off(SocketEvents.notificationUnreadCount);
    _socket.off(SocketEvents.userStatsUpdated);
  }

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map<String, dynamic>
      ? value
      : Map<String, dynamic>.from(value as Map? ?? const {});
}

typedef VoidCallback = void Function();
