import 'package:cardverse/core/network/api_client.dart';
import 'package:cardverse/core/network/api_endpoints.dart';
import 'package:cardverse/features/auth/models/auth_user_model.dart';

class SettingsApiService {
  SettingsApiService(this._api);

  final ApiClient _api;

  Future<AuthUserModel> update(Map<String, dynamic> settings) async {
    final response = await _api.patch(
      ApiEndpoints.userSettings,
      data: settings,
    );
    final data = Map<String, dynamic>.from(
      response['data'] as Map? ?? const {},
    );
    return AuthUserModel.fromJson(
      Map<String, dynamic>.from(data['user'] as Map? ?? const {}),
    );
  }

  Future<void> deleteAccount() =>
      _api.delete(ApiEndpoints.usersMe).then((_) {});
}
