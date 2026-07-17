import 'package:cardverse/core/network/api_client.dart';
import 'package:cardverse/core/network/api_endpoints.dart';
import 'package:cardverse/features/auth/models/auth_response_model.dart';
import 'package:cardverse/features/auth/models/auth_user_model.dart';

class AuthApiService {
  AuthApiService(this._api);

  final ApiClient _api;

  Future<AuthResponseModel> loginWithGoogle({required String idToken}) async {
    final response = await _api.post(
      ApiEndpoints.googleLogin,
      data: {'idToken': idToken},
    );
    return AuthResponseModel.fromJson(response);
  }

  Future<AuthUserModel> me() async {
    final response = await _api.get(ApiEndpoints.authMe);
    final data = Map<String, dynamic>.from(
      response['data'] as Map? ?? const {},
    );
    return AuthUserModel.fromJson(
      Map<String, dynamic>.from(data['user'] as Map? ?? const {}),
    );
  }

  Future<void> logout() async {
    await _api.post(ApiEndpoints.logout);
  }
}
