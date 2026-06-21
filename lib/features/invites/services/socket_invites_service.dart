import 'package:cardverse/core/network/socket_service.dart';

class SocketInvitesService {
  SocketInvitesService(this._socket);

  final SocketService _socket;

  void listen({
    required void Function(Map<String, dynamic>) onReceived,
    required void Function(Map<String, dynamic>) onAccepted,
    required void Function(Map<String, dynamic>) onDeclined,
    required void Function(Map<String, dynamic>) onCancelled,
  }) {
    disposeListeners();
    _socket.on(SocketEvents.inviteReceived, (data) => onReceived(_map(data)));
    _socket.on(SocketEvents.inviteAccepted, (data) => onAccepted(_map(data)));
    _socket.on(SocketEvents.inviteDeclined, (data) => onDeclined(_map(data)));
    _socket.on(SocketEvents.inviteCancelled, (data) => onCancelled(_map(data)));
  }

  void disposeListeners() {
    _socket.off(SocketEvents.inviteReceived);
    _socket.off(SocketEvents.inviteAccepted);
    _socket.off(SocketEvents.inviteDeclined);
    _socket.off(SocketEvents.inviteCancelled);
  }

  static Map<String, dynamic> _map(dynamic value) =>
      value is Map<String, dynamic>
      ? value
      : Map<String, dynamic>.from(value as Map? ?? const {});
}
