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
}
