import 'package:cardverse/core/network/api_exception.dart';
import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/core/storage/secure_storage_service.dart';
import 'package:cardverse/features/auth/models/auth_user_model.dart';
import 'package:cardverse/features/auth/models/auth_response_model.dart';
import 'package:cardverse/features/auth/services/auth_api_service.dart';
import 'package:cardverse/features/profile/services/profile_api_service.dart';
import 'package:flutter/widgets.dart';

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthApiService authService,
    required ProfileApiService profileService,
    required SecureStorageService secureStorage,
    required LocalStorageService localStorage,
  }) : _authService = authService,
       _profileService = profileService,
       _secureStorage = secureStorage,
       _localStorage = localStorage;

  final AuthApiService _authService;
  final ProfileApiService _profileService;
  final SecureStorageService _secureStorage;
  final LocalStorageService _localStorage;

  AuthUserModel? user;
  String? token;
  bool isGuest = false;
  bool isLoading = false;
  bool isInitialized = false;
  String? errorMessage;

  bool get isAuthenticated => token != null && user != null;
  String get identityId => user?.id ?? 'guest_local_user';
  String get identityUsername => user?.username ?? 'Guest Player';
  int get identityLevel => user?.level ?? 1;
  String get identityAvatar => user?.avatar ?? 'default';

  Future<void> initializeAuth() async {
    isLoading = true;
    notifyListeners();
    token = await _secureStorage.getToken();
    isGuest = await _localStorage.getBool(StorageKeys.isGuestMode) ?? false;
    if (token != null) {
      try {
        user = await _authService.me();
        isGuest = false;
      } catch (_) {
        await _secureStorage.deleteToken();
        token = null;
        user = null;
        isGuest = false;
      }
    }
    isInitialized = true;
    isLoading = false;
    notifyListeners();
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
  }) async {
    return _authenticate(
      () => _authService.register(
        username: username,
        email: email,
        password: password,
      ),
    );
  }

  Future<bool> login({required String email, required String password}) async {
    return _authenticate(
      () => _authService.login(email: email, password: password),
    );
  }

  Future<bool> _authenticate(
    Future<AuthResponseModel> Function() action,
  ) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      final response = await action();
      token = response.token;
      user = response.user;
      await _secureStorage.saveToken(token!);
      await _localStorage.saveBool(StorageKeys.isGuestMode, false);
      isGuest = false;
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } catch (_) {
      errorMessage = 'Could not connect to the CardVerse server.';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> continueAsGuest() async {
    await _secureStorage.deleteToken();
    await _localStorage.saveBool(StorageKeys.isGuestMode, true);
    token = null;
    user = null;
    isGuest = true;
    errorMessage = null;
    notifyListeners();
  }

  Future<void> loadMe() async {
    if (!isAuthenticated) return;
    try {
      user = await _authService.me();
      errorMessage = null;
    } on ApiException catch (error) {
      errorMessage = error.message;
    }
    notifyListeners();
  }

  Future<bool> updateProfile({String? username, String? avatar}) async {
    if (!isAuthenticated) return false;
    isLoading = true;
    notifyListeners();
    try {
      user = await _profileService.update(username: username, avatar: avatar);
      errorMessage = null;
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    if (isAuthenticated) {
      try {
        await _authService.logout();
      } catch (_) {
        // Local logout must still succeed if the backend is unavailable.
      }
    }
    await _secureStorage.deleteToken();
    await _localStorage.saveBool(StorageKeys.isGuestMode, false);
    token = null;
    user = null;
    isGuest = false;
    errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    errorMessage = null;
    notifyListeners();
  }

  void replaceUser(AuthUserModel updatedUser) {
    user = updatedUser;
    notifyListeners();
  }
}

class AuthScope extends InheritedNotifier<AuthController> {
  const AuthScope({
    required AuthController controller,
    required super.child,
    super.key,
  }) : super(notifier: controller);

  static AuthController of(BuildContext context) {
    final scope = maybeOf(context);
    assert(scope != null, 'AuthScope is missing above this context.');
    return scope!;
  }

  static AuthController? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AuthScope>()?.notifier;
}
