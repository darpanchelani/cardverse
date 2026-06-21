import 'package:cardverse/core/network/api_client.dart';
import 'package:cardverse/core/network/api_endpoints.dart';
import 'package:cardverse/features/auth/models/auth_user_model.dart';
import 'package:cardverse/features/customization/models/cosmetic_item_model.dart';

class ThemesApiService {
  ThemesApiService(this._api);

  final ApiClient _api;

  Future<Map<String, List<CosmeticItemModel>>> load() async {
    final response = await _api.get(ApiEndpoints.themes);
    final data = Map<String, dynamic>.from(
      response['data'] as Map? ?? const {},
    );
    final themes = Map<String, dynamic>.from(
      data['themes'] as Map? ?? const {},
    );
    return themes.map(
      (key, value) => MapEntry(
        key,
        (value as List<dynamic>? ?? const [])
            .map(
              (item) => CosmeticItemModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(),
      ),
    );
  }

  Future<AuthUserModel> purchase(String type, String themeId) =>
      _update('/purchase', type, themeId);

  Future<AuthUserModel> equip(String type, String themeId) =>
      _update('/equip', type, themeId);

  Future<AuthUserModel> _update(
    String action,
    String type,
    String themeId,
  ) async {
    final response = await _api.post(
      '${ApiEndpoints.themes}$action',
      data: {'type': type, 'themeId': themeId},
    );
    final data = Map<String, dynamic>.from(
      response['data'] as Map? ?? const {},
    );
    return AuthUserModel.fromJson(
      Map<String, dynamic>.from(data['user'] as Map? ?? const {}),
    );
  }
}
