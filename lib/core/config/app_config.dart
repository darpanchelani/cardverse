abstract final class AppConfig {
  /// iOS Simulator and Flutter web can use localhost.
  ///
  /// Android Emulator should run with:
  /// `--dart-define=SOCKET_BASE_URL=http://10.0.2.2:5050`
  ///
  /// Physical devices should use the computer's LAN address, for example:
  /// `--dart-define=SOCKET_BASE_URL=http://192.168.1.20:5050`
  static const socketBaseUrl = String.fromEnvironment(
    'SOCKET_BASE_URL',
    defaultValue: 'http://localhost:5050',
  );

  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '$socketBaseUrl/api',
  );

  /// OAuth client IDs are intentionally supplied at build/run time.
  ///
  /// `GOOGLE_CLIENT_ID` is used by web and Apple platforms. Android can read
  /// its client ID from `google-services.json` instead. `GOOGLE_SERVER_CLIENT_ID`
  /// should be the web OAuth client ID accepted by the CardVerse backend.
  static const googleClientId = String.fromEnvironment('GOOGLE_CLIENT_ID');
  static const googleServerClientId = String.fromEnvironment(
    'GOOGLE_SERVER_CLIENT_ID',
  );
}
