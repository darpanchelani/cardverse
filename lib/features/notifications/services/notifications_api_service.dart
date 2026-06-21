import 'package:cardverse/core/network/api_client.dart';
import 'package:cardverse/core/network/api_endpoints.dart';
import 'package:cardverse/features/notifications/models/app_notification_model.dart';

class NotificationsApiService {
  NotificationsApiService(this._api);

  final ApiClient _api;

  Future<({List<AppNotificationModel> items, int unreadCount})> load() async {
    final response = await _api.get(
      ApiEndpoints.notifications,
      query: {'limit': 100},
    );
    final data = Map<String, dynamic>.from(
      response['data'] as Map? ?? const {},
    );
    return (
      items: (data['notifications'] as List<dynamic>? ?? const [])
          .map(
            (item) => AppNotificationModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
      unreadCount: (data['unreadCount'] as num?)?.toInt() ?? 0,
    );
  }

  Future<void> markRead(String id) =>
      _api.post('${ApiEndpoints.notifications}/$id/read').then((_) {});

  Future<void> markAllRead() =>
      _api.post('${ApiEndpoints.notifications}/read-all').then((_) {});

  Future<void> delete(String id) =>
      _api.delete('${ApiEndpoints.notifications}/$id').then((_) {});
}
