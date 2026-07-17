import 'dart:async';

import 'package:cardverse/core/config/app_config.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

abstract interface class GoogleAuthGateway {
  Future<void> initialize();

  Stream<String> get idTokens;

  Future<String> authenticate();
}

class GoogleAuthService implements GoogleAuthGateway {
  GoogleAuthService._();

  static final GoogleAuthService instance = GoogleAuthService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final StreamController<String> _idTokenController =
      StreamController<String>.broadcast();
  Future<void>? _initialization;

  @override
  Stream<String> get idTokens => _idTokenController.stream;

  @override
  Future<void> initialize() => _initialization ??= _initialize();

  Future<void> _initialize() async {
    if (kIsWeb && AppConfig.googleClientId.isEmpty) {
      throw StateError(
        'Google sign-in needs GOOGLE_CLIENT_ID for this web build.',
      );
    }

    await _googleSignIn.initialize(
      clientId: AppConfig.googleClientId.isEmpty
          ? null
          : AppConfig.googleClientId,
      serverClientId: AppConfig.googleServerClientId.isEmpty
          ? null
          : AppConfig.googleServerClientId,
    );
    _googleSignIn.authenticationEvents.listen((event) {
      if (event is GoogleSignInAuthenticationEventSignIn) {
        final token = event.user.authentication.idToken;
        if (token != null && token.isNotEmpty) {
          _idTokenController.add(token);
        } else {
          _idTokenController.addError(
            StateError('Google did not return an ID token.'),
          );
        }
      }
    }, onError: _idTokenController.addError);
  }

  @override
  Future<String> authenticate() async {
    await initialize();
    if (!_googleSignIn.supportsAuthenticate()) {
      throw UnsupportedError(
        'Use the Google-provided button to sign in on this platform.',
      );
    }
    final account = await _googleSignIn.authenticate();
    final token = account.authentication.idToken;
    if (token == null || token.isEmpty) {
      throw StateError('Google did not return an ID token.');
    }
    return token;
  }
}
