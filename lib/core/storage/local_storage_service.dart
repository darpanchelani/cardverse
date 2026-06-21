import 'package:shared_preferences/shared_preferences.dart';

abstract final class StorageKeys {
  static const playerProfile = 'player_profile';
  static const gameStats = 'game_stats';
  static const matchHistory = 'match_history';
  static const achievements = 'achievements';
  static const leaderboard = 'leaderboard';
  static const blackjackChips = 'blackjack_chips';
  static const hasSeenOnboarding = 'has_seen_onboarding';
  static const multiplayerUserId = 'multiplayer_user_id';
  static const localAccount = 'local_account';
  static const localAccounts = 'local_accounts';
  static const activeAccountId = 'active_account_id';
  static const isGuestMode = 'is_guest_mode';
  static const soundEnabled = 'sound_enabled';
  static const vibrationEnabled = 'vibration_enabled';
  static const notificationsEnabled = 'notifications_enabled';
}

class LocalStorageService {
  LocalStorageService(this._preferences);

  final SharedPreferences _preferences;
  String _accountId = 'guest';

  static Future<LocalStorageService> create() async {
    return LocalStorageService(await SharedPreferences.getInstance());
  }

  Future<void> saveString(String key, String value) async {
    await _preferences.setString(key, value);
  }

  Future<String?> getString(String key) async => _preferences.getString(key);

  Future<void> saveBool(String key, bool value) async {
    await _preferences.setBool(key, value);
  }

  Future<bool?> getBool(String key) async => _preferences.getBool(key);

  Future<void> saveInt(String key, int value) async {
    await _preferences.setInt(key, value);
  }

  Future<int?> getInt(String key) async => _preferences.getInt(key);

  Future<void> remove(String key) async {
    await _preferences.remove(key);
  }

  Future<void> clearAll() async {
    await _preferences.clear();
  }

  String scopedKey(String key) => 'account:$_accountId:$key';

  Future<void> useAccount(String accountId) async {
    _accountId = accountId.trim().isEmpty ? 'guest' : accountId.trim();
    await _migrateLegacyProgress();
  }

  Future<void> _migrateLegacyProgress() async {
    for (final key in [
      StorageKeys.playerProfile,
      StorageKeys.gameStats,
      StorageKeys.matchHistory,
      StorageKeys.achievements,
      StorageKeys.leaderboard,
      StorageKeys.blackjackChips,
    ]) {
      final scoped = scopedKey(key);
      if (_preferences.containsKey(scoped) || !_preferences.containsKey(key)) {
        continue;
      }
      final value = _preferences.get(key);
      if (value is String) {
        await _preferences.setString(scoped, value);
      } else if (value is int) {
        await _preferences.setInt(scoped, value);
      }
      await _preferences.remove(key);
    }
  }
}
