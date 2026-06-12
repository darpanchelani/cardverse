import 'dart:convert';

import 'package:cardverse/core/storage/local_storage_service.dart';
import 'package:cardverse/features/auth/local_account_model.dart';
import 'package:crypto/crypto.dart';

class LocalAuthService {
  LocalAuthService(this._storage);

  final LocalStorageService _storage;

  Future<List<LocalAccountModel>> getAccounts() async {
    final raw = await _storage.getString(StorageKeys.localAccounts);
    if (raw == null) return _migrateLegacyAccount();
    try {
      return (jsonDecode(raw) as List<dynamic>)
          .map(
            (item) => LocalAccountModel.fromJson(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<LocalAccountModel> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    final accounts = await getAccounts();
    final normalizedEmail = email.trim().toLowerCase();
    final normalizedUsername = username.trim().toLowerCase();
    if (accounts.any(
      (account) =>
          account.email == normalizedEmail ||
          account.username.toLowerCase() == normalizedUsername,
    )) {
      throw StateError(
        'An account with this email or username already exists.',
      );
    }
    final account = LocalAccountModel(
      id: normalizedEmail,
      fullName: fullName.trim(),
      username: username.trim(),
      email: normalizedEmail,
      passwordHash: _hash(password),
      createdAt: DateTime.now(),
    );
    await _saveAccounts([...accounts, account]);
    await setActiveAccount(account.id);
    return account;
  }

  Future<LocalAccountModel?> login({
    required String email,
    required String password,
  }) async {
    final identifier = email.trim().toLowerCase();
    for (final account in await getAccounts()) {
      final matches =
          account.email == identifier ||
          account.username.toLowerCase() == identifier;
      if (matches && account.passwordHash == _hash(password)) {
        await setActiveAccount(account.id);
        return account;
      }
    }
    return null;
  }

  Future<void> setActiveAccount(String accountId) async {
    await _storage.saveString(StorageKeys.activeAccountId, accountId);
  }

  Future<void> continueAsGuest() async {
    await setActiveAccount('guest');
  }

  Future<void> logout() async {
    await _storage.remove(StorageKeys.activeAccountId);
  }

  Future<List<LocalAccountModel>> _migrateLegacyAccount() async {
    final raw = await _storage.getString(StorageKeys.localAccount);
    if (raw == null) return [];
    try {
      final account = LocalAccountModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
      await _saveAccounts([account]);
      await _storage.remove(StorageKeys.localAccount);
      return [account];
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAccounts(List<LocalAccountModel> accounts) {
    return _storage.saveString(
      StorageKeys.localAccounts,
      jsonEncode(accounts.map((account) => account.toJson()).toList()),
    );
  }

  String _hash(String value) => sha256.convert(utf8.encode(value)).toString();
}
