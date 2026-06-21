import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/features/auth/controllers/auth_controller.dart';
import 'package:cardverse/features/settings/services/settings_api_service.dart';
import 'package:flutter/foundation.dart';

class SettingsController extends ChangeNotifier {
  SettingsController({
    required LocalStorageService storage,
    required SettingsApiService api,
    required AuthController auth,
  }) : _storage = storage,
       _api = api,
       _auth = auth;

  final LocalStorageService _storage;
  final SettingsApiService _api;
  final AuthController _auth;

  bool soundEnabled = true;
  bool vibrationEnabled = true;
  bool notificationsEnabled = true;
  bool isLoading = false;
  String? errorMessage;

  Future<void> initialize() async {
    soundEnabled = await _storage.getBool(StorageKeys.soundEnabled) ?? true;
    vibrationEnabled =
        await _storage.getBool(StorageKeys.vibrationEnabled) ?? true;
    notificationsEnabled =
        await _storage.getBool(StorageKeys.notificationsEnabled) ?? true;
    notifyListeners();
  }

  Future<void> updateLocal({
    bool? sound,
    bool? vibration,
    bool? notifications,
  }) async {
    if (sound != null) {
      soundEnabled = sound;
      await _storage.saveBool(StorageKeys.soundEnabled, sound);
    }
    if (vibration != null) {
      vibrationEnabled = vibration;
      await _storage.saveBool(StorageKeys.vibrationEnabled, vibration);
    }
    if (notifications != null) {
      notificationsEnabled = notifications;
      await _storage.saveBool(StorageKeys.notificationsEnabled, notifications);
    }
    notifyListeners();
  }

  Future<bool> updateCloud({
    bool? notifications,
    bool? privateProfile,
    bool? showOnlineStatus,
  }) async {
    if (!_auth.isAuthenticated) return false;
    isLoading = true;
    notifyListeners();
    try {
      final user = await _api.update({
        'notificationsEnabled': ?notifications,
        'privateProfile': ?privateProfile,
        'showOnlineStatus': ?showOnlineStatus,
      });
      _auth.replaceUser(user);
      return true;
    } catch (error) {
      errorMessage = error.toString();
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteAccount() async {
    try {
      await _api.deleteAccount();
      await _auth.logout();
      return true;
    } catch (error) {
      errorMessage = error.toString();
      notifyListeners();
      return false;
    }
  }
}
