import 'package:cardverse/features/auth/models/auth_user_model.dart';

class AuthResponseModel {
  const AuthResponseModel({required this.token, required this.user});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    final data = Map<String, dynamic>.from(json['data'] as Map? ?? json);
    return AuthResponseModel(
      token: data['token'] as String? ?? '',
      user: AuthUserModel.fromJson(
        Map<String, dynamic>.from(data['user'] as Map? ?? const {}),
      ),
    );
  }

  final String token;
  final AuthUserModel user;
}
